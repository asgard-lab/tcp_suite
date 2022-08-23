TOPO="random"
NW_SIZE="5"
CAPACITY="1000"
DELAY="15"
SHORT_LIVED="100"
LONG_LIVED="40"
SEEDS="1 2 3 4"

for l in $LONG_LIVED
do
	mkdir model
	for c in $SEEDS
	do
		echo "nlong_lived=$l seed=$c"
		python3 topogen.py $TOPO $NW_SIZE 0 $CAPACITY $DELAY $l $SHORT_LIVED p2p
		size=$((NW_SIZE-1))
		perl ./generate_link.pl $size
		mv model-flow model/flow-$c
		mv model-link model/link-$c
		mv model-rtt model/rtt-$c
		mv model-topology model/topology-$c
	done
	mv model slived_$SHORT_LIVED\_llived$l
	sleep 2
done
