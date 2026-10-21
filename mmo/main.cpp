#include "Client.h"

int main()
{
    Client client;
	string user, pass;

	cout << "UserName: ";
	cin >> user;

	cout << "Password: ";
	cin >> pass;

	if(client.SyncWithServer(user, pass) != 0)
	{
		cout << "Failed" << endl;
	}
	else
	{
		cout << "Connected" << endl;
	}

	system("PAUSE");

	client.logoff();

	return 0;
}



