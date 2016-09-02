using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlServerCe;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Security.Policy;
using System.Text;
using System.Text.RegularExpressions;
using Umbraco.Core;
using Umbraco.Core.Models;
using Umbraco.Core.Persistence;
using Umbraco.Core.Services;
using IOMG.Umbraco.StandaloneServices;

namespace Website.ContentAdmin
{
    /// <summary>
    /// Before running this console app please ensure that the "umbracoDbDSN" ConnectionString is pointing to your database.
    /// If you are using Sql Ce please replace "|DataDirectory|" with a real path or alternatively place 
    /// your database in the debug folder before running the application in debug mode.
    /// </summary>
    class Program
    {
        private static Regex r = new Regex(":");

        static void Main(string[] args)
        {
            RunUmbraco();
        }

        private static void RunUmbraco()
        {
            Console.Title = "Umbraco Console";

            var umbracoAccess = new ServiceAccess();

            //Exit the application?
            var waitOrBreak = true;
            while (waitOrBreak)
            {
                //List options
                Console.WriteLine("-- Options --");
                Console.WriteLine("Load beers from file: b");
                Console.WriteLine("Quit application: q");

                var input = Console.ReadLine();
                if (string.IsNullOrEmpty(input) == false && input.ToLowerInvariant().Equals("q"))
                    waitOrBreak = false;                
                else if (string.IsNullOrEmpty(input) == false && input.ToLowerInvariant().Equals("b"))
                    UploadBeersFromFile(umbracoAccess.Services.ContentService, umbracoAccess.Services.MediaService);
            }
        }

        private static void UploadBeersFromFile(IContentService contentService, IMediaService mediaService)
        {
            // Indices of columns
            var nameIndex = -1;
            var countryIndex = -1;
            var brewerIndex = -1;
            var notesIndex = -1;
            var ratingIndex = -1;
            var imageCandidateIndex = -1;
            var imageChosenIndex = -1;

            // Values of columns
            string name = null;
            string country = null;
            string brewer = null;
            string notes = null;
            short rating = 0;
            string imageCandidates = null;
            string imageChosen = null;
            int imageId = 0;
            DateTime imageDateTaken = DateTime.MinValue;

            var inputFileDirectory = ConfigurationManager.AppSettings["BeerFileDirectory"];
            Console.WriteLine("Please enter name of the input file:");
            var inputFileName = Console.ReadLine();
            // TODO: check file exists
            using (var fileReader = new StreamReader(Path.Combine(inputFileDirectory, inputFileName)))
            {
                var currentRow = new string[0];
                var firstRow = true;
                var counter = 0; // Temp restriction                
                while (!fileReader.EndOfStream && counter < 10)
                {
                    currentRow = fileReader.ReadLine().Split(',');
                    if (firstRow)
                    {
                        nameIndex = currentRow.IndexOf("Beer");
                        countryIndex = currentRow.IndexOf("Country");
                        brewerIndex = currentRow.IndexOf("Brewer");
                        notesIndex = currentRow.IndexOf("Notes");
                        ratingIndex = currentRow.IndexOf("Rating");
                        imageCandidateIndex = currentRow.IndexOf("Matched Images");
                        imageChosenIndex = currentRow.IndexOf("Used Image");
                        firstRow = false;
                        continue;
                    }
                    name = currentRow[nameIndex];
                    country = currentRow[countryIndex];
                    if (!string.IsNullOrWhiteSpace(country))
                    {
                        brewer = currentRow[brewerIndex];
                        notes = currentRow[notesIndex];
                        short.TryParse(currentRow[ratingIndex], out rating);
                        imageCandidates = currentRow[imageCandidateIndex];
                        imageChosen = currentRow[imageChosenIndex];

                        if (string.IsNullOrWhiteSpace(imageChosen))
                        {
                            imageChosen = FindImage(name, country, out imageCandidates);
                        }

                        // TODO: check first that the media with given name exists
                        if (!string.IsNullOrWhiteSpace(imageChosen))
                        {
                            imageId = UploadImage(imageChosen, country, mediaService);
                            var imageChosenPath = Path.Combine(ConfigurationManager.AppSettings["BeerImagesRootDirectory"], country, Path.ChangeExtension(imageChosen, ".jpg"));
                            imageDateTaken = GetDateTakenFromImage(imageChosenPath);
                        }

                        UploadBeer(name, brewer, country, notes, rating, imageId, imageDateTaken, contentService);

                        // TODO: create output file as input file but with image columns updated
                    }

                    counter++;
                }
            }
        }
        
