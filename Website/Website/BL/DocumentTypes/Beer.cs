using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Umbraco.Core.Models;
using Umbraco.Web;
using Website.Extensions;

namespace Website.UI.BL.DocumentTypes
{
    public class Beer : Base
    {
        public string FullName { get { return Content.GetProperty<string>("fullName"); } }
        public string Brewer { get { return Content.GetProperty<string>("brewer"); } }
        public string CountryOfOrigin { get { return Content.Parent<Country>().Name; } }
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

        public string GetImageUrl(UmbracoHelper umbraco)
        {
            var mediaId = Content.GetProperty<int>("image");
            if (mediaId == 0)
            {
                return null;
            }
            var media = umbraco.TypedMedia(mediaId);
            return media != null ? media.Url : null;
        }

        public string GetCountryFlag(UmbracoHelper umbraco)
        {
            return Content.Parent<Country>().GetFlagImageUrl(umbraco);
        }
    }
}