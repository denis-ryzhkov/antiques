#include <windows.h>
#include <stdlib.h>
#include "resource.h"

#define ABSINTH "absinth"
#define WS_EX_LAYERED 0x80000
#define LWA_COLORKEY 1
#define LWA_ALPHA 2
#define START 100
#define BMP_WIDTH 800
#define BMP_HEIGHT 600
#define MAX_OFFSET 5
#define DELAY 40 // 40 == 25fps
#define ALPHA 128

HWND hWnd, hWnd2;
HBITMAP hBmp;
typedef DWORD( WINAPI* SLWA )( HWND, DWORD, BYTE, DWORD );
SLWA SetLayeredWindowAttributes;
int xo = 0, yo = 0;

void moveOffset( int* po ) {
 *po += 2 - rand() / (( (double) RAND_MAX + 1 ) / 4 );
 if ( *po > MAX_OFFSET ) *po = MAX_OFFSET;
 if ( *po < -MAX_OFFSET ) *po = -MAX_OFFSET;
}

void Paint( HWND hWnd ) {
 PAINTSTRUCT ps;
 HDC hDC = BeginPaint( hWnd, &ps );

 HDC hdcMem = CreateCompatibleDC( ps.hdc ); 
 SelectObject( hdcMem, hBmp ); 
 BitBlt( ps.hdc, 0, 0, BMP_WIDTH, BMP_HEIGHT, hdcMem, 0, 0, SRCCOPY );
 DeleteDC( hdcMem );

 EndPaint( hWnd, &ps );
}

LRESULT CALLBACK WndProc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam ) {
 switch ( msg ) {
  case WM_PAINT: Paint( hWnd ); break;
  case WM_TIMER: {
   moveOffset( &xo ); moveOffset( &yo );
   MoveWindow( hWnd2, START + xo, START + yo, BMP_WIDTH, BMP_HEIGHT, TRUE );
   break;
  }
  case WM_CLOSE: ExitProcess( 0 ); break;
  default:
   return DefWindowProc( hWnd, msg, wParam, lParam );
 }
 return 0;
}

int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
  LPSTR lpCmdLine, int nCmdShow ) {

 hBmp = LoadBitmap( hInstance, MAKEINTRESOURCE( IDB_BMP ));

 WNDCLASS wc;
 ZeroMemory( &wc, sizeof( wc ));
 wc.lpfnWndProc = ( WNDPROC ) WndProc;
 wc.hInstance = hInstance;
 wc.hIcon = LoadIcon( hInstance, MAKEINTRESOURCE( IDI_ABSINTH ));
 wc.hCursor = LoadCursor( 0, IDC_ARROW );
 wc.hbrBackground = CreateSolidBrush( RGB( 128, 128, 128 ));
 wc.lpszClassName = ABSINTH;
 RegisterClass( &wc );

 hWnd = CreateWindow( ABSINTH, ABSINTH,
  WS_POPUP,
  START, START, BMP_WIDTH, BMP_HEIGHT,
  0, 0, hInstance, 0 );
 ShowWindow( hWnd, nCmdShow );
 UpdateWindow( hWnd );

 hWnd2 = CreateWindow( ABSINTH, ABSINTH,
  WS_POPUP,
  START, START, BMP_WIDTH, BMP_HEIGHT,
  0, 0, 0, 0 );
 SetWindowLong( hWnd2, GWL_EXSTYLE, GetWindowLong( hWnd2, GWL_EXSTYLE ) | WS_EX_LAYERED );
 SetLayeredWindowAttributes = (SLWA) GetProcAddress( LoadLibrary( "user32" ), "SetLayeredWindowAttributes" );
 SetLayeredWindowAttributes( hWnd2, 0, ALPHA, LWA_ALPHA );
 ShowWindow( hWnd2, nCmdShow );
 UpdateWindow( hWnd2 );

 SetTimer( hWnd2, 1, DELAY, 0 );

 MSG msg;
 while ( true ) {
  if ( PeekMessage( &msg, hWnd, 0, 0, PM_REMOVE	) == TRUE ) DispatchMessage( &msg );
  if ( PeekMessage( &msg, hWnd2, 0, 0, PM_REMOVE ) == TRUE ) DispatchMessage( &msg );
 }

 return msg.wParam;
}
