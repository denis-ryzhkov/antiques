#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <process.h>

int main( int argc, char** argv ) {
 if ( argc < 2 ) puts( "err2out is stdERR TO stdOUT redirector, version 2.2\nCopyright (c) 2002-2003 Denis Ryzhkov ( Creon )\nhttp://creon.cjb.net/?soft/err2out\n\nExamples:\nerr2out \"C:\\Program Files\\jdk\\bin\\javac\" Some.java | more\nerr2out \"C:\\Program Files\\jdk\\bin\\javac\" Some.java > err.txt\nerr2out \"C:\\Program Files\\jdk\\bin\\javac\" Some.java >> err.txt" );
 else {
  _dup2( 1, 2 ); // redirect 2=stderr to 1=stdout
  char** argz = new char*[ argc ]; // -argv[ 0 ], +end0
  argz[ argc - 1 ] = 0; // end0
  for ( int i = 0; i < argc - 1; i++ )
   sprintf( argz[ i ] = new char[ strlen( argv[ i + 1 ] ) + 3 ], // \" \" \000
     "\"%s\"", argv[ i + 1 ] );
  _spawnv( _P_WAIT, argv[ 1 ], argz );
  for ( i = 0; i < argc - 1; i++ ) delete[] argz[ i ];
  delete[] argz;
 }
 return 0;
}
