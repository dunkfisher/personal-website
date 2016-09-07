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
        //[HttpPost]                
        public PartialViewResult ListBeers(string country)
        {
            var beers = Umbraco.TypedContentAtXPath(string.Format("//Country[@nodeName=\"{0}\"]/Beer", country))
                .OfType<Beer>()
                .OrderByDescending(x => x.ImageDate);
                        
            ViewBag.Umbraco = Umbraco; // TODO: Refactor
            return PartialView("_ListItems", beers);
        }

        //[ChildActionOnly]
        //public ActionResult Filter()
        //{
        //    return View("_Filter");
        //}

        //[ChildActionOnly]
        //public ActionResult ListItems(string country)
        //{
        //    var currentPage = CurrentPage as Listing;
        //    if (!string.IsNullOrEmpty(country))
        //    {
        //        currentPage.ApplyFilter(country);
        //    }
        //    return View("_ListItems", CurrentPage as Listing);
        //}
    }
}