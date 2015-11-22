using Umbraco.Core.Models;

namespace Website.UI.BL.DocumentTypes
{
    public class Home : Page
    {
        public string HeadingPart1 { get { return Content.GetProperty("headingPart1").Value.ToString(); } }
        public string HeadingPart2 { get { return Content.GetProperty("headingPart2").Value.ToString(); } }
        public string HeadingPart3 { get { return Content.GetProperty("headingPart3").Value.ToString(); } }

        public Home(IPublishedContent content) : base(content)
        {            
        }
    }
}