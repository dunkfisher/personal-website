using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Umbraco.Web.Mvc;
using Website.BL.DocumentTypes;
using Website.Models;

namespace Website.Controllers
{
    public class ListingController : SurfaceController
    {
        [ChildActionOnly]
        public PartialViewResult Filter()
        {
            var countries = Umbraco.TypedContentAtXPath("//Country")
                .Select(x => x.Name)
                .OrderBy(x => x)
                .ToList();
            countries.Insert(0, string.Empty);

            var brewers = Umbraco.TypedContentAtXPath("//Country/Beer")
                .OfType<Beer>()
                .Where(x => !string.IsNullOrWhiteSpace(x.Brewer))
                .Select(x => x.Brewer)
                .Distinct()
                .OrderBy(x => x)
                .ToList();
            brewers.Insert(0, string.Empty);
                            
            return PartialView("_Filter", new FilterViewModel { Countries = countries, Brewers = brewers });
        }

        [HttpPost]
        public PartialViewResult Filter(string country,
            string brewer,
            decimal? abvFrom,
            decimal? abvTo,
            int? ratingFrom,
            int? ratingTo,
            DateTime? dateFrom,
            DateTime? dateTo)
        {
            var beerXPath = !string.IsNullOrWhiteSpace(country) ? $"//Country[@nodeName=\"{country}\"]/Beer" : "//Country/Beer";

            var beers = Umbraco.TypedContentAtXPath(beerXPath)
                .OfType<Beer>();                
                
            if (!string.IsNullOrWhiteSpace(brewer))
            {
                beers = beers.Where(x => x.Brewer == brewer);
            }

            if (abvFrom.HasValue || abvTo.HasValue)
            {
                beers = beers.Where(x => x.Abv >= (abvFrom ?? 0) && x.Abv <= (abvTo ?? 0));
            }

            if (ratingFrom.HasValue || ratingTo.HasValue)
            {
                beers = beers.Where(x => x.Rating >= (ratingFrom ?? 0) && x.Rating <= (ratingTo ?? 0));
            }

            if (dateFrom.HasValue || dateTo.HasValue)
            {
                beers = beers.Where(x => x.LastTastedDate >= (dateFrom ?? DateTime.MinValue) && x.LastTastedDate <= (dateTo ?? DateTime.MaxValue));
            }

            ViewBag.Umbraco = Umbraco; // TODO: Refactor
            return PartialView("_ListItems", beers.OrderByDescending(x => x.ImageDate));
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