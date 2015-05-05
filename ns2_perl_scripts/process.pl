#!/usr/local/bin/perl
# goal 1
# obtain the "transfer times and throughput"
# how? collect the trace and verify the instant of the first cbr (after the AODV)
#

$verify_cts = 0;
$packets = 0;
$accum_result = 0;

$number_nodes = $ARGV[0];
$number_packets = $ARGV[1];
$trial = $ARGV[2];
$filename = "data_nodes_" . $number_nodes . "_packets_" . $number_packets . "_trial_" . $trial . ".dat";
open (FILE, ">$filename");
%state_time = ();
@cur_state = (0,0,0,0,0,0,0);
$#cur_state = $number_nodes-1;
$cur_state[0] = $number_packets;
@packet_receive = ();
$#packet_receive = $number_packets-1;
for ($i=0; $i<$number_packets; $i++) {
	$packet_receive[$i] = 0;
}
%mu_files = ();
%parallel = (
	from => -1,
	to => -1,
);
%normal = (
	from => -1,
	to => -1,
);
$start_time=0;
$num_of_trans=0;
@log_state = ();

#print "$number_nodes $number_packets\n";
#print FILE "\"" . join("", @cur_state). "\"\n";

while ( <STDIN> ) {
# go to until CTS followed by a cbr
# log the time
	$line = $_;

	if ( $_ =~ /\br (\d+)\.(\d+) _(\d+)_ MAC  --- (\d+) CTS (\d+) \[(\d+) (\d+) (\d+) (\d+)\](.*)$/ ) { 
	    # $1 - seconds $2 - milliconds 
	    if ($verify_cts == 0) { $verify_cts = 1; } 
	}

	if ($verify_cts == 1) {
	    if ( $_ =~ /\bs (\d+)\.(\d+) _(\d+)_ MAC  --- (\d+) cbr (\d+)(.*)$/ ) {
		# CTS followed by cbr
		$cts_cbr = $_;	
		$verify_cts = 2;
	    }
	}
	
	$last_line = $_;

	# obtain the state space
	# [13a 1 0 800] ------- [0:0 5:0 30 1] [0] 0 0
	if ( $_ =~ /\bs (\d+)\.(\d+) _(\d+)_ MAC  --- (\d+) cbr (\d+) \[(\w+) (\d+) (\d+) (\d+)\] ------- \[(.*)\] \[(\d+)\] (.*)$/ ) {
		#print "sending one packet - from $8 to $7 $_";
	    # Change state AFTER the packet has been successfully received
#		$cur_state[$8]--;
		$from = $8; $to = $7; 
#		$cur_state[$7]++;
		$sec_to_msec = $1*1000;
		$time_send = $sec_to_msec + ($2 / 1000000);
#		print "Accum Time to Send $accum_result\n";
		# change the vector state
#		if ( $packet_receive[$11] == 0 ) {
#		    $packet_receive[$11] = $time_send;
#		}
		$num_of_trans++;
		if ( $start_time == 0 ) {
		#if ( ++$num_of_trans == 1 ) {
			$start_time = $time_send;
		} #else {
		#	print "Parallel from $from to $to\n";
		#}
	# ------- [0:0 5:0 27 4] [3] 3 0
	}
	if ( $_ =~ /\br (\d+)\.(\d+) _(\d+)_ MAC  --- (\d+) cbr (\d+) \[(\w+) (\d+) (\d+) (\d+)\] ------- \[(.*)\] \[(\d+)\] (.*)$/ ) {
		$state = join("", @cur_state);
		print FILE "\"" . $state. "\"\n";
		push @log_state, $state; 
		$cur_state[$8]--;
		$cur_state[$7]++;
		$new_state = join("", @cur_state);

		if ( --$num_of_trans == 0  ) {
			$sec_to_msec = $1 * 1000;
			$end_time = $sec_to_msec + ($2 / 1000000);
			$time = $end_time - $start_time;  
			if ( $#log_state > 0 ) {
				$time = $time / ($#log_state + 1);
			}
			$next_state = $new_state;
			#foreach $v (@log_state) {
			for ( $cnt = $#log_state; $cnt >= 0; $cnt-- ) {
				$v = $log_state[$cnt];
				print "STATE: $v -> $next_state - start $start_time  end $end_time = time $time\n";
				$file=$v."_".$next_state;
				if ( ! exists $mu_files{$file} ) {
				    	open($mu_files{$file}, ">>", "mu_state_".$v."_".$next_state.".dat");
				}
				print { $mu_files{$file} }  "$time\n";	       
				$next_state = $v;
			}
			@log_state = ();
			$start_time = $end_time;
		} 
	
		$accum_result = $accum_result + $result;
		#print "Accumulated Result is $accum_result\n";	
		# obtain the time
	}	
}
print FILE "\"" . join("", @cur_state). "\"\n";

	#print "$cts_cbr";
	if ( $cts_cbr =~ /\bs (\d+)\.(\d+) _(\d+)_ MAC  --- (\d+) cbr (\d+)(.*)$/ ) {
		$sec_to_msec = $1 * 1000;
		$first = $sec_to_msec + ($2 / 1000000);
	}

	#print "$last_line";
	if ( $last_line =~ /\b[rs] (\d+)\.(\d+) (.*)$/ ) {
		$sec_to_msec = $1 * 1000;
		$second = $sec_to_msec + ($2 / 1000000);
	}

$result = $second - $first;
#print "Result $number_nodes $number_packets (ms) = $result\n";
#print "Throughput (bps) = $packets\n";

close(FILE);
# goal 2
# obtain the "loss probability"
# how? enumerate the retransmissions
#
# goal 3
# obtain the "state space pattern"
# how? verify the movement of packet in the net (represent as the same state space representation)
