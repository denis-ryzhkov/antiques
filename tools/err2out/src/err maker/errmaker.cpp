#include <stdio.h>

int main( int argc, char* argv[] ) {
 fprintf( stdout, "stdout test\n" );
 fprintf( stderr, "stderr test\n" );
 for( int i = 0; i < argc; i++ )
  printf( "argv[ %i ]=\"%s\"\n", i, argv[i] );
 return 0;
}