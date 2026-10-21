//
// "Role-On" Gaming Server
// Various data types
// 

#ifndef ROLEONTYPES_H
#define ROLEONTYPES_H

#include "osints.h"

typedef int MMO_SOCKET;

typedef uint16_t RIPID_t;

typedef uint32_t TransID_t;
#define TransID_T_MAX	0xFFFFFFFF

//
// Version number, of the form 'major.minor.patch'
//
typedef uint16_t VersionElement_t;
struct VersionNumber_t {
	VersionElement_t	major;
	VersionElement_t	minor;
	VersionElement_t	patch;
};

// Map formats (first entry 0; ENDMF must be last entry).
//  SLTM Simple Level-based Tile Map
enum MapFormat_t { SLTM=0, ENDMF };
// Map Accessibility (1 and 2 for future use)
enum MapAccess_t { MAP_NO_ACCESS=0, MAP_FULL_ACCESS=3 };
// PLayer cannot move reasons & excuses
enum PlayerMoveResult_t { MOVE_OK=0, MOVE_ILLEGAL, MOVE_OUT_OF_BOUNDS, MOVE_INACCESSIBLE };

#endif

