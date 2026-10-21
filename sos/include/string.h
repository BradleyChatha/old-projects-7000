#ifndef STRING_H
#define STRING_H

#include "types.h"

uint16 strLength(string s)
{
	/*uint16 i = 1;
	while(s[i++]); //Add 1 to i
	return --i;*/
	
	uint16 ret = 0;
	
	while(s[ret] != 0)
		ret++;
	return ret;
}

uint8 strEql(string s1, string s2)
{
	uint8 result = 1;
	uint8 size = strLength(s1);
	
	if(size != strLength(s2))
		result = 0;
	else
	{
		uint8 i = 0;
		
		for(; i <= size; i++)
		{
			if(s1[i] != s2[i])
				result = 0;
		}
	}
	
	return result;
}


char* itoa(int32 value, int32 base)
{
	static char buf[32] = {0};
	int i = 30;
	
	for(; value && i; --i, value /= base)
		buf[i] = "0123456789abcdef"[value % base];
		
	return &buf[i+1];
}

#endif
