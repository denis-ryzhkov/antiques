function upload( filename ) {
 var fso = new ActiveXObject( "Scripting.FileSystemObject" );
 if ( !fso.FileExists( filename ) ) return "File not found";
 var ado_stream = new ActiveXObject( "ADODB.Stream" );
 ado_stream.Type = 1; // adTypeBinary

 var xml_dom = new ActiveXObject( "MSXML2.DOMDocument" );
 xml_dom.loadXML( '<' + '?xml version="1.0" ?><root/>' );
 xml_dom.documentElement.setAttribute( "xmlns:dt", "urn:schemas-microsoft-com:datatypes" );
 var xml_node = xml_dom.createElement( "file" );
 xml_node.dataType = "bin.base64";
 xml_node.setAttribute( "name", filename.substr( filename.lastIndexOf( "\\" ) + 1, filename.length - 1 ) );
 ado_stream.Open(); 
 ado_stream.LoadFromFile( filename );
 xml_node.nodeTypedValue = ado_stream.Read( -1 ); // adReadAll
 ado_stream.Close();
 xml_dom.documentElement.appendChild( xml_node );

 var xml_http = new ActiveXObject( "Microsoft.XMLHTTP" );
 xml_http.open( "POST", "/upload.php", false );
 xml_http.send( xml_dom );
 return xml_http.ResponseText;
}