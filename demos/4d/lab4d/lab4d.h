/////// creoCLib lab4d, version 1.3, Denis Ryzhkov (Creon) (c) 2001

#ifndef _creoclib_lab4d_
#define _creoclib_lab4d_

#include <math.h>

bool creoclib_lab4d_orthogonal = true;
double k4d = double( 2 ) / 3;

int client_height; // set it before using obj4d.draw()

struct point4d {
 double x[4];
 double& operator[]( int i ) { return x[i]; }
 point4d( double x0 = 0, double x1 = 0, double x2 = 0, double x3 = 0 ) {
  x[0] = x0; x[1] = x1; x[2] = x2; x[3] = x3;
 }
};

struct arris {
 int k[2];
 int& operator[]( int i ) { return k[i]; }
 arris( int k0 = 0, int k1 = 0 ) { k[0] = k0; k[1] = k1; }
};

class obj4d {
public:
 point4d* x; int x_len;
 arris* ar; int ar_len;
 point4d c;

 void setShape( double* new_x, int new_x_len, int* new_ar, int new_ar_len ) {
  x_len = new_x_len; ar_len = new_ar_len;

  int siz = sizeof( double ) * 4 * x_len;
  free( x );
  x = ( point4d* ) malloc( siz );
  memcpy( x, new_x, siz );
  
  siz = sizeof( int ) * 2 * ar_len;
  free( ar );
  ar = ( arris* ) malloc( siz );
  memcpy( ar, new_ar, siz );
 }

 void moveRel( point4d r ) {
  for ( int j = 0; j < 4; j++ ) {
   for ( int i = 0; i < x_len; i++ )
    x[i][j] += r[j];
   c[j] += r[j];
  }
 }

 void move( point4d new_c ) {
  point4d r;
  for ( int j = 0; j < 4; j++ )
   r[j] = new_c[j] - c[j];
  moveRel( r );
 }
 
 void scale( double sr ) {
  for ( int i = 0; i < x_len; i++ )
   for ( int j = 0; j < 4; j++ )
    x[i][j] = c[j] + ( x[i][j] - c[j] ) * sr;
 }

private:

 void rotate2d( double& x0, double& x1, double a ) {
  double sina = sin( a );
  double cosa = cos( a );
  double new_x0 = x0 * cosa - x1 * sina;
             x1 = x0 * sina + x1 * cosa;
             x0 = new_x0;
 }

public:

 void rotate( double a[6] ) {
  for ( int i = 0; i < x_len; i++ ) {
   for ( int j = 0; j < 4; j++ ) x[i][j] -= c[j];
   rotate2d( x[i][0], x[i][1], a[0] );
   rotate2d( x[i][0], x[i][2], a[1] );
   rotate2d( x[i][0], x[i][3], a[2] );
   rotate2d( x[i][1], x[i][2], a[3] );
   rotate2d( x[i][1], x[i][3], a[4] );
   rotate2d( x[i][2], x[i][3], a[5] );
   for ( j = 0; j < 4; j++ ) x[i][j] += c[j];
  }
 }

 void draw( HDC hDC ) {
  if ( creoclib_lab4d_orthogonal ) {
   for ( int i = 0; i < ar_len; i++ ) {
    MoveToEx( hDC, floor( x[ ar[i][0] ][0] ), floor( client_height - x[ ar[i][0] ][1] ), 0 );
    LineTo( hDC, floor( x[ ar[i][1] ][0] ), floor( client_height - x[ ar[i][1] ][1] ) );
   }
  }
  
  else {
   for ( int i = 0; i < ar_len; i++ ) {
    int j0 = ar[i][0]; int j1 = ar[i][1];
    MoveToEx( hDC,
     floor( x[j0][0] - x[j0][2]*k4d - x[j0][3]*k4d ),
     floor( client_height - x[j0][1] - x[j0][2]*k4d + x[j0][3]*k4d ),
     0 );
    LineTo( hDC,
     floor( x[j1][0] - x[j1][2]*k4d - x[j1][3]*k4d ),
     floor( client_height - x[j1][1] - x[j1][2]*k4d + x[j1][3]*k4d )
    );
   }
  }
 }

 ~obj4d() {
  free( x );
  free( ar );
 }

};

class cube4d: public obj4d {
public:
 cube4d() {
  c[0] = c[1] = c[2] = c[3] = double( 1 ) / 2;
  double new_x[] = {
   0,0,0,0, 1,0,0,0, 0,1,0,0, 1,1,0,0, 0,0,1,0, 1,0,1,0, 0,1,1,0, 1,1,1,0,
   0,0,0,1, 1,0,0,1, 0,1,0,1, 1,1,0,1, 0,0,1,1, 1,0,1,1, 0,1,1,1, 1,1,1,1
  };
  int new_ar[] = {
   0,1, 0,2, 0,4, 0,8, 1,3, 1,5, 1,9, 2,3, 2,6, 2,10, 4,5, 4,6, 4,12, 5,7,
   5,13, 6,7, 6,14, 7,3, 7,15, 8,9, 8,10, 8,12, 9,11, 9,13, 10,11, 10,14, 
   11,3, 11,15, 12,13, 12,14, 13,15, 14,15
  };
  setShape( new_x, 16, new_ar, 32 );
 }
};

class tetra4d: public obj4d {
public:
 tetra4d() {
  c[0] = c[1] = c[2] = c[3] = double( 1 ) / 4;
  double new_x[] = { 0,0,0,0, 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 };
  int new_ar[] = { 0,1, 0,2, 0,3, 0,4, 1,2, 1,3, 1,4, 2,3, 2,4, 3,4 };
  setShape( new_x, 5, new_ar, 10 );
 }
};

#endif