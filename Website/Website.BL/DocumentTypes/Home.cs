using Umbraco.Core.Models;
using Website.BL.Extensions;

namespace Website.BL.DocumentTypes
{
    public class Home : Page
    {
        public string HeadingPart1 { get { return Content.GetProperty<string>("headingPart1"); } }
        public string HeadingPart2 { get { return Content.GetProperty<string>("headingPart2"); } }
        public string HeadingPart3 { get { return Content.GetProperty<string>("headingPart3"); } }

        public Home(IPublishedContent content) : base(content)
        {            
        }
    }
}