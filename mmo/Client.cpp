#include <iostream>
#include <fstream>
#include <winsock2.h>

#include "Client.h"
#include "Net.h"

using namespace std;

char buffer[MAX_BUFFER];
char gamePackCode[5];
int gpVersionMod;

Client::Client(void) : mapZone(0), myX(0), myY(0), myMap(0), wVer(MAKEWORD(2, 2))
{
	eVerErr = WSAStartup(wVer, &wsaData);

	 if (eVerErr != 0) {
        printf("WSAStartup failed with error: %d\n", eVerErr);
        exit(0);
    }
}

Client::~Client(void)
{
	WSACleanup();
}

int Client::confirmLogon(void)
{
	bool acked;
	RIPID_t ackedID;
	uint8_t logonReject;

	for(;;)
	{
		if(waitForAck(&acked, &ackedID, &logonReject) != 0)
		{
			cerr << "failed to connect to server" << endl;
			return -1;
		}
		if(ackedID == RI_LOGON && acked)
		{
			cerr << "Client logged on" << endl;
			state = LoggedOn;
			requestPlayerData();
			break;
		}
		else
		{
			if(logonReject == RI_REJ_RESEND)
			{
				cerr << "Logon blocked! try again..." << endl;
			}
			else if(logonReject == RI_REJ_LOGGEDON)
			{
				cerr << "Account already logged on" << endl;
			}
			else
			{
				cerr << "Password incorrect" << endl;
			}
			//logon(user, _Password);
		}
	}

	return 0;
}

int Client::waitForAck(bool* acked, RIPID_t *acktype, uint8_t* rejectReason)
{
	RIP_Acknowledge *ripAcknowledge;
	RIP_Reject *ripReject;

	if(WaitForServerData((RIP_Header**)&ripAcknowledge) == 0)
	{
		if(ripAcknowledge->h.ripID == RI_ACKNOWLEDGE)
		{
			*acked = true;
			*acktype = ripAcknowledge->ackRIPID;
		}

		else if(ripAcknowledge->h.ripID == RI_REJECT)
		{
			ripReject = (RIP_Reject*)ripAcknowledge;
			*acked = false;
			*acktype = ripReject->rejRIPID;
			cerr << "(RIP): Reject ID: " << ripReject->rejRIPID << " | Reject reason: " << ripReject->rejReason << endl;
		}
		else
		{
			cerr << "(RIP): no ack/reject - wrong ID" << endl;
		}
	}
	else
	{
		cerr << "(RIP): no ack/reject - recv error" << endl;
	}

	return 0;
}

int Client::connectToServer(void) {
	struct sockaddr_in serverAddr;

	serverSocket = socket(AF_INET, SOCK_STREAM, 0);

	serverAddr.sin_family = AF_INET;
	serverAddr.sin_port =  htons(2001);

	inet_pton(AF_INET, "127.0.0.1", &serverAddr.sin_addr);
	//inet_pton(AF_INET, "10.35.216.2", &serverAddr.sin_addr);

	connect(serverSocket, (sockaddr *)&serverAddr, sizeof (serverAddr));
	if (serverSocket == SOCKET_ERROR)
    {
        cout << "CLIENT Client cant connect to server." << endl;
        return -1;
    }


	return 0;
}

int	Client::SyncWithServer(string user, string pass)
{
	///setup the connection
	if(connectToServer() != 0)
	{
		cerr << "(Client) Failed to sync - connect" << endl;
		return -1;
	}
	else
	{
		cerr << "(Client) Connected to the server" << endl;
	}

	///Server will start talking to us now
	if(waitForIDRequest() != 0)
	{
		cerr << "(Client) Failed to sync - ID" << endl;
		return -1;
	}
	else
	{
		cerr << "(Client) Identified as client" << endl;
	}

	///Server will want to know our logon
	if(waitForLogonRequest(user, pass) != 0)
	{
		cerr << "(Client) failed to sync - Logon" << endl;
		return -1;
	}
	else
	{
		cerr << "(Client) Logged on" << endl;
	}
	return 0;
}

