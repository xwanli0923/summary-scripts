#!/usr/bin/perl

# Copyright (C) 2017 hfhua@biotecan.com
# Created       : 2017.8.9 15:00, HLF.
# Using Dir/File: LocisTmp, SampleList.txt
# Storage Path  : /public/home/liurui/hualf    
# Usage         : This Perl script is used to collect all positive locis and related info
#               : from the names of PositiveLoci.cfg.

# use warnings;
use strict;
use Data::Dumper;

open LOCIS, '>', 'PositiveLoci.txt' or
	die "Can't output the file: $!";

my %TargetDrug;

sub EachSampleLoci {

		# This subroutine can be used as a perl module to collect 
		# positive loci from each sample.
	
	my ($tmp, $opt) = @_;
	
	# my %TargetDrug;
	eval {
		# my @TargetDrug = `ls $tmp`;
			# Pay attention to the difference of the return for ls command between Bash shell and Perl.
			# The return for Bash shell is: ARRAY, each element is file or directory.
			# The return for Perl is: ARRAY, each element is character.
		
		open HASH, '>', 'TargetGeneDrugV2.nested.hash.txt' or 
			die "Can't output the outcome file: $!";
		opendir DIR, $tmp or 
			die "Can't open the direction $tmp : $!";

		foreach my $TargetDrug ( readdir DIR ) {
			next if ( $TargetDrug eq '.' or $TargetDrug eq '..' );
				# Directory '.' and '..' must be ignored!
				
			my @SampleName = split /\./, $TargetDrug;
				
			# Check whether the working directory is right. 
			unless ( -f $TargetDrug ) {
				print "\n===== ERROR OCCURED =====\n";
				print "The file ", $TargetDrug, " isn't in the directory!";
				print "\n===== Exitting the Perl script... =====\n";
				exit;
			# } else {
			#	print "All right: ", $TargetDrug, ". PASS\n";
			}

			open DRUG, '<', $TargetDrug or 
				die "Can't open the file $TargetDrug : $!";
				
			while (<DRUG>) {
				chomp;	
		
				next if ( $. == 1 );
					# There are special characters before title 'Type', so don't use /^Type/.
				my @capture = ( $_ =~ /^(?:.*?\t){2}(.*?)\t(.*?)\t(.*?)\t.*?SDP\t([^\s+]+)/m );
				
				# print "\nCapture elements to array is: \n";
				# print Data::Dumper->Dump( [ \@capture ], [ qw(*capture) ] ), "\n";			# debugging
				
				unless ( $capture[2] eq '' ) {
						# Create a three-dimensional hash: {...}->{...}->[...]
					push @{ $TargetDrug{ $SampleName[0] }{ $capture[0] } }, $capture[1];
					push @{ $TargetDrug{ $SampleName[0] }{ $capture[0] } }, $capture[2];
					push @{ $TargetDrug{ $SampleName[0] }{ $capture[0] } }, (split /:/, $capture[3])[6];					
				} else {
					next;
				}
			}		
		}		
		close DRUG;

		print HASH Data::Dumper->Dump( [ \%TargetDrug ], [ qw(*TargetDrug) ] ), "\n";		# debugging
		close HASH;
		
		if ( defined $opt ) {
			unless ( $opt eq '-') {
				open OUT, '>', $opt.'.loci.txt' or 
					die "Can't output the file: $!";	
				print "\n  *** The separated sample: ", $opt, " ***\n";
				
				foreach my $element ( keys %{ $TargetDrug{$opt} } ) {
					my $merge = join "\t", @{ $TargetDrug{$opt}{$element} };
					print OUT $opt, ": ", $element, " => ", $merge, "\n";
		 		}
			close OUT;
			}
		}
	};	
	print "ERROR: $@\n" if $@;
}

EachSampleLoci( $ARGV[0], $ARGV[2] );
	# $ARGV[0]: directory, which stored all *TargetGeneDrugV2*.
	# $ARGV[1]: file, which is the sample name list.
	# $ARGV[2]: character, which is the single sample name.

open NAME, '<', $ARGV[1] or die "Can't open the file $ARGV[1]: $!";
my @Name;
	# @Name is the complete name list included 73 project.
while (<NAME>) {
 	chomp;
	push @Name, $_;
}

foreach my $name (@Name) {

	if ( exists $TargetDrug{$name} ) {
		foreach my $gene ( keys %{ $TargetDrug{$name} } ) { 
			my $collect = join "\t", @{ $TargetDrug{$name}{$gene} };
			print LOCIS $name, "\t\t", $gene, "\t", $collect, "\n";
		}
	} else {
			# 73 project samples and other samples
		print LOCIS $name, "\t", "No positive locis ...\n";
	}

}
close NAME;
close LOCIS;


