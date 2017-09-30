using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Umbraco.Core.Models;
using Umbraco.Core.Models.PublishedContent;

namespace Website.BL.DocumentTypes
{
    public class Base : PublishedContentModel
    {
        //protected IPublishedContent Content;

        public Base(IPublishedContent content) : base(content)
        {
            //Content = content;
        }
    }
}
