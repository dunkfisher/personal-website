using IOMG.Umbraco.StandaloneServices;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using Umbraco.Core;
using Umbraco.Core.Models;
using Umbraco.Core.Services;

namespace Website.ContentAdmin
{
    class Program
    {
        private static string _beerImagesRootDirectory;
        private static Regex _dateTakenRegex = new Regex(":");

        private static string BeerImagesRootDirectory
        {
            get
            {
                if (_beerImagesRootDirectory == null)
                {
                    _beerImagesRootDirectory = ConfigurationManager.AppSettings["BeerImagesRootDirectory"];
                }
                return _beerImagesRootDirectory;
            }
        }

        static void Main(string[] args)
        {
            Console.Title = "Umbraco Console";
            var commandSettings = new CommandSettings(args);
            var umbracoAccess = new ServiceAccess();

            if (commandSettings.Command == Command.LoadBeerData)
            {
                UploadBeersFromFile(umbracoAccess.Services.ContentService, umbracoAccess.Services.MediaService, commandSettings.UpdateExisting, commandSettings.BeerFile, commandSettings.BeerName);
            }
            else if (commandSettings.Command == Command.UpdateMissingImages)
            {
                UpdateMissingImage(umbracoAccess.Services.ContentTypeService, umbracoAccess.Services.ContentService, umbracoAccess.Services.MediaService, commandSettings.BeerName);
            }
            else if (commandSettings.Command == Command.RefreshImageDate)
            {
                UpdateBeerImageDate(umbracoAccess.Services.ContentTypeService, umbracoAccess.Services.ContentService, umbracoAccess.Services.MediaService, commandSettings.BeerName);
            }
            else if (commandSettings.Command == Command.DeleteMedia)
            {
                DeleteMedia(umbracoAccess.Services.MediaService);
            }

            Console.WriteLine("Press any key to exit.");
            Console.ReadKey();
        }

