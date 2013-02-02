<?
 ignore_user_abort( false );
 ob_implicit_flush( true );
 define( "GH_COLOR", GREEN_COLOR );
 define( "MAX_LENGTH", "128" );
 define( "FILMS_FN", "/var/lib/ghd/cat/films" );

 $needle = str_replace( "\\\\", "\\",
 	substr( $_REQUEST[ "gh" ], 0, MAX_LENGTH ));
 $section = $needle[0] == "!" ? substr( $needle, 1 ) : "";
?>
<form name="gh_form" method="get">
 <table width="100%" height="50" border="0" cellspacing="0" cellpadding="0">
  <tr>
   <td width="<?=SPACE ?>">&nbsp;</td>
   <td width="1" valign="bottom"><a href="/?gh"><font size="5"
     color="<?=GH_COLOR ?>"><b>G</b>rep<b>H</b>ood</font></a></td>
   <td width="<?=SPACE ?>">&nbsp;</td>
   <td align="center" valign="top" nowrap>

<?
 while( tab( "menu" )) { ?>
<a href="/?gh<?
  if ( $tab["name"] ) echo "=!";
  echo $tab["name"] ?>"><?
  if ( $tab["name"] == $section ) {
    ?><font color="<?=HEADER_COLOR ?>" size="+1"><b><?=$tab["title"]
    ?></b></font><?
  } else echo $tab["title"] ?></a> |
<?
 } ?>
<a href="http://devil/topic.php?id=58">обсудить</a>

<? if ( !$section ) { ?>
<br><input id="gh" name="gh" maxlength="<?=MAX_LENGTH ?>"<?
  if ( $needle != "" and !$section ) { ?> value="<?=$needle ?>"<? }
  ?> size="48" class="in"><input
  type="submit" value="" class="in" style="width: <?=IN_CONTROL_SIZE ?>">
<? } ?>

   </td>
  </tr>
 </table>
</form>

<?
 if	( $section == "hint" ) include( "$dir_name/hint.php" );
 
 elseif	( $section == "films" ) { ?>
<pre><font face="<?=FIXED_FONT_NAME ?>" style="font-size: <?=FONT_SIZE ?>"><?
  include( FILMS_FN );
?></font></pre><?
 
 } elseif ( $needle != "" ) {
  $gh_viewd = $pid = "";
  function dying() {
   global $gh_viewd, $pid;
   if ( $pid ) exec( "kill $pid 2>/dev/null" );
   if ( $gh_viewd ) pclose( $gh_viewd ); $gh_viewd = "";
  }
  register_shutdown_function( dying );
  $gh_viewd = popen( "/usr/bin/nice -n 19 /usr/local/ghd/gh-viewd ".
    escapeshellarg( $needle ), "r" );
  $pid = chop( fgets( $gh_viewd )); ?>

<pre><font face="<?=FIXED_FONT_NAME ?>" style="font-size: <?=FONT_SIZE ?>"><?
  fpassthru( $gh_viewd );
  $gh_viewd = "";
?></font></pre><?
 }
?>

<?
 if ( $needle == "" ) echo_focus( "gh_form.gh" );
?>
