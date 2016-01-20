using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Umbraco.Core.Models;
using Umbraco.Web;
using Website.Extensions;

namespace Website.UI.BL.DocumentTypes
{
    public class Page : Base
    {
        public string Title { get { return Content.GetProperty<string>("pageTitle"); } }
        public bool HasBackgroundImage
        {
            get { return Content.HasProperty("backgroundImage") && Content.GetProperty("backgroundImage").HasValue; }
        }

        public Page(IPublishedContent content) : base(content)
        {
        }

        public string GetBackGroundImageUrl(UmbracoHelper umbraco)
        {
            var mediaId = Content.GetProperty<int>("backgroundImage");
            return umbraco.TypedMedia(mediaId).Url;
        }
    }
}
