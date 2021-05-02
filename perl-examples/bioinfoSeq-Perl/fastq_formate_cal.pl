#!/usr/bin/perl

use warnings;
use strict;

# This script is used to calculate the reads number, bases number, Q20 bases number 
# and Q30 bases number in fastq file.

open FASTQ, '<', 'part_of_C7G3BANXX.fastq' 
	or die "Don't open the fastq file: $!";
my $read_num;
my $total_base;
my $count;
my ($Q20_base, $Q30_base);
while (<FASTQ>) {
	chomp;
	$count++;
	if (/\A@/) {
		$read_num++;
	} elsif (/\A[ATGCN]+/) {
		$total_base += length $_;
	} elsif ( $count%4 == 0 ) {
		foreach my $each_base (split//,$_) {
			$Q20_base++ if ( ord($each_base)-33 > 20 );
			$Q30_base++ if ( ord($each_base)-33 > 30 );
		}
	}
}
print "Total reads: ", $read_num, "\n";
print "Total bases: ", $total_base, "\n";
print "Q20 bases: ", $Q20_base, "\nQ20%: ";
printf "%2.2f%%\n", ( $Q20_base/$total_base ) * 100;
print "Q30 bases: ", $Q30_base, "\nQ30%: ";
printf "%2.2f%%\n", ( $Q30_base/$total_base ) * 100;
close FASTQ;