        private static void UploadBeersFromFile(IContentService contentService,
            IMediaService mediaService,
            bool updateExisting = false,
            string beerFile = null,
            string beerName = null)
        {
            // Indices of columns
            var nameIndex = -1;
            var countryIndex = -1;
            var brewerIndex = -1;
            var typeIndex = -1;
            var styleIndex = -1;
            var sourceIndex = -1;
            var abvIndex = -1;
            var notesIndex = -1;
            var ratingIndex = -1;
            var imageCandidateIndex = -1;
            var imageChosenIndex = -1;

            // Values of columns
            string name = null;
            string country = null;
            string brewer = null;
            string type = null;
            string style = null;
            string source = null;
            decimal abv = 0m;
            string notes = null;
            short rating = 0;
            string imageCandidates = null;
            string imageChosen = null;
            int imageId = 0;
            DateTime imageDateTaken = DateTime.MinValue;

            var inputFileDirectory = ConfigurationManager.AppSettings["BeerFileDirectory"];
            var inputFilePath = Path.Combine(inputFileDirectory, beerFile);
            if (!System.IO.File.Exists(inputFilePath))
            {
                Console.WriteLine("Input file " + inputFilePath + " doesn't exist.");
                Console.ReadLine();
                return;
            }

            using (var fileReader = new StreamReader(inputFilePath))
            {
                var outputFilePath = string.Format("{0}_{1}.csv",
                    Path.Combine(Path.GetDirectoryName(inputFilePath), "BeerUploadResult"),
                    DateTime.Now.ToString("yyyyMMddhhmmss"));
                using (var fileWriter = new StreamWriter(outputFilePath))
                {
                    var currentRow = new string[0];
                    var firstRow = true;
                    while (!fileReader.EndOfStream)
                    {
                        currentRow = fileReader.ReadLine().Split(new[] { ',' }, 9);
                        if (firstRow)
                        {
                            nameIndex = currentRow.IndexOf("Beer");
                            countryIndex = currentRow.IndexOf("Country");
                            brewerIndex = currentRow.IndexOf("Brewer");
                            typeIndex = currentRow.IndexOf("Type");
                            styleIndex = currentRow.IndexOf("Style");
                            sourceIndex = currentRow.IndexOf("Source");
                            abvIndex = currentRow.IndexOf("ABV");
                            notesIndex = currentRow.IndexOf("Notes");
                            ratingIndex = currentRow.IndexOf("Rating");
                            if (notesIndex != 8 || new[] { nameIndex, countryIndex, brewerIndex, typeIndex, styleIndex, sourceIndex, abvIndex, notesIndex, ratingIndex }.Any(x => x < 0))
                            {
                                Console.WriteLine("Columns are incorrectly present in the input file.");
                                return;
                            }

                            // Write to output
                            Console.WriteLine("Writing headers to output file: " + outputFilePath + "..");
                            Console.WriteLine();
                            fileWriter.WriteLine("Result Code,Beer,Country,Brewer,Type,Style,Source,ABV,Rating,Matched Images,Used Image,Notes");

                            firstRow = false;
                            continue;
                        }

                        name = currentRow[nameIndex];
                        if (string.IsNullOrWhiteSpace(name))
                        {
                            Console.WriteLine("Missing beer name.");
                            Console.WriteLine();
                            continue;
                        }

                        if (beerName == null || name.Equals(beerName, StringComparison.CurrentCultureIgnoreCase))
                        {
                            UpdateStatus? status = null;

                            country = currentRow[countryIndex];
                            if (string.IsNullOrWhiteSpace(country))
                            {
                                Console.WriteLine("Missing country of origin.");
                                Console.WriteLine();
                                fileWriter.WriteLine(string.Join(",", UpdateStatus.N_NO_COUNTRY, name, country, brewer, type, style, source, abv, rating, imageCandidates, imageChosen, notes));
                                continue;
                            }

                            Console.WriteLine(string.Format("Loading data for {0} ({1})", name, country));

                            Console.WriteLine("Searching for image..");
                            imageChosen = FindImage(name, country, out imageCandidates);

                            if (!string.IsNullOrWhiteSpace(imageChosen))
                            {
                                Console.WriteLine("Uploading image: " + imageChosen + "..");
                                imageId = UploadImage(imageChosen, country, updateExisting, mediaService);
                                if (imageId >= 0)
                                {
                                    var imageChosenPath = Path.Combine(BeerImagesRootDirectory, country, Path.ChangeExtension(imageChosen, ".jpg"));
                                    imageDateTaken = GetDateTakenFromImage(imageChosenPath);
                                }
                            }
                            else
                            {
                                Console.WriteLine("No matching image was found.");
                                fileWriter.WriteLine(string.Join(",", UpdateStatus.N_NO_IMAGE, name, country, brewer, type, style, source, abv, rating, imageCandidates, imageChosen, notes));
                                continue;
                            }

                            type = currentRow[typeIndex];
                            if (string.IsNullOrWhiteSpace(type))
                            {
                                Console.WriteLine("No vessel type specified.");
                                fileWriter.WriteLine(string.Join(",", UpdateStatus.N_NO_TYPE, name, country, brewer, type, style, source, abv, rating, imageCandidates, imageChosen, notes));
                                continue;
                            }

                            brewer = currentRow[brewerIndex];
                            if (string.IsNullOrWhiteSpace(brewer))
                            {
                                Console.WriteLine("No brewer specified.");
                                status = UpdateStatus.Y_NO_BREWER;
                            }

                            if (!decimal.TryParse(currentRow[abvIndex], out abv))
                            {
                                Console.WriteLine("No ABV given.");
                                if (!status.HasValue)
                                {
                                    status = UpdateStatus.Y_NO_ABV;
                                }
                            }

                            if (!short.TryParse(currentRow[ratingIndex], out rating))
                            {
                                Console.WriteLine("No rating given.");
                                if (!status.HasValue)
                                {
                                    status = UpdateStatus.Y_NO_RATING;
                                }
                            }

                            style = currentRow[styleIndex];
                            source = currentRow[sourceIndex];
                            if (string.IsNullOrWhiteSpace(style) || string.IsNullOrWhiteSpace(source))
                            {
                                Console.WriteLine("Not all fields were specified.");
                                if (!status.HasValue)
                                {
                                    status = UpdateStatus.Y_INCOMPLETE;
                                }
                            }

                            Console.WriteLine("Proceeding to upload beer to CMS..");
                            var beerId = UploadBeer(name, brewer, country, notes, rating, imageId, imageDateTaken, contentService, updateExisting, ref status);
                            if (beerId >= 0)
                            {
                                if (status == UpdateStatus.N_EXISTS)
                                {
                                    Console.WriteLine("Beer already exists - no update.");
                                    fileWriter.WriteLine(string.Join(",", UpdateStatus.N_EXISTS, name, country, brewer, type, style, source, abv, rating, imageCandidates, imageChosen, notes));
                                } 
                                else
                                {
                                    Console.WriteLine("Beer successfully updated.");
                                    fileWriter.WriteLine(string.Join(",", status ?? UpdateStatus.Y_COMPLETE, name, country, brewer, type, style, source, abv, rating, imageCandidates, imageChosen, notes));
                                }
                            }
                            else
                            {
                                if (status == UpdateStatus.N_NO_COUNTRY)
                                {
                                    Console.WriteLine("Country " + country + " not found in CMS.");
                                    fileWriter.WriteLine(string.Join(",", UpdateStatus.N_NO_COUNTRY, name, country, brewer, type, style, source, abv, rating, imageCandidates, imageChosen, notes));
                                }
                                else
                                {
                                    Console.WriteLine("Couldn't update beer.");
                                    fileWriter.WriteLine(string.Join(",", UpdateStatus.N_UPLOAD_ERROR, name, country, brewer, type, style, source, abv, rating, imageCandidates, imageChosen, notes));
                                }
                            }
                            Console.WriteLine();

                            if (name.Equals(beerName, StringComparison.CurrentCultureIgnoreCase))
                            {
                                return; // Updated the specified beer so exit
                            }
                        }
                    }
                }
            }
        }

