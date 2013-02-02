#include <windows.h>
#include <stdio.h>

LONGLONG FileTime2LongLong( FILETIME fileTime ) {
 LARGE_INTEGER largeInteger; // 64-bit CPU alignment-safe method
 largeInteger.LowPart = fileTime.dwLowDateTime;
 largeInteger.HighPart = fileTime.dwHighDateTime;
 return largeInteger.QuadPart;
}

LONGLONG GetProcessCPUTime( HANDLE hProcess ) {
 FILETIME creationTime, exitTime, kernelTime, userTime;
 if ( !GetProcessTimes( hProcess, &creationTime, &exitTime, &kernelTime, &userTime )) ExitProcess( GetLastError());
 return FileTime2LongLong( kernelTime ) + FileTime2LongLong( userTime );
}

HANDLE StartCmdLine( LPSTR cmdLine ) {
 STARTUPINFO si; GetStartupInfo( &si );
 PROCESS_INFORMATION pi;
 if ( !CreateProcess( 0, cmdLine, 0, 0, 0, 0, 0, 0, &si, &pi )) ExitProcess( GetLastError());
 CloseHandle( pi.hThread );
 return pi.hProcess;
}

INT WINAPI WinMain( HINSTANCE, HINSTANCE, LPSTR cmdLine, INT ) {

 if ( !cmdLine[0]) {
  MessageBox( 0,
   "proczomb, version 1.3 2007-08-16--2008-01-14 (c) Denis Ryzhkov\n"
   "http://denis.ryzhkov.org/?soft/proczomb\n"
   "\n"
   "usage: proczomb 0.001 60 1000 \"C:\\Program Files\\App\\App.exe\" AppParam1 ... AppParamN\n"
   "\n"
   "means: proczomb starts \"C:\\Program Files\\App\\App.exe\" with AppParams\n"
   "and if its CPU Usage is 0.001% or less for 60 periods each 1000 mls\n"
   "then proczomb restarts the process.\n"
   "\n"
   "can be used to watch bots and restart hanged ones automatically.\n"
   "source code provided.\n",
   "proczomb", MB_OK );
  return 0;
 }

 float idleCPUUsage; // in %
 int deadTime; // in checkTime
 int checkTime; // in mls
 char processCmdLine[ 1024 ];
 if ( 4 != sscanf( cmdLine, "%f %d %d %[^\0]",
  &idleCPUUsage, &deadTime, &checkTime, processCmdLine )) return 1;

 HANDLE hProcess = StartCmdLine( processCmdLine );
 DWORD exitCode = STILL_ACTIVE;
 
 for ( int idleTime = 0; exitCode == STILL_ACTIVE; idleTime++ ) {

  LONGLONG prevCPUTime = GetProcessCPUTime( hProcess );
  Sleep( checkTime );
  LONGLONG deltaCPUTime = GetProcessCPUTime( hProcess ) - prevCPUTime;
  double cpuUsage = (double) deltaCPUTime / ( checkTime * 100 );
  if ( cpuUsage > idleCPUUsage ) idleTime = 0;

  if ( idleTime >= deadTime ) {
   TerminateProcess( hProcess, 0 );
   if ( WaitForSingleObject( hProcess, INFINITE ) == WAIT_FAILED ) return GetLastError();
   CloseHandle( hProcess );
   hProcess = StartCmdLine( processCmdLine );
   idleTime = 0;
  }
 
  if ( !GetExitCodeProcess( hProcess, &exitCode )) return GetLastError();
 }

 return 0;
}
