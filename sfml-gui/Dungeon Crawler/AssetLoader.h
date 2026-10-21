#pragma once

#include <iostream>
#include <map>
#include <string>

#include <SFML\Graphics.hpp>

/// This class is used as a resource cache to load in assets.
class AssetLoader
{
private:
	std::map<std::string, sf::Texture>	_TextureCache;
	std::map<std::string, sf::Font>		_FontCache;

public:
	AssetLoader(void);
	~AssetLoader(void);

	/// Load in the texture at "texturePath", caching it if it hasn't been already cached.
	const sf::Texture& LoadTexture(std::string& texturePath);

	/// Load in the font at "fontPath", caching it if neccissary
	const sf::Font& LoadFont(std::string& fontPath);
};

