//
// "Role-On" Gaming Server
// Encryption algorithm - acquired by DJB from somewhere. 
// TODO check valid to include
// 

#include <iostream>

using namespace std;

string encrypt(string strTarget)
{
	int len = strTarget.length();
	char a;
	string strFinal(strTarget);

	for (int i = 0; i <= (len-1); i++) {
		a = strTarget.at(i);
		int b = (int)a; //get the ASCII value of 'a'
		b += 15; //Mulitply the ASCII value by 27
		if (b > 254)
			b = 254;
		a = (char)b; //Set the new ASCII value back into the char
		strFinal.insert(i , 1, a); //Insert the new Character back into the string
	}

	string strEncrypted(strFinal, 0, len);

	return strEncrypted;
}

