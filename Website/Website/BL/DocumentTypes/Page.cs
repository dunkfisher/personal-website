using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Umbraco.Core.Models;
using Website.Extensions;

namespace Website.UI.BL.DocumentTypes
{
    public class Page : Base
    {
        public string Title { get { return Content.GetProperty<string>("pageTitle"); } }

        public Page(IPublishedContent content) : base(content)
        {
        }
    }
}