        private static void UpdateMissingImage(IContentTypeService contentTypeService, IContentService contentService, IMediaService mediaService, string beerName = null)
        {
            var beersMissingImages = new SortedList<string, string>();
            var beerContentType = contentTypeService.GetContentType("Beer");
            foreach (var beer in contentService.GetContentOfContentType(beerContentType.Id))
            {
                if (beerName == null || beer.Name == beerName)
                {
                    var mediaId = beer.Properties["image"].Value;
                    if (mediaId != null)
                    {
                        var media = mediaService.GetById(Convert.ToInt32(mediaId));
                        if (media != null)
                        {
                            var mediaFilePath = media.Properties["umbracoFile"].Value;
                            if (mediaFilePath != null && System.IO.File.Exists(mediaFilePath.ToString()))
                            {
                                Console.WriteLine("Beer " + beer.Name + " appears to have an image associated.");
                                if (beer.Name == beerName)
                                {
                                    return;
                                }
                                if (beerName == null)
                                {
                                    continue;
                                }
                            }
                        }
                    }

                    Console.WriteLine("Beer " + beer.Name + " is missing image. Trying to update..");
                    var country = beer.Parent();
                    if (country == null)
                    {
                        Console.WriteLine("Country for beer " + beer.Name + " not found.");
                        if (beer.Name == beerName)
                        {
                            return;
                        }
                        if (beerName == null)
                        {
                            continue;
                        }
                    }

                    var countryName = country.Name;
                    string candidates = null;
                    var imageChosen = FindImage(beer.Name, countryName, out candidates);

                    if (!string.IsNullOrWhiteSpace(imageChosen))
                    {
                        Console.WriteLine("Uploading image: " + imageChosen + "..");
                        var imageId = UploadImage(imageChosen, countryName, true, mediaService);
                        if (imageId >= 0)
                        {
                            var imageChosenPath = Path.Combine(BeerImagesRootDirectory, countryName, Path.ChangeExtension(imageChosen, ".jpg"));
                            var imageDate = GetDateTakenFromImage(imageChosenPath);
                            var beerImageDate = beer.Properties["imageDate"].Value;
                            Console.WriteLine("Image date taken: " + imageDate);
                            Console.WriteLine("Date in CMS: " + beerImageDate ?? "Unspecified");
                            if (imageDate != DateTime.MinValue && (beerImageDate == null || Convert.ToDateTime(beerImageDate) != imageDate))
                            {
                                beer.Properties["imageDate"].Value = imageDate;
                                Console.WriteLine("Image date updated in CMS.");
                            }

                            beer.Properties["image"].Value = imageId;
                            contentService.Save(beer);
                            Console.WriteLine("Saved beer with updated image.");
                        }
                    }
                    else
                    {
                        Console.WriteLine("No matching image was found.");
                        beersMissingImages.Add(beer.Name, beer.Name);
                    }
                }          
            }

            using (var fileWriter = new StreamWriter(string.Format("{0}_{1}.csv",
                    Path.Combine(ConfigurationManager.AppSettings["BeerFileDirectory"], "Beers_Missing_Images"),
                    DateTime.Now.ToString("yyyyMMddhhmmss"))))
            {
                foreach (var beer in beersMissingImages.Keys)
                {
                    fileWriter.WriteLine(beer);
                }
            }
        }

