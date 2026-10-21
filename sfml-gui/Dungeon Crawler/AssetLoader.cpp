#include "AssetLoader.h"

using namespace sf;
using namespace std;

AssetLoader::AssetLoader(void)
{
}


AssetLoader::~AssetLoader(void)
{
}

const Texture& AssetLoader::LoadTexture(string& texturePath)
{
	// Get either "map::end" or the iterator to the cached texture
	map<string, Texture>::const_iterator Cached = this->_TextureCache.find(texturePath);

	// If it's not cached, load it in and cache it
	if(Cached == this->_TextureCache.end())
	{
		Texture Tex;
		Tex.loadFromFile(texturePath);
		this->_TextureCache[texturePath] = Tex;

		return this->_TextureCache[texturePath];
	}
	// Otherwise just return the cached thing
	else
	{
		return Cached->second;
	}
}

const Font& AssetLoader::LoadFont(string& fontPath)
{
	// Get either "map::end" or the iterator to the cached font
	map<string, Font>::const_iterator Cached = this->_FontCache.find(fontPath);

	// If it's not cached, load it in and cache it
	if(Cached == this->_FontCache.end())
	{
		Font F;
		F.loadFromFile(fontPath);
		this->_FontCache[fontPath] = F;

		return this->_FontCache[fontPath];
	}
	// Otherwise just return the cached thing
	else
	{
		return Cached->second;
	}
}