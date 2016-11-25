using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Website.ContentAdmin
{
    public enum Command { Unknown, LoadBeerData, UpdateMissingImages, RefreshImageDate, DeleteMedia }

    class CommandSettings
    {
        private string[] _args;

        public Command Command
        {
            get
            {
                Command command;
                Enum.TryParse(_args[0], out command);
                return command;
            }
        }
                
        public bool UpdateExisting { get { return _args[1] == "true"; } }
        public string BeerFile { get { return _args.Length > 2 ? _args[2] : null; } }

        public string BeerName
        {
            get
            {
                return Command == Command.LoadBeerData && _args.Length > 3 ? _args[3] : (_args.Length > 1 ? _args[1] : null);                
            }
        }

        public CommandSettings(string[] args)
        {
            _args = args;
        }        
    }
}
