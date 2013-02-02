hiderun, version 1.2
Copyright (c) 2001-2003 Denis Ryzhkov ( Creon )
http://creon.cjb.net/?soft/hiderun

usage:	hiderun someapp.exe
result:	someapp.exe is started, but no window is displayed
why:	Apache for Win32 runs under Win9x as a boring console

source code:

#include <windows.h>

int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
  LPSTR lpCmdLine, int nCmdShow ) {
 return WinExec( lpCmdLine, SW_HIDE );
}

tools 4 Apache:

apache-run.bat	@hiderun c:\app\apache\apache.exe
apache-die.bat	@c:\app\apache\apache.exe -k shutdown
apache-re.bat	@c:\app\apache\apache.exe -k restart