        // Take media image associated with beer(s) and update the image taken date from the file if exists.
        private static void UpdateBeerImageDate(IContentTypeService contentTypeService, IContentService contentService, IMediaService mediaService, string beerName = null)
        {
            var beerContentType = contentTypeService.GetContentType("Beer");
            foreach (var beer in contentService.GetContentOfContentType(beerContentType.Id))
            {
                if (beerName == null || beer.Name == beerName)
                {
                    Console.WriteLine();
                    Console.WriteLine("Updating image date for " + beer.Name + "..");

                    var country = beer.Parent();
                    if (country == null)
                    {
                        Console.WriteLine("Parent node not found.");
                        continue;
                    }

                    var mediaId = beer.Properties["image"].Value;
                    if (mediaId == null)
                    {
                        Console.WriteLine("No image associated with beer.");
                        continue;
                    }

                    var media = mediaService.GetById(Convert.ToInt32(mediaId));
                    if (media == null)
                    {
                        Console.WriteLine("Image media of id " + mediaId + " is missing.");
                        continue;
                    }

                    var mediaFilePath = media.Properties["umbracoFile"].Value;
                    if (mediaFilePath == null)
                    {
                        Console.WriteLine("Image media path is missing.");
                        continue;
                    }

                    var imageFileName = Path.GetFileName(mediaFilePath.ToString());
                    var imageFilePath = Path.Combine(BeerImagesRootDirectory, country.Name, imageFileName);
                    if (!System.IO.File.Exists(imageFilePath))
                    {
                        Console.WriteLine("Image file " + imageFilePath + " doesn't exist.");
                        continue;
                    }

                    var imageDate = GetDateTakenFromImage(imageFilePath);
                    var beerImageDate = beer.Properties["imageDate"].Value;
                    Console.WriteLine("Image date taken: " + imageDate);
                    Console.WriteLine("Date in CMS: " + beerImageDate ?? "Unspecified");
                    if (imageDate != DateTime.MinValue && (beerImageDate == null || Convert.ToDateTime(beerImageDate) != imageDate))
                    {
                        beer.Properties["imageDate"].Value = imageDate;
                        contentService.Save(beer);
                        Console.WriteLine("Image date updated in CMS.");
                    }
                }
            }
        }

        private static void DeleteMedia(IMediaService mediaService)
        {
            var beerMediaRoot = mediaService.GetRootMedia().SingleOrDefault(x => x.Name == "Beers");
            if (beerMediaRoot == null)
            {
                Console.WriteLine("Couldn't find media folder with name \"Beers\".");
                return;
            }

            foreach (var countryMediaParent in mediaService.GetChildren(beerMediaRoot.Id))
            {
                Console.WriteLine("Deleting media for " + countryMediaParent.Name + "..");
                foreach (var beerImageMedia in mediaService.GetChildren(countryMediaParent.Id))
                {
                    Console.WriteLine("Deleting media: " + beerImageMedia.Name + "..");
                    mediaService.Delete(beerImageMedia);
                }
            }
        }            

