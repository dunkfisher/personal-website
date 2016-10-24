using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Umbraco.Web.Mvc;
using Website.UI.BL.DocumentTypes;

namespace Website.Controllers
{
    public class ListingController : SurfaceController
    {
        [ChildActionOnly]
        public PartialViewResult CountryFilter()
        {
            var countries = Umbraco.TypedContentAtXPath("//Country")
                .Select(x => x.Name)
                .OrderBy(x => x);
            return PartialView("_CountryFilter", countries);
        }

        [HttpPost]
        public PartialViewResult Filter(string country)
        {
            var beers = Umbraco.TypedContentAtXPath(string.Format("//Country[@nodeName=\"{0}\"]/Beer", country))
                .OfType<Beer>()
                .OrderByDescending(x => x.ImageDate);
                        
            ViewBag.Umbraco = Umbraco; // TODO: Refactor
            return PartialView("_ListItems", beers);
        }

        [HttpPost]
        public PartialViewResult Search(string searchTerm)
        {
            var beers = Umbraco.TypedSearch(searchTerm)
                .OfType<Beer>()
                .OrderByDescending(x => x.ImageDate);

            ViewBag.Umbraco = Umbraco; // TODO: Refactor
            return PartialView("_ListItems", beers);
        }
    }
}