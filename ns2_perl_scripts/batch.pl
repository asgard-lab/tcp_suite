#!/usr/local/bin/perl
use POSIX qw(ceil floor);

$start = $ARGV[0];
$end = $ARGV[1];

# $j is the burst size (range)
for ($j=$start;$j<=$end;$j++) {
	system "perl gen_dot_graph.pl $j > original$j.dot";
	#print "Setting burst size as $j packets\n";	
	# $i is the # of different trials
	for ($i=1;$i<=1000;$i++) {
		#print "$i Trial\n";
		#system "/mnt/shared/cs212A/ns-allinone-2.28/ns-2.28/ns wireless2.tcl $j";
		$file = "burst_{$j}_trial_{$i}.dat";
		#print "Processing filename = $file\n";
		#system "mv simple.tr $file";
		#print "Process $i Trial\n";
		system "perl process.pl 6 $j $i < $file";	
	}
}

# second phase
# get the distribution of number nodes and number of packets

for ($j=$start;$j<=$end;$j++) {
	system "cat data_nodes_6_packets_" . $j . "_trial* > " . $j . "packets"; 
	system "sort -r " . $j . "packets | uniq -c > dist" . $j . " "; 

# process the averages and stuff
	open(IN, "dist$j");
	open(HEAD, ">>head$j.txt");
	while(<IN>) {
		#print "$_"; 
		if ($_ = /(.*)"(\d+)"(.*)/) {
			# Frequency of that state
			print "$1\n";
			
			# State
			print "$2\n";
			# Go ahead and process this file
			@array = split(//, $2);
			$freq = ceil($1/100) -1;
			if ($freq == 0) { $freq = 1; }
			$result = sprintf("\t\t<%d %d %d %d %d %d> [\n\t\tcolor=\"1.0 .$freq 1.0\"\n\t\t];",$array[0],$array[1],$array[2],$array[3],$array[4],$array[5]);
			print HEAD "$result\n";
		#	system "perl avg.pl mu_state_$2.dat";	
		}
	}
	close(IN);
	close(HEAD);
	system("for i in `ls mu*.dat`; do awk 'BEGIN{tot=0;cnt=0}{cnt=cnt+1;tot=tot+\$1;}END{print tot/cnt}' \$i > \$i.avg; done");
	system("perl parse_dot.pl $j < original$j.dot > result$j.dot");
}
