# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
#set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ifq)            CMUPriQueue                ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             6          	   	   ;# number of mobilenodes
#set val(nn)             [lindex $argv 0]          ;# number of mobilenodes
set val(rp)             DSR	                   ;# routing protocol
set burst_size 		[lindex $argv 0]
#set val(sc)		"scen-20-test"		   ;#topology file

# ======================================================================
# Main Program
# ======================================================================

#puts "hops = $val(nn)"

Mac/802_11 set CWMin_ 1
Mac/802_11 set CWMax_ 2

#Mac/802_11 set basicRate_ 2e6
#Mac/802_11 set dataRate_   2e6
#Mac/802_11 set bandwidth_ 2e6

#
# Initialize Global Variables
#

#set rng [new RNG]
#$rng seed 0
# seeds the RNG heuristically;

ns-random 0
set ns_		[new Simulator]
set tracefd     [open simple.tr w]
$ns_ trace-all $tracefd


set namtrace [open out.nam w]
#$ns_ namtrace-all $nf

# set up topography object
set topo       [new Topography]

$topo load_flatgrid 2000 2000
$ns_ namtrace-all-wireless $namtrace 2000 2000

#
# Create God
#
set god_ [create-god $val(nn)]

#
#  Create the specified number of mobilenodes [$val(nn)] and "attach" them
#  to the channel. 
#  Here two nodes are created : node(0) and node(1)

# configure node

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace ON \
			 -movementTrace OFF \
			 
	for {set i 0} {$i < $val(nn) } {incr i} {
		set node_($i) [$ns_ node]	
		$node_($i) random-motion 0		;# disable random motion
	}
	
#
# Provide initial (X,Y, for now Z=0) co-ordinates for mobilenodes
#

#source $val(sc)
for {set i 0} {$i < $val(nn) } {incr i} {
		$node_($i) set X_ [expr $i*200]
		#puts [$node_($i) set X_]
		$node_($i) set Y_ 200.0
		$node_($i) set Z_ 0.0
}		

# Define node initial position in nam

for {set i 0} {$i < $val(nn)} {incr i} {

    # 20 defines the node size in nam, must adjust it according to your scenario
    # The function must be called after mobility model is defined
    
    $ns_ initial_node_pos $node_($i) 30
}

set start_time 0.0
set stop_time 100.0

set udp [new Agent/UDP]

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 512
$cbr set interval_ 0.25
$cbr set random_ 1
$cbr set maxpkts_ $burst_size
$cbr set burst_ 1
$ns_ attach-agent $node_(0) $udp

set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 512
$cbr2 set interval_ 0.25
$cbr2 set random_ 1
$cbr2 set maxpkts_ $burst_size
$cbr2 set burst_ 1

set null [new Agent/Null]
$ns_ attach-agent $node_([expr $val(nn)-1]) $null
$ns_ connect $udp $null

$cbr attach-agent $udp
$cbr2 attach-agent $udp
$ns_ at $start_time "$cbr start" 
$ns_ at [expr $start_time+1] "$cbr2 start"

proc stop {} {
    global ns_ namtrace 
    $ns_ flush-trace
    
    close $namtrace
#    exec nam out.nam &
    exit 0
}

$ns_ at [expr $stop_time+0.01] "stop"
$ns_ at [expr $stop_time+0.01] "puts \"NS EXITING...\" ; $ns_ halt"

#puts "Starting Simulation..."
$ns_ run
