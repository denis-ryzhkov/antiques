#include <windows.h>

INT WINAPI WinMain( HINSTANCE, HINSTANCE, LPSTR, INT ) {
 RegisterHotKey( 0, GlobalAddAtom( "InsOFF" ), 0, VK_INSERT );
 Sleep( INFINITE );
 return 0;
}
