using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Game.Engine
{
    class CacheException : Exception
    {
        public CacheException(string Message) : base(Message)
        {

        }
    }

    class Cache<T>
    {
        public Cache()
        {
            CachedItems = new Dictionary<string, T>();
        }

        public T Get(string Key)
        {
            if(this.CachedItems.ContainsKey(Key))
                return this.CachedItems[Key];

            throw new CacheException($"Failed to find key: {Key}");
        }

        public T Add(string Key, T Item)
        {
            if(this.CachedItems.ContainsKey(Key))
                throw new CacheException($"There is already an element with the key: {Key}");

            this.CachedItems[Key] = Item;

            return Item;
        }

        protected Dictionary<string, T> CachedItems;
    }
}