        private static string FindImage(string beerName, string country, out string candidates)
        {                        
            var imageDirectory = ConfigurationManager.AppSettings["BeerImagesRootDirectory"];
            var possibleMatches = new SortedDictionary<int, List<string>>();
            foreach (var filePath in Directory.GetFiles(Path.Combine(imageDirectory, country)))
            {
                var fileName = Path.GetFileNameWithoutExtension(filePath);
                var beerNameMatchArray = beerName.ToLower().Split(' ');
                var fileNameMatchArray = fileName.ToLower().Split('-');
                var matchingWords = beerNameMatchArray.Intersect(fileNameMatchArray).Count();
                var difference = Math.Abs(beerNameMatchArray.Count() - matchingWords);
                if (matchingWords > 0)
                {
                    if (possibleMatches.ContainsKey(difference))
                    {
                        possibleMatches[difference].Add(fileName);
                    }
                    else
                    {
                        possibleMatches.Add(difference, new List<string>(new[] { fileName }));
                    }
                }                
            }
            candidates = string.Join(",", possibleMatches.SelectMany(x => x.Value));
            return possibleMatches.Count() > 0 ? possibleMatches.First().Value[0] : null;
        }

        private static int UploadImage(string imageName, string country, IMediaService mediaService)
        {
            var imageDirectory = ConfigurationManager.AppSettings["BeerImagesRootDirectory"];
            var imageFileName = Path.ChangeExtension(imageName, ".jpg");
            using (var fileStream = new FileStream(Path.Combine(imageDirectory, country, imageFileName), FileMode.Open))
            {
                var beerMediaRoot = mediaService.GetRootMedia().SingleOrDefault(x => x.Name == "Beers");
                var countryMediaParent = mediaService.GetChildren(beerMediaRoot.Id).SingleOrDefault(x => x.Name == country);
                var image = mediaService.CreateMedia(imageFileName, countryMediaParent, "Image");
                image.SetValue("umbracoFile", fileStream.Name, fileStream);
                mediaService.Save(image);
                return image.Id;
            }
        }

        private static int UploadBeer(string name, string brewer, string country, string notes, short rating, int imageId, DateTime imageDateTaken, IContentService contentService)
        {
            var rootContent = contentService.GetRootContent().SingleOrDefault();
            var beersRoot = contentService.GetChildren(rootContent.Id).SingleOrDefault(x => x.Name == "Beer Reviews");
            var countryItem = contentService.GetChildren(beersRoot.Id).SingleOrDefault(x => x.Name == country);
            var newBeer = contentService.CreateContent(name, countryItem.Id, "Beer");
            newBeer.Properties["fullName"].Value = name;
            newBeer.Properties["brewer"].Value = brewer;
            newBeer.Properties["image"].Value = imageId;
            newBeer.Properties["imageDate"].Value = imageDateTaken;
            newBeer.Properties["review"].Value = notes;
            newBeer.Properties["rating"].Value = rating;

            //Save the Content
            contentService.Save(newBeer);
            return newBeer.Id;
        }

        private static DateTime GetDateTakenFromImage(string path)
        {            
            using (FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read))
            {
                using (Image myImage = Image.FromStream(fs, false, false))
                {
                    PropertyItem propItem = myImage.GetPropertyItem(36867);
                    string dateTakenText = r.Replace(Encoding.UTF8.GetString(propItem.Value), "-", 2);
                    DateTime dateTaken;
                    DateTime.TryParse(dateTakenText, out dateTaken);
                    return dateTaken;
                }
            }
        }
    }
}