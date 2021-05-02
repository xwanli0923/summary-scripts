#!/usr/bin/perl

# Edited: 2017.8.31 14:45 by HLF.
# Usage : This perl script is used to merge sample name and project.

use warnings;
use strict;

eval {
	open OUT, '>', 'MergeNameProject.txt';
	open IGNORE, '>', 'IgnoredSample.txt';
};
print "ERROR: $@\n" if ($@);

while (<>) {
	chomp;
	if (/\// or /CNVseq/ or /T12/ 
		or /G123/ or /XT/ or /S124/ or /V6/i) {
		print IGNORE $_, "\n";
		next;
	}

	# Ignore:
	#  /: not found
	#  CNVseq: germline
	#  T12: germline
	#  G123: germline
	#  sureselect XT(XT): germline
	#  S124: project is different, so ignore.
	#  V6: include health or cancer, so ignore.

	my @element = split /\s+/, $_;
	my $merge = $element[1]."/".$element[0];
	
	print OUT $merge, "\n";
}


