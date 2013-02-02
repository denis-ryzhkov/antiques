#include <stdio.h>
#include <string.h>
#include <io.h>
#include <malloc.h>

#define STR_LEN 256
#define SAMPLE_PIXELS_OFFSET 82
#define INPUT_PIXELS_OFFSET 58
#define SAMPLE_PIXELS_SIZE 320
#define INPUT_PIXELS_SIZE 68
#define CHAR_WIDTH 12
#define CHAR_HEIGHT 16
#define DIV_WIDTH 1
#define BITS_PER_BYTE 8
#define SAMPLE_BYTES_PER_LINE 20
#define INPUT_BYTES_PER_LINE 4
#define LEFT_BIT 128
#define CHARS_C 10
#define MAX_INT 0x7FFFFFFF

char* pixels = 0;
int fonts_c = 0;

bool pixel( int font_i, int char_i, int x, int y ) {
 if ( font_i ) { // sample
  int bit_x = DIV_WIDTH + char_i * ( CHAR_WIDTH + DIV_WIDTH ) + x;
  return pixels[ bit_x / BITS_PER_BYTE + 
    ( CHAR_HEIGHT - 1 - y ) * SAMPLE_BYTES_PER_LINE
    + font_i * SAMPLE_PIXELS_SIZE ] & ( LEFT_BIT >> ( bit_x % BITS_PER_BYTE ) );
 } else // input
  return pixels[ x / BITS_PER_BYTE + ( CHAR_HEIGHT - y ) 
    * INPUT_BYTES_PER_LINE ] & ( LEFT_BIT >> ( x % BITS_PER_BYTE ) );
}

void load_bmp( const char* fn ) {
 pixels = ( char* ) realloc( pixels, ++fonts_c * SAMPLE_PIXELS_SIZE );
 FILE* f = fopen( fn, "rb" );
 bool is_input = ( fonts_c == 1 );
 fseek( f, is_input? INPUT_PIXELS_OFFSET : SAMPLE_PIXELS_OFFSET, SEEK_SET );
 fread( pixels + ( ( fonts_c - 1 ) * SAMPLE_PIXELS_SIZE ), 1,
   is_input? INPUT_PIXELS_SIZE : SAMPLE_PIXELS_SIZE, f );
 fclose( f );
}

int rel( int font_i1, int font_i2, int char_i1, int char_i2 ) {
 int r = 0;
  for ( int y = 0; y < CHAR_HEIGHT; y++ )
   for ( int x = 0; x < CHAR_WIDTH; x++ )
    if ( pixel( font_i1, char_i1, x, y ) != pixel( font_i2, char_i2, x, y ) )
     r++;
    //<<< or maybe compare squares 3x3
 return r;
}

int rel( int font_i, int char_i1, int char_i2 ) {
 int r = 0;
 for ( int font_i2 = 1; font_i2 < fonts_c; font_i2++ )
  r += rel( font_i, font_i2, char_i1, char_i2 );
  //<<< add weights for punishment
 return r;
}

int recog_char_i( int font_i, int char_i ) {
 int min_r = MAX_INT;
 int ret = 0;
 for ( int char_i2 = 0; char_i2 < CHARS_C; char_i2++ ) {
  int r = rel( font_i, char_i, char_i2 );
  if ( r < min_r ) {
   min_r = r;
   ret = char_i2;
  }
 }
 return ret;
}

int main( int argc, char** argv ) {

 load_bmp( argv[ 1 ] );

 // get native directory
 char native_dir[ STR_LEN ];
 strcpy( native_dir, argv[ 0 ] );
 *( strrchr( native_dir, '\\' ) + 1 ) = 0;

 // get sample base

 char sample_dir[ STR_LEN ];
 strcpy( sample_dir, native_dir );
 strcat( sample_dir, "sample\\" );

 char sample_filespec[ STR_LEN ];
 strcpy( sample_filespec, sample_dir );
 strcat( sample_filespec, "*.bmp" );

 _finddata_t f;
 long find_h = _findfirst( sample_filespec, &f ); // assume has samples
 do {
  char fn[ STR_LEN ];
  strcpy( fn, sample_dir );
  strcat( fn, f.name );
  load_bmp( fn );
 } while ( !_findnext( find_h, &f ) ); 
 _findclose( find_h );

 // output recognized char_i
 printf( "%i\n", recog_char_i( 0, 0 ) );

 // finalize
 free( pixels );
 return 0;
}