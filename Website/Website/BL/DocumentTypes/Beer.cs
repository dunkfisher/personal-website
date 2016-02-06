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

        public DateTime LastTastedDate
        {
            get
            {
                var lastTasted = Content.GetProperty<DateTime>("lastTastedDate");
                return lastTasted > DateTime.MinValue ? lastTasted : ImageDate;
            }
        }

        public string Review { get { return Content.GetProperty<string>("review"); } }
        public int Rating { get { return Content.GetProperty<int>("rating"); } }

        public Beer(IPublishedContent content) : base(content)
        {
        }

        public string GetImageUrl(UmbracoHelper umbraco)
        {
            var mediaId = Content.GetProperty<int>("image");
            return umbraco.TypedMedia(mediaId).Url;
        }

        public string GetCountryFlag(UmbracoHelper umbraco)
        {
            return Content.Parent<Country>().GetFlagImageUrl(umbraco);
        }
    }
}