#!/usr/bin/perl -w
use strict;
use Tk;
use Tk::Photo;
use Tk::Font;
use Tk::Text;
use Tk::ProgressBar;
#perl2exe_bundle "YesNoTester.gif"
#perl2exe_bundle "Yes.gif"
#perl2exe_bundle "No.gif"

my $exe = $^X !~ /perl/;
my $temp = $exe? $ENV{TEMP} || $ENV{TMP} || ( $^O eq "MSWin32" ? $ENV{WINDIR} : '/tmp' ) : ".";
my ( $root ) = $exe? $0 =~ /^(.*)[\/\\]/ : "..";
my ( @quest, @answ, $quest_ind, $quest_num,
 $scale_name, @scale_names, %scale, $scale_text,
 $max_ok, $max_name, $ok_text, $bad_text, $save_text,
 $fail, $state, $i_from_n, $msg );

open( TEST, "$root/test.txt" );
while (<TEST>) {
 /^\s*([^\.\s]+)[\.\s]*(.+?)\s*$/ or next;
 my ( $id, $text ) = ( $1, $2 );
 $text =~ tr/\|/\n/;
 $id =~ /^\d+$/ and $quest[ $quest_num = $id ] = $text;
 $id eq "=" and $scale_names[ @scale_names ] = $scale_name = $text;
 if ( $id =~ /^\+|\-$/ ) {
  foreach $quest_ind ( split /[\,\.\s]+/, $text ) {
   $scale{ $scale_name }{ $quest_ind } = $id;
 }}
 $id eq ">" and do { $max_ok = $text; $max_name = $scale_name };
 $id eq "*" and $ok_text = $text;
 $id eq "#" and $bad_text = $text;
 $id eq "@" and $save_text = $text;
}
close( TEST );

sub set_msg {
 $msg->configure( -state=> "normal" );
 $msg->delete( "1.0", "end" );
 $msg->insert( "end", shift );
 $msg->configure( -state=> "disabled" );
}

sub set_bad_ok {
 $state = "bad_ok";
 $i_from_n = $fail? ":(" : ":)";
 set_msg( $fail? $bad_text : "$ok_text\n\n$scale_text" );
}

sub result {
 $fail = 0; $scale_text = "";
 foreach my $scale_name ( @scale_names ) {
  my $scale_value = 0;
  for ( $quest_ind = 1; $quest_ind <= $quest_num; $quest_ind++ ) {
   my $scale_variant = $scale{ $scale_name }{ $quest_ind };
   $scale_variant && $scale_variant eq $answ[ $quest_ind ] and
    $scale_value++;
  }
  $scale_text .= "$scale_name: $scale_value\n";
  $max_ok and $scale_name eq $max_name and $scale_value > $max_ok and $fail = 1;
 }
 set_bad_ok;
}

sub save_report {
 my $save_data = $msg->get( "1.0", "end" );
 $save_data =~ s/\s*$//;
 my ( $name ) = $save_data =~ /^.*?\:\ *(.*?)\ *\n/;
 $name or $name = time;
 open( REPORT, ">$root/reports/$name.txt" );
 my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime( time );
 print REPORT "$mday.".( $mon + 1 ).".".( $year + 1900 )."\n";
 print REPORT "$save_data\n\n";
 print REPORT "$scale_text\n";
 for ( $quest_ind = 1; $quest_ind <= $quest_num; $quest_ind++ ) {
  print REPORT "$quest_ind".$answ[ $quest_ind ]." ";
 }
 close( REPORT );
 exit;
}

sub answer {
 my $variant = shift;
 my $text;

 if ( $state eq "bad_ok" ) {
  if ( $fail ) {
   $variant eq "-" and exit;
   $quest_ind = 0;
   $state = "q";
   return answer( "+" );
  } else {
   $variant eq "-" and exit;
   $i_from_n = "...";
   set_msg( $save_text );
   $msg->configure( -state=> "normal" );
   $msg->markSet( "insert", "1.end" );
   $msg->focus;
   return $state = "@";
 }}

 elsif ( $state eq "@" ) {
  $variant eq "-" and return set_bad_ok;
  return save_report;
 }
 
 elsif ( $state eq "q" ) {
  $quest_ind or !$quest[0] or $variant eq "+" or exit;
  $quest_ind > 0 and $answ[ $quest_ind ] = $variant;
  $quest_ind >= $quest_num and return result;
  $text = $quest[ ++$quest_ind ];
  $i_from_n = "$quest_ind/$quest_num";
 }

 set_msg( $text );
}

my $mw = new MainWindow( -width=> 600, -height=> 400 );
$mw->idletasks;
$mw->iconimage( $mw->Photo( -file=> "$temp/YesNoTester.gif" ));
$mw->Photo( "Yes", -file=> "$temp/Yes.gif" );
$mw->Photo( "No", -file=> "$temp/No.gif" );
my $font = $mw->Font( -family=> "Courier", -size=> 14 );
my $mf = $mw->Frame->place( -relwidth=> 1, -relheight=> 1 );
my $top = $mf->Frame->pack( -side=> "top", -fill=> "x" );
$top->Label( -textvariable=> \$i_from_n, -font=> $font, -relief=> "groove" )->
 pack( -side=> "left" );
$top->ProgressBar( -variable=> \$quest_ind, -from=> 0, -to=> $quest_num,
 -gap=> 0, -colors=> [0, 'blue'], -takefocus=> 0 )->
 pack( -side=> "right", -fill=> "both", -expand=> 1 );
$msg = $mf->Text( -wrap=> "word", -font=> $font, -width=> 1, -height=> 1 )->
 pack( -fill=> "both", -expand=> 1 );
$mw->bind( "Tk::Text", "<3>", "" );
my $yes_no = $mf->Frame->pack( -side=> "bottom", -fill=> "x" );
$yes_no->Button( -image=> "Yes", -command=> [ \&answer, "+" ], -takefocus=> 0 )->
 pack( -side=> "left", -fill=> "both", -expand=> 1, -ipady=> 20 );
$yes_no->Button( -image=> "No", -command=> [ \&answer, "-" ], -takefocus=> 0 )->
 pack( -side=> "right", -fill=> "both", -expand=> 1 );

$quest[0] and $quest_ind = -1;
$state = "q";
answer( "+" );

MainLoop;