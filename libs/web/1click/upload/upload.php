<?
 if ( $HTTP_SERVER_VARS[ "REQUEST_METHOD" ] == "POST" ) {
  $s = $HTTP_RAW_POST_DATA; // name="filename">content</file>
  if ( ( $p1 = strpos( $s, " name=" ) ) !== false ) { // ereg fails with big strings
   $p1 += 7; // first char of filename
   if ( ( $p2 = strpos( $s, "\"", $p1 ) ) !== false ) {
    $filename = substr( $s, $p1, $p2 - $p1 );
    $p1 = $p2 + 2; // first char of content
    if ( ( $p2 = strpos( $s, "</file>", $p1 ) ) !== false ) {
     $content = substr( $s, $p1, $p2 - $p1 );
     $content = base64_decode( $content );
     $root = $HTTP_SERVER_VARS[ "DOCUMENT_ROOT" ];
     $f = fopen( "$root/$filename", "wb" );
     fwrite( $f, $content, strlen( $content ) );
     fclose( $f );
     echo "OK";
    }
   }
  }
 }
?>