/////// lab4d example, version 1.3, Denis Ryzhkov (Creon) (c) 2001

#include <windows.h>
#include "lab4d.h"

double dr = 5; // delta moveRel
double dsr = 0.1; // delta scale
double da = 0.05; // delta rotate

HINSTANCE hInstance;
int scr_xc, scr_yc;
HPEN hPen;

cube4d cube;
tetra4d tetra;
obj4d* obj;

LRESULT CALLBACK WndProc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam );

///
/// WinMain
///
int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
                    LPSTR lpCmdLine, int nCmdShow ) {
 ::hInstance=hInstance;

 WNDCLASS wc;
 wc.style = CS_VREDRAW | CS_HREDRAW;
 wc.lpfnWndProc = (WNDPROC) WndProc;
 wc.cbClsExtra = 0;
 wc.cbWndExtra = 0;
 wc.hInstance = hInstance;
 wc.hIcon = 0;
 wc.hCursor = 0;
 wc.hbrBackground = CreateSolidBrush( RGB( 0, 0, 0 ) );
 wc.lpszMenuName = 0;         
 wc.lpszClassName = "lab4d_xmp";
 if ( !RegisterClass( &wc ) ) return 0;

 HWND hWnd = CreateWindow( "lab4d_xmp", "lab4d example",
  WS_POPUP,
  0, 0, 300, 300,
  0, 0, hInstance, 0 );
 if ( !hWnd ) return 0;

 ShowWindow( hWnd, SW_MAXIMIZE );
 RECT r;
 GetClientRect( hWnd, &r );
 client_height = r.bottom;
 scr_xc = r.right / 2;
 scr_yc = r.bottom / 2;
 point4d c( scr_xc, scr_yc, 0, 0 );
 int sr = 100;
 cube.move( c ); cube.scale( sr );
 tetra.move( c ); tetra.scale( sr );
 obj = &cube;
 hPen = CreatePen( PS_SOLID, 1, RGB( 0, 255, 0 ) );
 UpdateWindow( hWnd );
 ShowCursor( 0 );

 SetTimer( hWnd, 1, 100, 0 );

 MSG msg;
 while ( GetMessage( &msg, hWnd, 0, 0 ) == TRUE ) {
  TranslateMessage( &msg );
  DispatchMessage( &msg );
 }

 KillTimer( hWnd, 1 );
 DeleteObject( hPen );
 DeleteObject( wc.hbrBackground );

 return msg.wParam;
}

///
/// WndProc
///
LRESULT CALLBACK WndProc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam ) {
 switch ( msg ) {
  
  case WM_PAINT: {
   PAINTSTRUCT ps;
   HDC hDC = BeginPaint( hWnd, &ps );
   SelectObject( hDC, hPen );
   obj->draw( hDC );
   EndPaint( hWnd, &ps );
  } break;

  case WM_TIMER: {
   unsigned char key[256];
   GetKeyboardState( ( unsigned char* ) &key );

   // select orthogonal
   if ( key[ '0' ] & 128 ) creoclib_lab4d_orthogonal = true;
   if ( key[ '9' ] & 128 ) creoclib_lab4d_orthogonal = false;

   // select obj
   if ( key[ '1' ] & 128 ) obj = &cube;
   if ( key[ '2' ] & 128 ) obj = &tetra;

   // moveRel
   point4d r;
   if ( key[ 'J' ] & 128 ) r[0] = dr;
   if ( key[ 'M' ] & 128 ) r[0] = -dr;
   if ( key[ 'K' ] & 128 ) r[1] = dr;
   if ( key[ 188 ] & 128 ) r[1] = -dr; // ,
   if ( key[ 'L' ] & 128 ) r[2] = dr;
   if ( key[ 190 ] & 128 ) r[2] = -dr; // .
   if ( key[ 186 ] & 128 ) r[3] = dr;  // ;
   if ( key[ 191 ] & 128 ) r[3] = -dr; // /
   obj->moveRel( r );

   // scale
   double sr = 1;
   if ( key[ 221 ] & 128 ) sr += dsr;  // ]
   if ( key[ 222 ] & 128 ) sr -= dsr;  // '
   obj->scale( sr );

   // rotate
   double a[] = { 0,0,0,0,0,0 };
   if ( key[ 'A' ] & 128 ) a[0] = da;
   if ( key[ 'Z' ] & 128 ) a[0] = -da;
   if ( key[ 'S' ] & 128 ) a[1] = da;
   if ( key[ 'X' ] & 128 ) a[1] = -da;
   if ( key[ 'D' ] & 128 ) a[2] = da;
   if ( key[ 'C' ] & 128 ) a[2] = -da;
   if ( key[ 'F' ] & 128 ) a[3]= da;
   if ( key[ 'V' ] & 128 ) a[3]= -da;
   if ( key[ 'G' ] & 128 ) a[4] = da;
   if ( key[ 'B' ] & 128 ) a[4] = -da;
   if ( key[ 'H' ] & 128 ) a[5] = da;
   if ( key[ 'N' ] & 128 ) a[5] = -da;
   obj->rotate( a );

   InvalidateRect( hWnd, 0, TRUE );
  } break;
  
  case WM_DESTROY:
   PostQuitMessage( 0 );
  break;

  default:
   return DefWindowProc( hWnd, msg, wParam, lParam );
 }
 return 0;
}