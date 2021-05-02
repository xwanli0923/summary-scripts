#!/usr/bin/perl
#
#   Created on 2017-08-12 20:00 by hualf.
#   Usage: The Perl web scrapy is used to scrapy images from https://www.nvshens.com/g/<groupNumber>
#   e.g, https://www.nvshens.com/g/23589/	8 .
#

use warnings;
use strict;
use Data::Dumper;
use LWP::Simple;

print "Please type the website which you want to scrapy: ";
chomp(my $url = <STDIN>);
print "Please type the pages of pictures: ";
chomp(my $page = <STDIN>);

my @url;
my $i = 1;

while ($i <= $page) {	
	# Generate the set of series of urls.					
	my $mergeURL = $url.$i.'.html';
	print $mergeURL, "\n";
	push @url, $mergeURL;
	$i++;
}

print "The index pages \@url are: \n";	
print Data::Dumper->Dump([ \@url ], [ qw(*url) ]), "\n\n";

my $count = 0;
foreach my $webSite (@url) {
	# Enter the each website to catch the images which you want.
	print "Now scrapying $webSite ... \nBe patient, waiting...\n";
	my $html = get($webSite);
	my @catch = ($html =~ /<img .*?(https:.*?\/(?:\d+|s)\/\d+\.jpg).*?\/>/g);
	# Catch the image websites from $webSite.
	print Data::Dumper->Dump([ \@catch ], [ qw(*catch) ]), "\n";
	unless (@catch) {
		# Testing: if @catch is undef, the image website hasn't been scrapied.
		print "Scrapying failure ...\n";
		exit;
	}		
	
	foreach my $jpg (@catch) {		
		# Save the images from the image every website.
		$count++;
		open FILE, '>', $count.'.jpg' or die "Can't output the ${i}.jpg: $!";	
		my $outcome = get($jpg);
		binmode(FILE);
		print FILE $outcome;		
	}	
}

print "****** Scrapying successfully ! ******\n";


