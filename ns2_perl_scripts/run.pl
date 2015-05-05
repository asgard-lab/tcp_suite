#!/usr/local/bin/perl
#$filename = $ARGV[0];
#system "rm hist";
# $j is the burst size (range)
for ($j=2;$j<=5;$j++) {
	#print "Setting burst size as $j packets\n";	
	# $i is the # of different trials
	for ($i=1;$i<=1000;$i++) {
		#print "$i Trial\n";
		system "/mnt/shared/cs212A/ns-allinone-2.28/ns-2.28/ns wireless2.tcl $j";
		$file = "burst_{$j}_trial_{$i}.dat";
		print "filename = $file\n";
		system "mv simple.tr $file";
		#print "Process $i Trial\n";
		system "perl process.pl 6 $j $i < $file";	
	}
}
