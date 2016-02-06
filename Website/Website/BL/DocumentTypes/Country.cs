using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Umbraco.Core.Models;
using Umbraco.Web;
using Umbraco.Core.Models.PublishedContent;
using Website.Extensions;

namespace Website.UI.BL.DocumentTypes
{
    public class Country : PublishedContentModel
    {
        //public string Name { get { return Content.Name; } }

        public Country(IPublishedContent content) : base(content)
        {
        }

        public string GetFlagImageUrl(UmbracoHelper umbraco)
        {
            var mediaId = Content.GetProperty<int>("flag");
            return umbraco.TypedMedia(mediaId).Url;
        }
    }
}