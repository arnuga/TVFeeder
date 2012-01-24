#!/usr/bin/perl -w

package main;
use strict;

use TVFeederApp;

$|=1; # this disables buffering

unless(caller){
	my $TVFeeder = TVFeederApp->new();
	$TVFeeder->MainLoop();
}