        private static string FindImage(string beerName, string country, out string candidates)
        {
            var imageDirectory = BeerImagesRootDirectory;
            var imageCountryPath = Path.Combine(imageDirectory, country);
            if (!Directory.Exists(imageCountryPath))
            {
                Console.WriteLine("Images folder " + imageCountryPath + " doesn't exist.");
                candidates = null;
                return null;
            }

            var possibleMatches = new SortedDictionary<int, List<string>>();
            foreach (var filePath in Directory.GetFiles(imageCountryPath))
            {
                var fileName = Path.GetFileNameWithoutExtension(filePath);
                var beerNameMatchArray = beerName.ToLower().Split(' ', '-', '/', '\\', '\'');
                var fileNameMatchArray = fileName.ToLower().Split(' ', '-', '/', '\\', '\'');
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
            candidates = string.Join(";", possibleMatches.SelectMany(x => x.Value));
            return possibleMatches.Count() > 0 ? possibleMatches.First().Value[0] : null;
        }

        private static int UploadImage(string imageName, string country, bool overwriteExisting, IMediaService mediaService)
        {
            var imageDirectory = BeerImagesRootDirectory;
            var imageFileName = Path.ChangeExtension(imageName, ".jpg");
            var imagePath = Path.Combine(imageDirectory, country, imageFileName);
            if (!System.IO.File.Exists(imagePath))
            {
                Console.WriteLine("Image file " + imagePath + " doesn't exist.");
                return -1;
            }

            using (var fileStream = new FileStream(imagePath, FileMode.Open))
            {
                var beerMediaRoot = mediaService.GetRootMedia().SingleOrDefault(x => x.Name == "Beers");
                if (beerMediaRoot == null)
                {
                    Console.WriteLine("Couldn't find media folder with name \"Beers\".");
                    return -1;
                }

                var countryMediaParent = mediaService.GetChildren(beerMediaRoot.Id).SingleOrDefault(x => x.Name == country);
                if (countryMediaParent == null)
                {
                    Console.WriteLine("Couldn't find media folder with name " + country + ".");
                    return -1;
                }

                // Check existence of media
                var existingMedia = mediaService.GetChildren(countryMediaParent.Id).SingleOrDefault(x => x.Name.Equals(imageFileName, StringComparison.CurrentCultureIgnoreCase));
                if (existingMedia != null)
                {
                    Console.WriteLine("Image media " + imageFileName + " already exists.");
                    if (overwriteExisting)
                    {
                        mediaService.Delete(existingMedia);
                        Console.WriteLine("Replacing image media..");
                    }
                    else
                    {
                        return existingMedia.Id;
                    }                    
                }

                var image = mediaService.CreateMedia(imageFileName, countryMediaParent, "Image");
                image.SetValue("umbracoFile", Path.GetFileName(fileStream.Name), fileStream);
                mediaService.Save(image);
                return image.Id;
            }
        }

        private static int UploadBeer(string name, string brewer, string country, string notes, short rating, int imageId, DateTime imageDateTaken, IContentService contentService, bool updateExisting, ref UpdateStatus? status)
        {
            var rootContent = contentService.GetRootContent().SingleOrDefault();
            var beersRoot = contentService.GetChildren(rootContent.Id).SingleOrDefault(x => x.Name == "Beer Reviews");
            if (beersRoot == null)
            {
                Console.WriteLine("Couldn't find node with name \"Beer Reviews\".");
                status = UpdateStatus.N_UPLOAD_ERROR;
                return -1;
            }

            var countryItem = contentService.GetChildren(beersRoot.Id).SingleOrDefault(x => x.Name == country);
            if (countryItem == null)
            {
                Console.WriteLine("Couldn't find country node with name " + country + ".");
                status = UpdateStatus.N_NO_COUNTRY;
                return -1;
            }

            IContent beerToUpdate = null;

            // Check existence of content
            beerToUpdate = contentService.GetChildren(countryItem.Id).SingleOrDefault(x => x.Name.Equals(name, StringComparison.CurrentCultureIgnoreCase));
            if (beerToUpdate == null)
            {
                beerToUpdate = contentService.CreateContent(name, countryItem.Id, "Beer");
            }
            else
            {
                Console.WriteLine("Beer " + name + " already exists.");
                if (!updateExisting)
                {
                    status = UpdateStatus.N_EXISTS;
                    return beerToUpdate.Id;
                }
            }

            var newNotes = notes.Trim('"', ',');
            beerToUpdate.Properties["fullName"].Value = name;
            beerToUpdate.Properties["brewer"].Value = brewer;
            beerToUpdate.Properties["image"].Value = imageId;
            beerToUpdate.Properties["imageDate"].Value = imageDateTaken;
            beerToUpdate.Properties["review"].Value = newNotes;            
            beerToUpdate.Properties["rating"].Value = rating;

            //Save the Content
            contentService.Save(beerToUpdate);
            return beerToUpdate.Id;
        }

        private static DateTime GetDateTakenFromImage(string path)
        {
            try
            {
                using (FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read))
                {
                    using (Image myImage = Image.FromStream(fs, false, false))
                    {
                        PropertyItem propItem = myImage.GetPropertyItem(36867);
                        string dateTakenText = _dateTakenRegex.Replace(Encoding.UTF8.GetString(propItem.Value), "-", 2);
                        DateTime dateTaken;
                        DateTime.TryParse(dateTakenText, out dateTaken);
                        return dateTaken;
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine("Error when getting date taken from image: " + e.Message);
                return DateTime.MinValue;
            }
        }
    }
}