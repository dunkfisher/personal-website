using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Website.Models
{
    public class FilterViewModel
    {
        public IEnumerable<string> Countries { get; set; }
        public IEnumerable<string> Brewers { get; set; }
    }
}