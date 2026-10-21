#ifndef NET_H_INCLUDED
#define NET_H_INCLUDED

extern int inet_pton(int af, const char *src, void *dst);
extern const char *inet_ntop(int af, const void *src, char *dst, socklen_t size);

#endif // NET_H_INCLUDED
