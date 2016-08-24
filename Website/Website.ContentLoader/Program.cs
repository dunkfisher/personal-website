using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Website.ContentLoader
{
    class Program
    {
        static void Main(string[] args)
        {
            // arg[0] is file path
            // open file (csv)
            // for each row
            //    load fields
            //    if image not specified
            //        for each image in Country folder
            //            perform match against name (intersect)
            //            if any match
            //                add to match collection
            //    load image file name (best match)
            //    load tasted date as image date taken
            //    write to output file with image match list and chosen image
            //    if not beer exists in Umbraco (name)
            //        call Umbraco to add content     
            //    else
            //        call Umbraco to update content 
        }
    }
}
