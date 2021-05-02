#!/usr/bin/perl

# Copyright (C) 2017.8.19 12:50 hfhua@biotecan.com (HLF)
# Using file: RawIndex{1~6}.txt, IndexList.txt
# Usage: 
# 	Checking indexes of samlplesheet for running NextSeq CN500 is repeating and conflicting or not.
#	
#	perl BiotecanIndexDebug.pl

##################################################################
# Please pay attention to following information:				 #
# [ ERROR ]	 : An important error, you must deal with at once.   #
# [ CAUTION ]: You should know that to deal with error.			 #
# [ INFO ]	 : An universal information.						 #
# [ PASS ]	 : A good result you want.							 #
##################################################################

use warnings;
use strict;
# use Data::Dumper;
# use JSON;

# Step 1. To create six index libraries hash, according to conflicting index sheet.
my @SetIndexLib;
	# open ARRAY, '>', 'NestedIndexHash.txt' or
	# 	die "Can't output the file: $!";

foreach my $file (qw/RawIndex1.txt RawIndex2.txt RawIndex3.txt 
				  RawIndex4.txt RawIndex5.txt RawIndex6.txt/) {

	my %IndexLib;	
	my $basename = (split /\./, $file)[0];

	open IN, '<', $file or die "Can't open the file: $!";
		# open OUT, '>', $basename.".hash.txt" or die "Can't output the file: $!";

	while (<IN>) {
		chomp;
		my @element = split /\s+/, $_;
		push @{ $IndexLib{ $element[0] } }, $element[1];
		push @{ $IndexLib{ $element[0] } }, $element[2];
		push @{ $IndexLib{ $element[0] } }, $element[3];
	}

		# print OUT Data::Dumper->Dump( [ \%IndexLib ], [ qw(*IndexLib) ] ), "\n";	# debugging
		# print to_json( \%IndexLib, { pretty => 1 } ), "\n";						# debugging

	close IN;
		# close OUT;

	push @SetIndexLib, \%IndexLib;
}

	# print ARRAY to_json( \@SetIndexLib, { pretty => 1 } ), "\n";					    # debugging
	# print ARRAY Data::Dumper->Dump( [ \@SetIndexLib ], [ qw(*SetIndexLib)] ), "\n";	# debugging
	# close ARRAY;

print "\n*** All right. Pass! ***\n";	
print "========== Create index libs completely! ==========\n\n";



# Step 2. Check whether there is the same index in the index list for running.
open INDEX, '<', 'IndexList.txt' or
	die "Can't open the file: $!";

my (@IndexList, %CountIndex, @SepIndex);
while (<INDEX>) {
	chomp;
	push @IndexList, $_;
}

%CountIndex = map { $_ => $CountIndex{$_}++; } @IndexList;
	# print Data::Dumper->Dump( [ \@IndexList], [ qw(*IndexList) ] ), "\n";			# debugging
	# print Data::Dumper->Dump( [ \%CountIndex ], [ qw(*CountIndex) ] ), "\n";		# debugging

my $num = 0;
foreach my $repeat ( keys %CountIndex ) {
	unless ( $CountIndex{$repeat} == 0 ) {
		print "[ ERROR ] Index repeat => \"$repeat\" \n";
		$num++;		
	}
}
	
if ( $num == 0 ) {
	print "*** All right. Pass! ***\n";
} else {
	print "\n[ CAUTION ] Please check the sample sheet: Existing repeating index!\n";
	print "========== ERROR occured. No check confilcting index. Exit... ==========\n";
	exit;
}

foreach my $single (@IndexList) {
	if ( $single =~ /\//) {
		my @list = split /\//, $single;
		unless ( $list[1] eq 'MID') {
			my $sgl = "D".$list[1];
			push @SepIndex, $list[0];
			push @SepIndex, $sgl;
		} else {
			push @SepIndex, $list[0];
		}
	} else {
		push @SepIndex, $single;
	}
}
	# print Data::Dumper->Dump( [ \@SepIndex], [ qw(*SepIndex) ] ), "\n";		# debugging

print "========== Check the same index completely! ==========\n\n";


# Step 3. Check the confilcting index.
foreach my $index (@SepIndex) {

	foreach my $hash (@SetIndexLib) {
		my $pair = $hash->{$index}->[1];
			# check the pair of confilcting index
			
		if ( defined $pair ) {
			if ( exists $CountIndex{$pair} ) {
				print "*** [ ERROR ] Existing conflicting index in sample sheet: $index <=> $pair ***\n";
				print "\n[ CAUTION ] Please check the sample sheet: Existing conflicting index!\n";
				print "========== ERROR occured. Exit... ==========\n";
				exit;
			} else {
				print "[ INFO ] Existing conflicting index in sample sheet: <$index>. But no problem!\n";
			}
		} else {
			print "[ INFO ] No conflicting index with $index\n";
		}
	}
	print "\n";

}

print "[ PASS ] If you havn't seen any [ ERROR ], that's all right. Pass!\n";
print "\n========== All analysis completely! ==========\n";


