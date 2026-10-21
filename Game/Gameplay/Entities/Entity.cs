using System;
using System.Reflection;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Game.Engine;

namespace Game.Gameplay
{
    class EntityException : Exception
    {
        public EntityException(string Message) : base(Message)
        { }
    }

    class Entity : Drawable
    {
        public Entity(string EntityPath) : base(EntityPath)
        {
            this.Components = new List<IComponent>();
            Logger.Log(LogLevel.Info, "Created new Entity");
        }

        public Component Get<Component>()
        {
            for(int i = 0; i < this.Components.Count; i++)
            {
                if(this.Components[i] is Component)
                    return (Component)Components[i];
            }

            return default(Component);
        }

        public void AddNewComponent<Component>() where Component : IComponent, new()
        {
            Component Comp = new Component();
            Comp.Init();
            
            for(int i = 0; i < this.Components.Count; i++)
            {
                if(typeof(Component) == this.Components[i].GetType())
                {
                    Logger.Log(LogLevel.Error, "Cannot have two components of the same type attached to one entity");
                    Logger.Deinit();
                    throw new EntityException("Cannot have two components of the same type attached to one entity");
                }
            }

            this.Components.Add(Comp);
            Logger.Log(LogLevel.Info, $"Added new {typeof(Component).Name} component");
        }

        public void DeleteComponent<Component>()
        {
            for (int i = 0; i < this.Components.Count; i++)
            {
                if (this.Components[i] is Component)
                {
                    this.Components[i].Deinit();
                    this.Components.RemoveAt(i);
                    Logger.Log(LogLevel.Info, $"Removed {typeof(Component).Name} component");
                }
            }
        }

        public override void Update()
        {
            for(int i = 0; i < this.Components.Count; i++)
                this.Components[i].Update(this);
        }

        protected List<IComponent> Components;
    }
}
