using System.Collections.Generic;
using Umbraco.Core.Models;
using Umbraco.Web;

namespace Website.UI.BL.DocumentTypes
{
    public class Listing : Page
    {
        public IEnumerable<Beer> Beers
        {
            get
            {
                var beers = new List<Beer>();
                foreach (var beer in Content.Descendants<Beer>())
                {
                    beers.Add(beer);
                }
                return beers;
            }
        }

        public Listing(IPublishedContent content) : base(content)
        {
        }
    }
}