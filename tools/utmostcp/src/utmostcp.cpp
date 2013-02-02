#include <stdlib.h>
#include <stdio.h>
#include <io.h>
#include <string.h>

#define IN_FN argv[ 1 ]
#define OUT_FN argv[ 2 ]
#define SKIP_K argv[ 3 ]
#define INT64 __int64

int percents_c = 0;
INT64 in_size, byte_i, bads_c = 0, skip_k = 0, skip_c = 1;

int calc_percents_c() { return percents_c = ( byte_i * 100 ) / in_size; }

void print_status() {
 printf( "%i%% - %iB", calc_percents_c(), bads_c );
 if ( skip_c > 1 ) printf( " >>> %iB", skip_c );
 else printf( "\t\t\t" );
 printf( "\015" );
 fflush( stdout );
}

int main( int argc, char** argv ) {
 if ( ( argc != 3 ) && ( argc != 4 ) ) puts( "utmostcp 1.1 2002-01-07\nCopyright (C) 2003 Denis Ryzhkov ( Creon ) mail@creon.cjb.net\ndoes: utmost copy of source file to destination file or folder\nneed when: for example MPEG from bad CD\ncomment: almost as slow as effective\nusage: utmostcp <source> <destination> [<skip-coefficient>]" );
 else {
  FILE* in_f = fopen( IN_FN, "rb" );
  if ( !in_f ) printf( "can't read file \"%s\"\n", IN_FN );
  else {
   char out_fn[ _MAX_PATH ];
   strcpy( out_fn, OUT_FN );
   if ( out_fn[ strlen( out_fn ) - 1 ] == '\\' ) strcat( out_fn, IN_FN );
   FILE* out_f = fopen( out_fn, "wb" );
   if ( !out_f ) printf( "can't write file \"%s\"\n", out_fn );
   else {
    if ( argc == 4 ) skip_k = atoi( SKIP_K );
    if ( skip_k < 0 ) skip_k = 0;
    bool ok;
    in_size = _filelengthi64( _fileno( in_f ) );
    int percents_old_c = 0;
    print_status();
    for ( byte_i = 0; byte_i < in_size; byte_i++ ) {
     int buf = fgetc( in_f );
     if ( buf != EOF ) {
      if ( !ok ) { // get out of bads
       ok = true;
       skip_c = 1;
       print_status();
      } // eo get out of bads
      fputc( buf, out_f );
     } else { // skip bads
      if ( !ok && skip_k ) { // use skip_k
       skip_c *= skip_k;
       for ( INT64 skip_i = 0; ( skip_i < skip_c ) && ( byte_i < in_size ); skip_i++, byte_i++, bads_c++ )
        fputc( 0, out_f );
      } else { // no skip_k
       ok = false;
       fputc( 0, out_f );
       bads_c++;
      } // eo no skip_k
      print_status();
      fseek( in_f, byte_i + 1, SEEK_SET );
     } // eo skip bads
     if ( calc_percents_c() != percents_old_c ) {
      percents_old_c = percents_c;
      print_status();
     } // eo calc_percents_c() != percents_old_c
     fflush( out_f );
    } // eo for byte_i
    fclose( out_f );
    print_status();
    puts( "\n" );
   } // eo ok out_f
   fclose( in_f );
  } // eo ok in_f
 } // eo argc != 1
 return 0;
} // eo main
