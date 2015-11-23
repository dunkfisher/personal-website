using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Umbraco.Core.Models;

namespace Website.UI.BL.DocumentTypes
{
    public class Faq : Page
    {
        public Faq(IPublishedContent content) : base(content)
        {
        }
    }
}