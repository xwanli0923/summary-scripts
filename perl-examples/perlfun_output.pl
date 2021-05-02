#!/usr/bin/perl

use warnings;
use strict;

# This script is used to output perl function doc to 
# the desktop, and the format is 'perlfun_....txt'.
# Created on 2016.11.23 21:15 by HLF.

foreach my $fun (@ARGV) {
	open OUT, '>', 'perlfun_'.$fun.'.txt' 
		or die "Can open() output the file: $!";

	my $fun_doc = `perldoc -f $fun`;
	print OUT $fun_doc, "\n";	
	close OUT;
}
