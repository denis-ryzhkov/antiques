// filemsg, version 1.1 2007-11-28 (c) Denis Ryzhkov
// http://denis.ryzhkov.org/?soft/filemsg

#include <windows.h>
#include <stdio.h>
#include <string.h>

//// general commands

// command: set title
// param-s: title(string)
// default: !t filemsg
char title[128] = "filemsg";

// command: sleep
// param-s: sleepTime(mls)
// default: !s 1000
int sleepTime = 1 * 1000;

// command: beep internal pc-speaker
// param-s: beepFrequency(hertz) beepDuration(mls)
// default: !b 800 200
DWORD beepFrequency = 800;
DWORD beepDuration = 200;

// command: reload file
// param-s: none
// usage  : !r

// command: only once execute next lines (if onceLevel is greater than stored)
// param-s: onceLevel(0-18446744073709551615) onceSkip(lines)
// default: !o 0 1
unsigned __int64 onceLevel = 0;
int onceSkipNew = 1;
int onceSkip = 0;

//// unclosable window commands

// command: set initial position
// param-s: initLeft initTop (pixel)
// default: !i 100 100
int initLeft = 100;
int initTop = 100;

// command: show window
// param-s: windowWidth windowHeight windowMargin (pixel)
// default: !w 200 100 10
int windowWidth = 200;
int windowHeight = 100;
int windowMargin = 10;

// command: hide window
// param-s: none
// default: !h
bool windowVisible = false;

// command: set align
// param-s: align(single character: l=left c=center r=right)
// default: !a l
char align[2] = "l"; // l-eft c-enter r-ight

// command: set font
// param-s: fontSize(points) fontStyle(string with characters:
//          b=bold i=italic u=underline s=strikeout OR n=normal)
//          fontFace(string OR "any")
// default: !f 14 n any
int fontSize = 14;
char fontStyle[5] = "n";
char fontFace[128] = "any"; // font face name

// command: set color
// param-s: textR textG textB backR backG backB (RGB 0-255)
// default: !c 255 255 255 0 0 0
int textR = 255; int textG = 255; int textB = 255;
int backR = 0; int backG = 0; int backB = 0;

//// globals

HINSTANCE instance;
HWND window;
bool windowReady = false;
char* windowText = 0;

//// window messages

LRESULT CALLBACK windowProc( HWND window, UINT msg, WPARAM wParam, LPARAM lParam ) {
 switch ( msg ) {

  case WM_LBUTTONDOWN:
  SendMessage( window, WM_SYSCOMMAND, SC_MOVE | HTCAPTION, 0 );
  break;

  case WM_PAINT: {
  if ( !windowText ) return DefWindowProc( window, msg, wParam, lParam );
  PAINTSTRUCT ps;
  HDC dc = BeginPaint( window, &ps );
  SetTextColor( dc, RGB( textR, textG, textB ));
  SetBkMode( dc, TRANSPARENT );
  HFONT font = CreateFont(
   -MulDiv( fontSize, GetDeviceCaps( dc, LOGPIXELSY ), 72 ), 0, 0, 0,
   ( strchr( fontStyle, 'b' )? 700 : 400 ),
   ( strchr( fontStyle, 'i' )? TRUE : FALSE ),
   ( strchr( fontStyle, 'u' )? TRUE : FALSE ),
   ( strchr( fontStyle, 's' )? TRUE : FALSE ),
   DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, DEFAULT_QUALITY,
   DEFAULT_PITCH, ( strcmp( fontFace, "any" )? fontFace : 0 ));
  DeleteObject((HFONT) SelectObject( dc, font ));
  RECT rect = { windowMargin, windowMargin,
   windowWidth - windowMargin, windowHeight - windowMargin };
  DrawText( dc, windowText, strlen( windowText ), &rect, DT_WORDBREAK |
   ( align[0] == 'l' ? DT_LEFT :
     align[0] == 'c' ? DT_CENTER :
     align[0] == 'r' ? DT_RIGHT : 0 ));
  EndPaint( window, &ps );
  } break;

  default:
  return DefWindowProc( window, msg, wParam, lParam );
 }
 return 0;
}

//// window thread

DWORD WINAPI threadMain( LPVOID ) {
 WNDCLASS windowClass = { CS_NOCLOSE, windowProc, 0, 0, instance, 0,
  LoadCursor( 0, IDC_ARROW ), CreateSolidBrush( RGB( backR, backG, backB )),
  0, title };
 RegisterClass( &windowClass );
 window = CreateWindowEx( WS_EX_TOPMOST | WS_EX_TOOLWINDOW, title, title,
  WS_POPUP, initLeft, initTop, 0, 0, 0, 0, instance, 0 );
 MSG msg;
 windowReady = true;
 while ( GetMessage( &msg, window, 0, 0 ) == TRUE ) DispatchMessage( &msg );
 return 0;
}

