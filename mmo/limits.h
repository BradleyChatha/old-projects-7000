//
// "Role-On" Gaming Server
// Limits for game
// 

#ifndef LIMITS_H
#define LIMITS_H

//
// GENERAL GAME
//
#define	GAME_NAME_MAX		64
#define GAMEPACK_CODE_LEN	4

//
// MAPPING LIMITS
// (dont exceed 65535)
//
#define	MAP_X_MAX		50
#define	MAP_Y_MAX		50
#define MAPS_MAX		999
#define ZONES_MAX		255
#define MAPS_PER_ZONE	20
// SLTM specific limits
#define HIGH_LEVEL		255
#define GROUND_LEVEL	128
#define	LOW_LEVEL		1

//
// CLIENTS
//
#define CLIENTS_MAX		999
#define LOGON_NAME_MIN	8
#define LOGON_NAME_MAX	40
#define LOGON_PWD_MIN	8
#define LOGON_PWD_MAX	16

//
// OBJECTS
//
#define OBJECT_DEFS_MAX	10
#define OBJECTS_MAX 	100

//
// PLAYERS
//
#define PLAYER_NAME_MIN	4
#define PLAYER_NAME_MAX	16
#define PLAYER_DESC_MAX	128
#define PLAYERS_MAX		10
#define RACES_MAX 		10

//
// MISCELLANEOUS
//
#define TEXTMSG_LEN		128

#endif

