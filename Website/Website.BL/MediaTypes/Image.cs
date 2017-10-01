using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using Slimsy;
using Umbraco.Core.Models;
using Website.BL.DocumentTypes;

namespace Website.BL.MediaTypes
{
    public class Image : Base
    {
        public Image(IPublishedContent content) : base(content)
        {            
        }
    }
}
