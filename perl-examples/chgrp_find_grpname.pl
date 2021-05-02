#!/usr/bin/perl

use warnings;
use strict;

# This script is used to find wheather the name which the user has inserted
# on command line is in /etc/group ,when we use "chgrp" command.

my $existence; 
my $change_name = $ARGV[0];
open INPUT, '<', '/etc/group' or die "Dont't open the file: $!";
while (<INPUT>) {
	if ( $change_name eq (split /:/)[0]) {
		$existence = 1;
		print "\"$change_name\" has been here!\n";
		last;
	}
}
unless (defined $existence) {
	print "No the group name!\n";
}
close INPUT;