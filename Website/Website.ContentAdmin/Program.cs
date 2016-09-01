using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlServerCe;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Security.Policy;
using Umbraco.Core;
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
        static void Main(string[] args)
        {
            RunUmbraco();

            //var umbracoDomain = AppDomain.CreateDomain(
            //    "Umbraco",
            //    new Evidence(),
            //    new AppDomainSetup
            //    {
            //        ApplicationBase = Environment.CurrentDirectory,
            //        PrivateBinPath = Path.Combine(Environment.CurrentDirectory, "bin"),
            //        ConfigurationFile = Path.Combine(Environment.CurrentDirectory, "web.config")
            //    }
            //);
            //umbracoDomain.SetData("args", args);

            //umbracoDomain.DoCallBack(RunUmbraco);
        }

        private static void RunUmbraco()
        {
            Console.Title = "Umbraco Console";

            var umbracoAccess = new ServiceAccess();

            //Initialize the application
            //var application = new ConsoleApplicationBase();
            //application.Start(application, new EventArgs());
            //Console.WriteLine("Application Started");

            //Console.WriteLine("--------------------");
            ////Write status for ApplicationContext
            //var context = ApplicationContext.Current;
            //Console.WriteLine("ApplicationContext is available: " + (context != null).ToString());
            ////Write status for DatabaseContext
            //var databaseContext = context.DatabaseContext;
            //Console.WriteLine("DatabaseContext is available: " + (databaseContext != null).ToString());
            ////Write status for Database object
            //var database = databaseContext.Database;
            //Console.WriteLine("Database is available: " + (database != null).ToString());
            //Console.WriteLine("--------------------");

            //Get the ServiceContext and the two services we are going to use
            //var serviceContext = context.Services;
            //var contentService = serviceContext.ContentService;
            //var contentTypeService = serviceContext.ContentTypeService;

            //Exit the application?
            var waitOrBreak = true;
            while (waitOrBreak)
            {
                //List options
                Console.WriteLine("-- Options --");
                Console.WriteLine("List content nodes: l");
                Console.WriteLine("Create new content: c");
                //Console.WriteLine("Create Umbraco database schema in empty db: d");
                Console.WriteLine("Quit application: q");

                var input = Console.ReadLine();
                if (string.IsNullOrEmpty(input) == false && input.ToLowerInvariant().Equals("q"))
                    waitOrBreak = false;//Quit the application
                else if (string.IsNullOrEmpty(input) == false && input.ToLowerInvariant().Equals("l"))
                    ListContentNodes(umbracoAccess.Services.ContentService);//Call the method that lists all the content nodes
                else if (string.IsNullOrEmpty(input) == false && input.ToLowerInvariant().Equals("c"))
                    CreateNewContent(umbracoAccess.Services.ContentService, umbracoAccess.Services.ContentTypeService);//Call the method that does the actual creation and saving of the Content object
                //else if (string.IsNullOrEmpty(input) == false && input.ToLowerInvariant().Equals("d"))
                //    CreateDatabaseSchema(database, databaseContext.DatabaseProvider, application.DataDirectory);
            }
        }

        /// <summary>
        /// Private method to list all content nodes
        /// </summary>
        /// <param name="contentService"></param>
        private static void ListContentNodes(IContentService contentService)
        {
            //Get the Root Content
            var rootContent = contentService.GetRootContent();
            foreach (var content in rootContent)
            {
                Console.WriteLine("Root Content: " + content.Name + ", Id: " + content.Id);
                //Get Descendants of the current content and write it to the console ordered by level
                var descendants = contentService.GetDescendants(content);
                foreach (var descendant in descendants.OrderBy(x => x.Level))
                {
                    Console.WriteLine("Name: " + descendant.Name + ", Id: " + descendant.Id + " - Parent Id: " + descendant.ParentId);
                }
            }
        }

        private static void UploadBeersFromFile(IContentService contentService)
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

            Console.WriteLine("Please enter the path of the input file:");
            var inputFilePath = Console.ReadLine();
            // TODO: check file exists
            using (var fileReader = new StreamReader(inputFilePath))
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
                    }
                    name = currentRow[nameIndex];
                    country = currentRow[countryIndex];
                    brewer = currentRow[brewerIndex];
                    notes = currentRow[notesIndex];
                    ratingIndex = short.Parse(currentRow[ratingIndex]); // TODO: TryParse
                    imageCandidates = currentRow[imageCandidateIndex];
                    imageChosen = currentRow[imageChosenIndex];
                    
                    if (string.IsNullOrWhiteSpace(imageChosen))
                    {
                        imageChosen = FindImage(name, country, out imageCandidates);       
                    }
                    //    load tasted date as image date taken
                    //    write to output file with image match list and chosen image
                    //    if not beer exists in Umbraco (name)
                    //        call Umbraco to add content     
                    //    else
                    //        call Umbraco to update content
                }
            }
        }

        /// <summary>
        /// Private method to create new content
        /// </summary>
        /// <param name="contentService"></param>
        /// <param name="contentTypeService"></param>
        private static void CreateNewContent(IContentService contentService, IContentTypeService contentTypeService)
        {
            //We find all ContentTypes so we can show a nice list of everything that is available
            //var contentTypes = contentTypeService.GetAllContentTypes();
            //var contentTypeAliases = string.Join(", ", contentTypes.Select(x => x.Alias));

            //Console.WriteLine("Please enter the Alias of the ContentType ({0}):", contentTypeAliases);
            Console.WriteLine("Please enter the Alias of the ContentType (Beer):");
            var contentTypeAlias = Console.ReadLine();

            Console.WriteLine("Please enter the Id of the Parent:");
            var strParentId = Console.ReadLine();
            int parentId;
            if (int.TryParse(strParentId, out parentId) == false)
                parentId = -1;//Default to -1 which is the root

            Console.WriteLine("Please enter the name of the Content to create:");
            var name = Console.ReadLine();

            //Create the Content
            var content = contentService.CreateContent(name, parentId, contentTypeAlias);
            foreach (var property in content.Properties)
            {
                Console.WriteLine("Please enter the value for the Property with Alias '{0}':", property.Alias);
                var value = Console.ReadLine();
                var isValid = property.IsValid(value);
                if (isValid)
                {
                    property.Value = value;
                }
                else
                {
                    Console.WriteLine("The entered value was not valid and thus not saved");
                }
            }

            //Save the Content
            contentService.SaveAndPublishWithStatus(content);

            Console.WriteLine("Content was saved: " + content.HasIdentity);
        }  

        private static string FindImage(string beerName, string country, out string candidates)
        {                        
            var imageDirectory = ConfigurationManager.AppSettings["BeerImagesRootDirectory"];
            var possibleMatches = new SortedDictionary<int, string>();
            foreach (var fileName in Directory.GetFiles(Path.Combine(imageDirectory, country)))
            {
                var beerNameMatchArray = beerName.ToLower().Split(' ');
                var fileNameMatchArray = Path.GetFileNameWithoutExtension(fileName).ToLower().Split('-');
                var matchStrength = beerNameMatchArray.Intersect(fileNameMatchArray).Count();
                if (matchStrength > 0)
                {
                    possibleMatches.Add(matchStrength, fileName);
                }                
            }
            candidates = string.Join(",", possibleMatches.Select(x => x.Value));
            return possibleMatches.Count() > 0 ? possibleMatches.Last().Value : null;
        }
    }
}