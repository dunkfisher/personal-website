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
        public bool UpdateNotes { get { return _args[2] == "true"; } }
        public bool OverwriteImage { get { return _args[3] == "true"; } }
        public string BeerFile { get { return _args.Length > 4 ? _args[4] : null; } }

        public string BeerName
        {
            get
            {
                return Command == Command.LoadBeerData && _args.Length > 5 ? _args[5] : (_args.Length > 1 ? _args[1] : null);                
            }
        }

        public CommandSettings(string[] args)
        {
            _args = args;
        }        
    }
}
