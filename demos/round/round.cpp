/////// round button example, version 1.0, Denis Ryzhkov (Creon) (c) 2001

#include <windows.h>
#include <wingdi.h>

#define round "round"
#define w 150 // width
#define h 80 // height

HINSTANCE hInstance;

LRESULT CALLBACK WndProc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam );

int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
                   LPSTR lpCmdLine, int nCmdShow ) {

 ::hInstance=hInstance;

 WNDCLASS wc;
 wc.style = CS_VREDRAW | CS_HREDRAW;
 wc.lpfnWndProc = ( WNDPROC ) WndProc;
 wc.cbClsExtra = 0;
 wc.cbWndExtra = 0;
 wc.hInstance = hInstance;
 wc.hIcon = 0;
 wc.hCursor = LoadCursor( 0, IDC_ARROW );
 wc.hbrBackground = ( HBRUSH ) COLOR_WINDOW;
 wc.lpszMenuName = 0;         
 wc.lpszClassName = round;
 RegisterClass( &wc );

 RECT r;
 GetWindowRect( GetDesktopWindow(), &r );
 HWND hWnd = CreateWindow( round, round,
  WS_OVERLAPPEDWINDOW,
  r.right / 2 - w / 2, r.bottom / 2 - h / 2, w, h,
  0, 0, hInstance, 0 );
 ShowWindow( hWnd, nCmdShow );
 UpdateWindow( hWnd );

 MSG msg;
 while ( GetMessage( &msg, hWnd, 0, 0 ) == TRUE ) DispatchMessage( &msg );

 return msg.wParam;
}

LRESULT CALLBACK WndProc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam ) {

 switch ( msg ) {

  case WM_SIZE:
   RECT r;
   GetWindowRect( hWnd, &r );
   SetWindowRgn( hWnd, CreateEllipticRgn( 0, 0, r.right - r.left, r.bottom - r.top ), TRUE );
  break;

  case WM_DESTROY:
   PostQuitMessage( 0 );
  break;

  default:
   return DefWindowProc( hWnd, msg, wParam, lParam );
 }

 return 0;
}