using System.Collections.Generic;
using System.Linq;
using Umbraco.Core.Models;
using Umbraco.Web;

namespace Website.UI.BL.DocumentTypes
{
    public class Listing : Page
    {
        //private string _countryFilter;

        //public IEnumerable<Beer> Beers
        //{            
        //    get
        //    {
        //        var beers = new List<Beer>();
        //        foreach (var beer in Content.Descendants<Beer>().Where(x => _countryFilter == null || x.CountryOfOrigin == _countryFilter).OrderByDescending(x => x.ImageDate))
        //        {
        //            beers.Add(beer);
        //        }
        //        return beers;
        //    }
        //}

        public Listing(IPublishedContent content) : base(content)
        {
        }

        //public void ApplyFilter(string country)
        //{
        //    _countryFilter = country;
        //}
    }
}