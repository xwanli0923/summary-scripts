#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper;	# Marshalling data
# use Data::Printer;
# use YAML;
use JSON;

# The script programme should be used to evaluate the data of each base site in every index.
# The data is the standard to judge the index balance.
# Created on 2016.6.28 22:15, by Longfei_Hua.

my %index_data;
my $total_data;
eval { open OUT_FH, '>', 'index_base_distribution.txt'
	or die "Don't output the file: $!"; };
print "An ERROR: $@!\n" if ($@);

while (<>) {
	chomp;
	my ($index, $sigdata) = split;
	$index_data{$index} = $sigdata;
	$total_data += $sigdata;	
}

if ( $total_data > 0 && $total_data <= 150 ) {
	print "\n---------- Rapid SR Flow cell V2 ( 1x50 )----------\n\n";
} elsif ( $total_data >= 1000 && $total_data <= 90000 ) {
	print "\n---------- High output PE Flow cell V4 ( 2x125 )----------\n\n";
}

my %basesite_val;
for (my $i = 1; $i <= 6; $i++) {	
	my ($eachbase, $eachbase_data);	
	foreach my $barcode ( sort keys %index_data ) {
		if ( length $barcode == 6
				or length $barcode == 8 ) {
			$eachbase = ( $total_data > 0 && $total_data <= 150 ) ? ((1000 * $index_data{$barcode}/$total_data )/6) :
					    ( $total_data >= 1000 && $total_data <= 90000 ) ? ((2000 * $index_data{$barcode}/$total_data )/6) : 
					    'This data arrangement of the FC exits ERRORs!';
				# Unity of index is 'M', either FC is SR or PE.
			$eachbase_data = sprintf "%.2f", $eachbase;
		}		
		my @base = split //, $barcode;
		$basesite_val{$i}{ $base[$i-1] } += $eachbase_data;	# autovivification and hash
	}
}
print OUT_FH "1.Data::Dumper : \n", "\t", Data::Dumper->Dump(
	[ \%basesite_val ],
	[ qw(*basesite_val) ]
);

# p( %basesite_val );

# print OUT_FH "2.YAML format: \n", "\t", Dump( \%basesite_val );
print OUT_FH "3.JSON format: \n", "\t", to_json( \%basesite_val, { pretty => 1 } );
close OUT_FH;
