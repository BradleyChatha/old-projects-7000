#include "Player.h"
#include <iostream>
using namespace std;

Player::Player()
{
	Texture texture;
	if (!texture.loadFromFile("Assets\\Actors\\Player.png"))
		throw runtime_error("[Player] Failed to find player textures.");

	this->ActorSprite.setTexture(*TextureCache("PlayerTexture", texture));
	this->ActorSprite.setPosition(10, 10);
	this->ActorSprite.setColor(Color(255, 255, 255));

	this->PlayerMovementSpeed = 20.f;
	this->ActorID = 0x01;
}

Player::~Player()
{
}

void Player::Destroy(void)
{
}

void Player::Move(Vector2f MoveBy)
{
	this->ActorSprite.move(MoveBy);
}

void Player::Teleport(Vector2f NewPosition)
{}

void Player::Update(Time DeltaTime)
{
	if (Keyboard::isKeyPressed(Keyboard::D)) ///Right
	{
		this->Move(Vector2f(this->PlayerMovementSpeed, 0) * DeltaTime.asSeconds());
	}
	else if (Keyboard::isKeyPressed(Keyboard::A)) ///Left
	{
		this->Move(Vector2f(-this->PlayerMovementSpeed, 0) * DeltaTime.asSeconds());
	}
}

void Player::draw(RenderWindow &GameWindow)
{
	GameWindow.draw(this->ActorSprite);
}

void Player::Save(fstream & SaveFile)
{
	if (!SaveFile)
		throw runtime_error("[Player] Invaild Save File.");

	SaveFile.write((char*)&this->ActorSprite.getPosition().x, sizeof(float));
	SaveFile.write((char*)&this->ActorSprite.getPosition().y, sizeof(float));
}

void Player::Load(fstream & SaveFile)
{
	if (!SaveFile)
		throw runtime_error("[Player] Invaild Save File.");

	SaveFile.write((char*)&this->ActorSprite.getPosition().x, sizeof(float));
	SaveFile.write((char*)&this->ActorSprite.getPosition().y, sizeof(float));
}
