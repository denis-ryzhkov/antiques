InsOFF, version 1.1
Copyright (c) 2005 Denis Ryzhkov
http://denis.ryzhkov.org/?soft/insoff

Some people (not me) hate Ins key that toggles Overwrite mode on.
InsOFF placed in startup disables Ins key.

source code:

#include <windows.h>

INT WINAPI WinMain( HINSTANCE, HINSTANCE, LPSTR, INT ) {
 RegisterHotKey( 0, GlobalAddAtom( "InsOFF" ), 0, VK_INSERT );
 Sleep( INFINITE );
 return 0;
}
