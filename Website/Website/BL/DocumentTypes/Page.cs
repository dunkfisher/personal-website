using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Umbraco.Core.Models;

namespace Website.UI.BL.DocumentTypes
{
    public class Page : Base
    {
        public string Title { get { return Content.GetProperty("pageTitle").Value.ToString(); } }

        public Page(IPublishedContent content) : base(content)
        {
        }
    }
}
