using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Website.ContentAdmin
{
    enum UpdateStatus
    {
        N_EXISTS,        
        N_NO_COUNTRY,
        N_NO_IMAGE,
        N_NO_TYPE,
        Y_NO_BREWER,
        Y_NO_ABV,
        Y_NO_RATING,
        Y_INCOMPLETE
    }
}
