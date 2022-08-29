mkdir data5
gzip *.output
mv *.output.gz data5
mkdir exp6
mv data* exp6
mkdir data
mkdir data4

# watch -n 2 "ps -ef | grep script.tcl | grep -v grep"
