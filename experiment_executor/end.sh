mkdir data5
gzip *.output
mv *.output.gz data5
mkdir exp3
mv data* exp3
mkdir data
mkdir data4

# watch -n 2 "ps -ef | grep script.tcl | grep -v grep"
