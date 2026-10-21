#include "GuiImage.h"

using namespace std;
using namespace sf;

GuiImage::GuiImage(string image) : _ImagePath(image)
{
}


GuiImage::~GuiImage(void)
{
}

void GuiImage::Init(AssetLoader* loader)
{
	this->_Image.setTexture(loader->LoadTexture(this->_ImagePath), true);
}

void GuiImage::Draw(RenderWindow* window)
{
	window->draw(this->_Image);
}

void GuiImage::Update(RenderWindow* window)
{

}

void GuiImage::Inline()
{
	this->_Image.setPosition(this->GetPosition());
}