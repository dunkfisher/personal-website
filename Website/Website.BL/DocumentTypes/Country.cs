using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Umbraco.Core.Models;
using Umbraco.Web;
using Umbraco.Core.Models.PublishedContent;
using Website.BL.Extensions;
using Website.BL.MediaTypes;

namespace Website.BL.DocumentTypes
{
    public class Country : PublishedContentModel
    {
        //public string Name { get { return Content.Name; } }

        public Country(IPublishedContent content) : base(content)
        {
        }

        public string GetFlagImageUrl(UmbracoHelper umbraco)
        {
            var image = Content.GetProperty<Image>("flag");
            return image.Url;
        }
    }
}