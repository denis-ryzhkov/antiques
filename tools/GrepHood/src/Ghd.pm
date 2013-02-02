#!/usr/bin/perl
package Ghd;
use strict;
use warnings;
use Exporter; our @ISA = qw( Exporter ); our @EXPORT = qw(
 $app_dir $conf_dir $cat_dir $smb_dir $tmp_dir $tail
 $ifconfig $arp $nmblookup $touch $echo $smbclient $pidof
 ping pinged open_log print_log quote quote_url group3
);

#### variables

our $app_dir = "/usr/local/ghd";
our $conf_dir = "$app_dir/conf";
our $var_dir = "/var/lib/ghd";
our $cat_dir = "$var_dir/cat";
our $log_dir = "$var_dir/log";
our $smb_dir = "$var_dir/smb";
our $tmp_dir = "$var_dir/tmp";
our $tail = "-U GrepHood -N -s $conf_dir/smb 2>/dev/null";
our $ifconfig = "/sbin/ifconfig";
our $arp = "/usr/sbin/arp";
our $nmblookup = "/usr/bin/nmblookup";
our $touch = "/usr/bin/touch";
our $echo = "/bin/echo";
our $smbclient = "/usr/bin/smbclient";
our $pidof = "/bin/pidof";

#### ping
  
use Net::Ping;
our $pinger = Net::Ping->new();
$pinger->{port_num} = getservbyport( 139, "tcp" );
sub ping($) { $pinger->ping( shift, 0.25 )? 1 : 0 }

#### print_log

sub print_log( $ ) {
 my @t = localtime time;
 printf STDERR "[%d-%02d-%02d %02d:%02d:%02d] %s\n",
   1900 + $t[5], 1 + $t[4], reverse( @t[ 0 .. 3 ] ), shift;
}

#### open_log

sub open_log( $ ) {
 my $who = shift;
 my $fn = "$log_dir/gh-".$who."d";
 open STDERR, ">>$fn";
 chmod 0660, $fn;
 print STDERR "\n".( "-"x80 )."\n";
 print_log "start of GrepHood $who daemon";
}

#### quote

sub quote( $ ) {
 ( my $what = shift ) =~ s/'/'\\''/g;
 return "'$what'";
}

#### quote_url

sub quote_url( $ ) {
 local $_ = shift;
 s/\\/\//g;
 s/#/%23/g;
 s/&/%26/g;
 s/\+/%2B/g;
 return $_;
}

#### group3

sub group3( $ ) {
 local $_ = shift;
 1 while s/(\d)(\d{3})(?!\d)/$1,$2/;
 return $_;
}
