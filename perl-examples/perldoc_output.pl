#!/usr/bin/perl

use warnings;
use strict;
# use File::Basename;

# This script is used to output 'perldoc' on Windows OS command line 
# to Desktop to learn.

my $rep_name;
sub perldoc {
	my $refdoc = shift;
	unless ( @{$refdoc} ) {
		warn "Warning: No the module has been installed in the WinOS!\n";
		exit;
	}	
	eval { open OUT_FH, '>', $rep_name; 1 };
	foreach ( @{$refdoc} ) {
		chomp;
		print OUT_FH $_, "\n";
	}
	close OUT_FH;	
	print $rep_name, " ", ( -s $rep_name)/1000, "KB";
		# dirname ($rep_name), "\n";
}

$rep_name = ($ARGV[0] =~ /(\w*)::(\w*)(::)?\w*/) ? "perlmod_$1_$2".'.txt' : 
			($ARGV[0] =~ /(\w*)/) ? "perldoc_$1".'.txt' : '';	
			
			# Condition operator is equal to the following code.
	# if ( $ARGV[0] =~ /(\w*)::(\w*)(::)?\w*/ ) {
		# $rep_name = "perlmod_$1_$2".'.txt';
	# } elsif ( $ARGV[0] =~ /(\w*)/ ) {
		# $rep_name = "perldoc_$1".'.txt';
	# }

my @docarray = `perldoc $ARGV[0]`;
perldoc (\@docarray);