//// main

INT WINAPI WinMain( HINSTANCE instance, HINSTANCE, LPSTR cmdLine, INT cmdShow ) {
 ::instance = instance;

 if ( !lstrlen( cmdLine )) {
  MessageBox( 0, "Please see \"readme.txt\" file for usage help.", title, MB_OK );
  return 0;
 }

 HANDLE thread = CreateThread( 0, 0, threadMain, 0, 0, 0 );
 while ( !windowReady ) Sleep( 10 );

 bool reload = true;
 while ( reload ) {

  //// load file
 
  HANDLE file;
  if (( file = CreateFile( cmdLine, GENERIC_READ, FILE_SHARE_READ, 0,
    OPEN_EXISTING, 0, 0 )) == INVALID_HANDLE_VALUE ) {
   Sleep( sleepTime );
   continue;
  }
  reload = false;

  DWORD fileSize = GetFileSize( file, 0 ), readSize;
  char* fileLines = (char*) LocalAlloc( LMEM_FIXED, fileSize + 1 );
  ReadFile( file, fileLines, fileSize, &readSize, 0 );
  CloseHandle( file );
  fileLines[ fileSize ] = 0;
  
  //// parse lines

  char* end = fileLines + fileSize;
  char* newLine;
  for ( char* line = fileLines; line < end && !reload; line = newLine ) {
   if ( !( newLine = strchr( line, '\n' ))) newLine = line + strlen( line );
   newLine[0] = 0;
   newLine++;
   if ( onceSkip ) { onceSkip--; continue; }

   //// text output
   
   if ( line[0] != '!' ) {
    if ( windowVisible ) {
     if ( windowText ) free( windowText );
     windowText = _strdup( line );
     InvalidateRgn( window, 0, TRUE );
    } else MessageBox( 0, line, title, MB_OK );
   }

   //// command

   else if ( line + 1 < end ) {
    char command = line[1];
    line += 2;
    switch ( command ) {

     //// general commands

     case 't':
     sscanf( line, "%127[^\r\n]", title );
     break;

     case 's':
     sscanf( line, "%d", &sleepTime );
     Sleep( sleepTime );
     break;

     case 'b':
     sscanf( line, "%d %d", &beepFrequency, &beepDuration );
     Beep( beepFrequency, beepDuration );
     break;

     case 'r':
     reload = true;
     break;

     case 'o': {
     unsigned __int64 onceLevelNew = 0;
     sscanf( line, "%I64d %d", &onceLevelNew, &onceSkipNew );
     if ( onceLevelNew > onceLevel ) onceLevel = onceLevelNew;
     else onceSkip = onceSkipNew;
     }
     break;

     //// unclosable window commands

     case 'i': {
     sscanf( line, "%d %d", &initLeft, &initTop );
     RECT rect;
     GetWindowRect( window, &rect );
     if ( rect.left == rect.right && rect.top == rect.bottom )
      MoveWindow( window, initLeft, initTop, 0, 0, TRUE );
     } break;

     case 'w': {
     windowVisible = true;
     sscanf( line, "%d %d %d", &windowWidth, &windowHeight, &windowMargin );
     RECT rect;
     GetWindowRect( window, &rect );
     MoveWindow( window, rect.left, rect.top, windowWidth, windowHeight, TRUE );
     ShowWindow( window, SW_SHOW );
     UpdateWindow( window );
     } break;

     case 'h':
     windowVisible = false;
     ShowWindow( window, SW_HIDE );
     break;

     case 'a':
     sscanf( line, "%1s", &align );
     InvalidateRgn( window, 0, TRUE );
     break;

     case 'f':
     sscanf( line, "%d %4s %127[^\r\n]", &fontSize, &fontStyle, &fontFace );
     InvalidateRgn( window, 0, TRUE );
     break;

     case 'c':
     sscanf( line, "%d %d %d %d %d %d", &textR, &textG, &textB,
      &backR, &backG, &backB );
     DeleteObject((HBRUSH) SetClassLong( window, GCL_HBRBACKGROUND,
      (LONG) CreateSolidBrush( RGB( backR, backG, backB ))));
     InvalidateRgn( window, 0, TRUE );
     break;

  //// finalize

  }}}
  LocalFree( fileLines );
 }

 CloseHandle( thread );
 return 0;
}
