#pragma once

#include <map>
#include <SFML\Graphics.hpp>

using namespace sf;
using namespace std;

template<class T>
class Cache
{
public:
	Cache() {}

	/*
	*	Adds a new value into the array.
	*	Params:
	*		string Name - the Key used to add to the Array.
	*		T* Item - The item to add to the cache.
	*	Returns a pointer to the added item.
	*	Exceptions:
	*		Runtime_error - if Item is a nullptr.
	*/
	T* AddItem(string Name, T Item)
	{
		auto CacheIt = CachedData.find(Name);
		
		if (CacheIt != CachedData.end())
			return &CachedData[Name];

		CachedData[Name] = Item;
		return &CachedData[Name];
	}

	/*
	*	See AddItem, just an easy way to use.
	*/
	T* operator()(string Name, T Item)
	{
		return AddItem(Name, Item);
	}

	/*
	*	Gets an item stored in the cache.
	*	Params:
	*		string Name - The key used to access the array.
	*	Returns a pointer to the item found.	
	*	Exceptions:
	*		Runtime_error - If the key used doesn't access any data.
	*/
	T* GetItem(string Name)
	{
		auto CacheIt = CachedData.find(Name);

		if (CacheIt != CachedData.end())
			return &CachedData[Name];

		throw runtime_error("[Cache] Cannot find item in cache.");
	}

private:
	map<string, T> CachedData;
};

static Cache<Texture> TextureCache;