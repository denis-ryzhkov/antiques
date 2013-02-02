#ifndef __dr_creon__pinger_h__
#define __dr_creon__pinger_h__

/*
 * pinger, version 2.0 for icmp.dll
 * Copyright (c) 2002-2003 Denis Ryzhkov ( Creon )
 * http://creon.cjb.net/?soft/pinger
 *
 */

#include <windows.h>

class Pinger {

 typedef struct tag_IP_OPTION_INFORMATION {
  UCHAR ttl;
  UCHAR tos;
  UCHAR flags;
  UCHAR optionsSize;
  UCHAR FAR *optionsData;
 } IP_OPTION_INFORMATION, FAR *PIP_OPTION_INFORMATION;

 typedef struct tag_ICMP_ECHO_REPLY {
  DWORD address;
  ULONG status;
  ULONG rtt;
  USHORT dataSize;
  USHORT reserved;
  VOID FAR *data;
  IP_OPTION_INFORMATION options;
 } ICMP_ECHO_REPLY, FAR *PICMP_ECHO_REPLY;

 HANDLE ( WINAPI *IcmpCreateFile )();

 BOOL ( WINAPI *IcmpCloseHandle )( HANDLE );

 DWORD ( WINAPI *IcmpSendEcho )( HANDLE, DWORD, LPVOID, WORD,
   PIP_OPTION_INFORMATION, LPVOID, DWORD, DWORD );

 HMODULE hLib;
 HANDLE hFile;
 ICMP_ECHO_REPLY replyBuffer;

public:

 static enum LoadCode { OK, INVALID_LIBRARY, INVALID_FUNCTIONS, INVALID_FILE };
 IP_OPTION_INFORMATION requestOptions;
 DWORD ttw;

 Pinger() : hLib( 0 ) {}

 LoadCode load( DWORD ttw = 500, UCHAR ttl = 127 ) {
  if ( !( hLib = LoadLibrary( "ICMP.DLL" )))
   return INVALID_LIBRARY;

  IcmpCreateFile = ( HANDLE ( WINAPI* )() )
    GetProcAddress( hLib, "IcmpCreateFile" );
  IcmpCloseHandle = ( BOOL ( WINAPI* )( HANDLE ) )
    GetProcAddress( hLib, "IcmpCloseHandle" );
  IcmpSendEcho = ( DWORD ( WINAPI* )( HANDLE, DWORD, LPVOID, WORD,
    PIP_OPTION_INFORMATION, LPVOID, DWORD, DWORD ))
    GetProcAddress( hLib, "IcmpSendEcho" );
  if ( !IcmpCreateFile || !IcmpCloseHandle || !IcmpSendEcho ) {
   FreeLibrary( hLib );
   hLib = 0;
   return INVALID_FUNCTIONS;
  }

  if ( ( hFile = IcmpCreateFile() ) == INVALID_HANDLE_VALUE ) {
   FreeLibrary( hLib );
   hLib = 0;
   return INVALID_FILE;
  }

  memset( &requestOptions, 0, sizeof( IP_OPTION_INFORMATION ));
  requestOptions.ttl = ttl;
  this->ttw = ttw;
  return OK;
 }

 ~Pinger() { if ( hLib ) {
  IcmpCloseHandle( hFile );
  FreeLibrary( hLib );
 }}

 bool ping( DWORD dwAddr ) {
  if ( !hLib ) return false;
  IcmpSendEcho( hFile, dwAddr, 0, 0, &requestOptions, &replyBuffer,
    sizeof( ICMP_ECHO_REPLY ), ttw );
  return ( replyBuffer.address == dwAddr ) && !replyBuffer.status;
 }

};

/*
 * example of usage:
 *
 * Pinger pinger;
 * switch ( pinger.load() ) {
 *  case Pinger::INVALID_LIBRARY: cout << "INVALID_LIBRARY"; break;
 *  case Pinger::INVALID_FUNCTIONS: cout << "INVALID_FUNCTIONS"; break;
 *  case Pinger::INVALID_FILE: cout << "INVALID_FILE"; break;
 *  case Pinger::OK:
 *   cout << "Ping of localhost: " << 
 *     ( pinger.ping( 0x0100007F )? "OK" : "Bad" );
 *   break;
 * }
 *
 */

#endif
