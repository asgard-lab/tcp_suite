$num = $ARGV[0];
open(IN,"head$num.txt");
while ( <STDIN> ) {
    $line = $_;

    if ( $line =~ /^\s*<(\d) (\d) (\d) (\d) (\d) (\d)> -> <(\d) (\d) (\d) (\d) (\d) (\d)>.*$/ ) {
	$state = $1.$2.$3.$4.$5.$6;
	$to = $7.$8.$9.$10.$11.$12;

	$avg = "0";	
	chop $line;

	if ( -e "mu_state_".$state."_".$to.".dat.avg" ) {
	    open(FILE, "mu_state_".$state."_".$to.".dat.avg");
	    $avg = <FILE>;
	    chop $avg;
	    print <FILE>;
	    close(FILE);
	} 
	print $line." [label=\"".$avg."ms\"]\n";
    } else {
	print $line;
	
	if ( $line =~ /];/ ) {
		print <IN>;
    	}
    }
}
