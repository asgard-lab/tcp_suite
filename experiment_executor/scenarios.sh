prot=experiment01
combination="1 2 3 4 5 6 7"

for i in $combination
do
	mkdir data
	mkdir data4
	exp=$prot$i
	sh ./submit_batch$i.sh
	counter=0
	name=`date`

	while [ 1 ] 
	do 
	    test=`ps -ef | grep script.tcl | wc -l`

	    if [ "$test" -ge 2 ]; then
		let counter=counter+1
		echo "minutes = $counter"
		sleep 60
	    else 
		echo "experiment $exp done in $counter minutes" | mail -s "experiment $name" cmarcond06@gmail.com
		break;
	    fi
	done

	mkdir data5
	mkdir $exp
	gzip *.output
	mv *.output.gz data5
	mv data $exp
	mv data4 $exp
	mv data5 $exp
done
