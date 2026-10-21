//
// "Role-On" Gaming Server
// Client/Server comms packets
// definitions
//

#ifndef CLIENTSERVER_H
#define CLIENTSERVER_H

#include "osints.h"
#include "localtypes.h"
#include "limits.h"

// Version number, "0.1".
#define IF_VERSION_MAJOR	0
#define IF_VERSION_MINOR	1

#pragma pack(1)

// common TCP/IP stuff
#define SOCKET_ERROR	(-1)
#define RX_ATTEMPTS		3
#define TX_ATTEMPTS		3
#define MAX_BUFFER		512

#define MAP_SEGMENT_SIZE	36

// Gender symbols
enum Gender_t { male=1, female=2 };

// Boolean as uint8_t for interface
enum Bool_t { ripFalse = 0, ripTrue = 1 };

//
// Role-On Interface Packet ids (RIPID_t), 1-65535
//
// Server -> client ids
#define RI_IDENTIFYTYPE			1
#define	RI_REQUESTLOGON			2
#define RI_ACKNOWLEDGE			3
#define RI_REJECT				4
#define RI_TEXT_MESSAGE			5
#define RI_SERVER_SHUTDOWN		6
#define RI_HEARTBEAT			7
#define	RI_NO_PLAYERS			8
#define	RI_PLAYER_ID			9
#define	RI_QR_SERVER			10
#define	RI_ZONE_LOCATION		11
#define RI_ZONE_MAPS			12
#define RI_MAP_PARAMS			13
#define RI_MAP_SEGMENT			14
#define RI_QR_MAP_ZONES			15
#define RI_PLAY_LOCATION		16
#define	RI_MOVE_REJECTED		17

// Client -> server ids
#define RI_TYPE					1000
#define RI_QUIT					1001
#define	RI_LOGON				1002
#define	RI_TERMINATE			1003
#define RI_DEBUG_LEVEL			1004
#define RI_LOG_LEVEL			1005
#define RI_CON_BROADCAST	    1006
#define	RI_LOGOFF				1007
#define RI_CREATE_PLAYER		1008
#define RI_FETCH_PLAYER_DATA	1009
#define RI_PLAY					1010
#define RI_END_PLAY				1011
#define RI_DELETE_PLAYER		1012
#define	RI_QUERY_SERVER			1013
#define	RI_FETCH_ZONE_MAPS		1014
#define RI_FETCH_MAP_PARAMS		1015
#define RI_FETCH_MAP_SEGMENT	1016
#define RI_QUERY_MAP_ZONES		1017
#define RI_NSEW_TILE_MOVE		1018

// REJECT reasons
#define RI_REJ_GENERAL	0
#define RI_REJ_RESEND	1
#define RI_REJ_LOGGEDON	2

// Client identities
enum ClientType_t { CLIENT_UNKNOWN, CLIENT_PLAYER, SERVER_CONSOLE };

//
// Packet data structures
//
struct RIP_Header {
	RIPID_t		ripID;
	uint16_t	length;		// length of entire packet including header
	TransID_t	transID;	// transaction id
};

// S->C Type Identification request packet
struct RIP_IdentifyType {
	RIP_Header	h;
};

// S->C player requested to logon
struct RIP_RequestLogon {
	RIP_Header	h;
	uint8_t		multiPlayerMode;
};

// S->C Server Acknowledges request
struct RIP_Acknowledge {
	RIP_Header	h;
	RIPID_t		ackRIPID;
};

// S->C Server rejects request
struct RIP_Reject {
	RIP_Header	h;
	RIPID_t		rejRIPID;
	uint8_t		rejReason;
};

// S->C Inform client(s) server has shut down
struct RIP_ServerShutdown {
	RIP_Header	h;
};

// S->C heartbeat
struct RIP_Heartbeat {
	RIP_Header	h;
};


// S->C tell client no player
struct RIP_NoPlayers {
	RIP_Header	h;
};


// S->C tell client about their player
struct RIP_PlayerID {
	RIP_Header	h;
	char		name[PLAYER_NAME_MAX+1];
	uint8_t		race;
	uint8_t		gender;
	char		briefDescription[PLAYER_DESC_MAX+1];
};