int	Client::WaitForServerData(RIP_Header** header)
{
	ssize_t recvB;
	char *bufPtr = buffer;

	recvB = recv(serverSocket, bufPtr, sizeof(RIP_Header), 0);
	*header = (RIP_Header*)bufPtr;

	while(recvB > 0 && (*header)->length > recvB)
	{
		bufPtr += recvB;
		recvB += recv(serverSocket, bufPtr, (*(header))->length-recvB, 0);
	}

	if(recvB <= 0)
	{
		cerr << "(Client) Error receiving data from server! recvB: " << recvB  << " BufPtr: " << &bufPtr << endl;
		return -1;
	}

	return 0;
}

int Client::waitForIDRequest(void)
{
	RIP_IdentifyType *ripIdentifyType;

	if (WaitForServerData((RIP_Header **)&ripIdentifyType) == 0) {
		if (ripIdentifyType->h.ripID == RI_IDENTIFYTYPE) {
			return (identifyClient());
		}
		else
		{
			cerr << "(Client) Wrong Error" << endl;
			return -1;
		}
	}
	else
	{
		cerr << "(Client) Recv error" << endl;
		return -1;
	}

}

int Client::identifyClient(void) {
	RIP_Type ripType;
	ssize_t sentB;

	ripType.h.ripID = RI_TYPE;
	ripType.h.length = sizeof(ripType);
	ripType.h.transID = 0;
	ripType.ifVersion.major = IF_VERSION_MAJOR;
	ripType.ifVersion.minor = IF_VERSION_MINOR;
	ripType.type = CLIENT_PLAYER;

	strcpy(ripType.gamePackCode, gamePackCode);
	ripType.gamePackVer.major = 0 + gpVersionMod;
	ripType.gamePackVer.minor = 0 + gpVersionMod;
	ripType.gamePackVer.patch = 0 + gpVersionMod;

	ripType.gamePackCode[0] = 'S';
	ripType.gamePackCode[1] = 'O';
	ripType.gamePackCode[2] = 'U';
	ripType.gamePackCode[3] = 'P';

	sentB = send(serverSocket, (char*)&ripType, sizeof(ripType), 0);
	if (sentB != sizeof(ripType))
	{
        cout << "(Client) Could not send identify!" << endl;
        return -1;
	}

	return 0;
}

int Client::logon(string user, string pass)
{
	RIP_Logon ripLogon;
	ssize_t sentB;

	string userName = user;
	string Password = pass;

	ripLogon.h.ripID = RI_LOGON;
	ripLogon.h.length = sizeof(ripLogon);
	ripLogon.h.transID = 0;

	strcpy(ripLogon.name, userName.c_str());
	Password = encrypt(Password);
	strcpy(ripLogon.password, Password.c_str());

	sentB = send(serverSocket, (char*)&ripLogon, sizeof(ripLogon), 0);

	if(sentB != sizeof(ripLogon))
	{
		cerr << "(Client) Couldn't send logon" << endl;
		return -1;
	}

	state = LoggedOn;

	return 0;
}

int Client::waitForLogonRequest(string user, string pass)
{
	RIP_RequestLogon *ripRequestLogon;

	if(WaitForServerData((RIP_Header **)&ripRequestLogon) == 0)
	{
		if(ripRequestLogon->h.ripID == RI_REQUESTLOGON)
		{
			return ((logon(user, pass) == ripTrue)? true : false);
		}
		else if(ripRequestLogon->h.ripID == RI_REJECT)
		{
			cerr << "(Client) Client Incompatible. ripID: " << ripRequestLogon->h.ripID << endl;
			return -1;
		}
		else
		{
			cerr << "(Client) No request to logon. Wrong ID" << endl;
			return -1;
		}
	}
	else
	{
		cerr << "(Client) no request to logon. Recv error" << endl;
	}

	return 0;
}

void Client::logoff(void)
{
    RIP_Logoff ripLogoff;
    ssize_t sentB;
    bool acked;
    RIPID_t ackedID;

    if(state == Playing)
    {
        ///stopPlaying();
    }
    else if(state == LoggedOn)
    {
        ripLogoff.h.ripID = RI_LOGOFF;
        ripLogoff.h.length = sizeof(ripLogoff);
        ripLogoff.h.transID = 0;
        sentB = send(serverSocket, (char*)&ripLogoff, sizeof(ripLogoff), 0);

        waitForAck(&acked, &ackedID, NULL);
        if(acked && (ackedID == RI_LOGOFF))
        {
            state = LoggedOff;
            cout << "Logged off" << endl;
        }
    }

}

void Client::requestPlayerData(void)
{}
