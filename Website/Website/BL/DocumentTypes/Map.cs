using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Umbraco.Core.Models;

namespace Website.UI.BL.DocumentTypes
{
    public class Map : Page
    {
        public Map(IPublishedContent content) : base(content)
        {
        }
    }
}