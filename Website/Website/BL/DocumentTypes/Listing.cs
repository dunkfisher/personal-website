using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Umbraco.Core.Models;

namespace Website.UI.BL.DocumentTypes
{
    public class Listing : Page
    {
        public Listing(IPublishedContent content) : base(content)
        {
        }    
    }
}