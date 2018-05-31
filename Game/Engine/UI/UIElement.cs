using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Game.Engine
{
    class UIElement : Drawable
    {
        public UIElement(string ElementPath, ref DrawWindow WindowHandle) : base(ElementPath)
        {
            this.WindowHandle = WindowHandle;
        }

        public bool HasBeenInteractedWith
        {
            get;
            protected set;
        }

        protected DrawWindow WindowHandle
        {
            get;
            set;
        }
    }
}
