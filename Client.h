#pragma once

#define _WINSOCKAPI_
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif

#include <iostream>
#include <map>
#include <list>

#include <WinSock2.h>
#include <Windows.h>
#include <WS2tcpip.h>
#include <iphlpapi.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <string.h>
#include <stddef.h>

#include "clientserver.h"
#include "Map.h"
#include "encrypt.h"

///Windows API strikes again
//typedef SSIZE_T ssize_t;

using namespace std;

enum GameState{
	LoggedOff, LoggedOn, Playing
};

/**
	GameMaster = power to full ban and all commands.
	Moderator = power to temp ban (Max 2 days) and limited commands.
	NormalUser = very little power. Only /unstick to a town/city/settlement and the talk commands.
**/
enum CharacterType{
	GameMaster, Moderator, NormalUser
};

class Client
{
public:
	Client(void);
	~Client(void);

	int		SyncWithServer(string, string);
	int		confirmLogon(void);
    void	logoff(void);

private:
	/// Winsock Strikes again
	WORD wVer;
	WSADATA wsaData;
	int eVerErr;

	/// Stay away from those nasty varibles. You variables are too nice to be tainted by Microsoft!
	MMO_SOCKET		 serverSocket;
	GameState		 state;

	///Map Data
	unsigned int	 mapZone;
	unsigned int	 myMap;
	unsigned int	 myX;
	unsigned int	 myY;

	list<unsigned int> maps;
	map<unsigned int, Map*> mapData;

	///Logon functions
	int		waitForLogonRequest(string, string);
	int		logon(string, string);

	///Player function
	void	requestPlayerData(void);

	//Misc.
	int		waitForAck(bool*, RIPID_t*, uint8_t*);
	int		WaitForServerData(RIP_Header **);
	int		waitForIDRequest(void);

	int		identifyClient(void);

	int		connectToServer(void);

};