// S->C Query Response - Server data
struct RIP_ServerData {
	RIP_Header		h;
	VersionNumber_t	serverVersion;
	VersionNumber_t ifVersion;
	char			gameName[GAME_NAME_MAX+1];
	VersionNumber_t	gamePackVer;
	VersionNumber_t dbVersion;
};

// S->C Send Zone Location
struct RIP_ZoneLocation {
	RIP_Header		h;
	uint8_t			zone;
	uint16_t		map;
	uint16_t		x;
	uint16_t		y;
};

// S->C Send Maps of Zone
struct RIP_ZoneMaps {
	RIP_Header		h;
	uint16_t		mapList[MAPS_PER_ZONE];
	uint16_t		numInList;
};

// S->C Send Map params
struct RIP_MapParams {
	RIP_Header		h;
	uint16_t		mapNumber;
	uint16_t		level;
	uint16_t		x;
	uint16_t		y;
};

// S->C Map segment
struct RIP_MapSegment {
	RIP_Header		h;
	uint16_t		mapNumber;
	uint16_t		segment;
	char			mapSegment[MAP_SEGMENT_SIZE+1];
};

// S->C Map Zones
struct RIP_MapZones {
	RIP_Header		h;
	uint8_t			zoneList[ZONES_MAX];
	uint8_t			numInList;
	uint8_t			format;
};

// S->C Play Location (after a move)
struct RIP_PlayLocation {
	RIP_Header		h;
	uint16_t		x;
	uint16_t		y;
};

// S->C Move rejected with reason
struct RIP_MoveRejected {
	RIP_Header		h;
	uint8_t			reason;
};

// C->S Client's type
struct RIP_Type {
	RIP_Header		h;
	VersionNumber_t ifVersion;
	uint8_t			type;
	char		    gamePackCode[4];
	VersionNumber_t	gamePackVer;
};

// C->S Quit
struct RIP_Quit {
	RIP_Header	h;
};

// C->S Logon
struct RIP_Logon {
	RIP_Header	h;
	char		name[LOGON_NAME_MAX+1];
	char		password[LOGON_PWD_MAX+1];
};

// C->S Terminate server (console)
struct RIP_Terminate {
	RIP_Header	h;
};

// C->S Set server's debug level (console)
struct RIP_DebugLevel {
	RIP_Header	h;
	uint8_t		level;
};

// C->S/S->C Text message: includes broadcasts
struct RIP_TextMessage{
    RIP_Header	h;
    char 		msg[TEXTMSG_LEN+1];
};

// C->S client logoff
struct RIP_Logoff {
	RIP_Header	h;
};

// C->S Create player character
struct RIP_CreatePlayer {
	RIP_Header	h;
	char		name[PLAYER_NAME_MAX+1];
	uint8_t		race;
	uint8_t		gender;
	char		briefDescription[PLAYER_DESC_MAX+1];
};

// C->S request player data for account
struct RIP_FetchPlayerData {
	RIP_Header		h;
};

// C->S request start playing
struct RIP_Play {
	RIP_Header		h;
};

// C->S request end playing
struct RIP_EndPlay {
	RIP_Header		h;
};

// C->S request end playing
struct RIP_DeletePlayer {
	RIP_Header		h;
};

// C->S query server
struct RIP_QueryServer {
	RIP_Header		h;
};

// C->S fetch maps for specified zone
struct RIP_FetchZoneMaps {
	RIP_Header	h;
	uint8_t	zone;
};

// C->S fetch map parameters
struct RIP_FetchMapParams {
	RIP_Header	h;
	uint16_t	map;
};

// C->S fetch map segment
struct RIP_FetchMapSegment {
	RIP_Header	h;
	uint16_t	map;
	uint16_t	segment;
};

// C->S query server
struct RIP_QueryMapZones {
	RIP_Header	h;
};

// C->S North,South,East,West tile move
struct RIP_NSEWTileMove {
	RIP_Header	h;
	char		direction;
};

#pragma pack ()
#endif

