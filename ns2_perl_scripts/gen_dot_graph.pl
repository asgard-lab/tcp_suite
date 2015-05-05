$packets = $ARGV[0];
%draw_state = ();

sub draw
{
    my @nodes = @_;
    my $size = @nodes;
    my $i;

    if ( exists $draw_state{join("",@nodes)} ) {
	return;
    }
    $draw_state{join("",@nodes)} = 1;

    for ( $i = 0; $i < $size-1; $i++ ) {
	if ( $nodes[$i] > 0 ) {
	    @tmp = @nodes;
	    $tmp[$i]--;
	    $tmp[$i+1]++;
	    print "\t<@nodes> -> <@tmp>\n";
	    draw(@tmp);
	}
    }
}

@n = ($packets, 0, 0, 0, 0, 0);

print "digraph layout\n{\n";
print "\tnode [\n";
print "\t\tstyle=filled\n";
print "\t];\n";
draw(@n);
print "\n}\n";
