using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Slimsy;
using Umbraco.Core.Models;
using Umbraco.Web;
using Website.BL.Extensions;
using Website.BL.MediaTypes;

namespace Website.BL.DocumentTypes
{
    public class Beer : Base
    {
        public string BeerName { get { return Content.GetProperty<string>("name"); } }
        public string CountryOfOrigin { get { return Content.Parent<Country>().Name; } }
        public string Style { get { return Content.GetProperty<string>("style"); } }
        public int Abv { get { return Content.GetProperty<int>("abv"); } }
        public string Brewer { get { return Content.GetProperty<string>("brewer"); } }
        public string Type { get { return Content.GetProperty<string>("type"); } }
        public string Source { get { return Content.GetProperty<string>("source"); } }
        public DateTime ImageDate { get { return Content.GetProperty<DateTime>("imageDate"); } }

        public string ImageDateDisplay
        {
            get
            {
                return ImageDate > DateTime.MinValue ? ImageDate.ToString("dd/MM/yyyy") : "--/--/----";
            }
        }

        public DateTime LastTastedDate
        {
            get
            {
                var lastTasted = Content.GetProperty<DateTime>("lastTastedDate");
                return lastTasted > DateTime.MinValue ? lastTasted : ImageDate;
            }
        }

        public string LastTastedDateDisplay
        {
            get
            {
                return LastTastedDate > DateTime.MinValue ? LastTastedDate.ToString("dd/MM/yyyy") : "--/--/----";
            }
        }

        public string Review { get { return Content.GetProperty<string>("review"); } }
        public int Rating { get { return Content.GetProperty<int>("rating"); } }

        public string RatingDisplay
        {
            get
            {
                var rating = Content.GetProperty<int>("rating");
                return rating > 0 ? rating.ToString() + "/10" : "Unrated";
            }
        }

        public Beer(IPublishedContent content) : base(content)
        {
        }

        public string GetImageUrl(UmbracoHelper umbraco, bool small = false)
        {
            var image = Content.GetProperty<Image>("image");
            //return image?.Url.GetCropUrl(600, imageCropMode: Umbraco.Web.Models.ImageCropMode.Crop);
            return image?.GetResponsiveImageUrl(600, 0);
        }

        public string GetCountryFlag(UmbracoHelper umbraco)
        {
            return Content.Parent<Country>().GetFlagImageUrl(umbraco);
        }
    }
}