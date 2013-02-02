 // <<< test output
 /*
 {

  for ( int y = 0; y < CHAR_HEIGHT; y++ ) {
   for ( int x = 0; x < CHAR_WIDTH; x++ )
    putchar( pixel( 0, 0, x, y )? '·' : '#' );
   puts( "" );
  }
  puts( "" );  

 } {

  for ( int char_i = 0; char_i < CHARS_C; char_i++ ) {
   for ( int y = 0; y < CHAR_HEIGHT; y++ ) {
    for ( int font_i = 1; font_i < fonts_c; font_i++ ) {
     for ( int x = 0; x < CHAR_WIDTH; x++ )
      putchar( pixel( font_i, char_i, x, y )? '·' : '#' );
     putchar( ' ' );
    }
    puts( "" );
   }  
   puts( "" );
  }

 }
 */
