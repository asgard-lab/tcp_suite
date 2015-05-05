# Go ahead and generate and R file
# Read each mu 
# obtain the average, mode, standard deviation, histogram
# exit

#!/usr/local/bin/perl
$filename = $ARGV[0];
$path="/mnt/shared/cs212A/cesar-project/data_nocontention"; 
$newfile=$filename . ".avg";
use Test;
BEGIN { plan tests => 1 } ;
use Statistics::R ;
use warnings qw'all' ;
#########################
{
  if (-e "$path/$filename") {
  print "file exists\n";
  } else { exit; } 
  open(OUT, ">>", $newfile) or die "Cannot open output file";
  my $R = Statistics::R->new() ;
  $R->startR;
  $R->Rbin;
  $R->send(qq`tmp=scan(file=\"$path/$filename\")`);
  $R->send(q`print(mean(tmp))`);
  $ret = $R->read;
  $grab  = substr($ret, 4, 100);
  print OUT "$grab\n";
  $R->send(q`print(sd(tmp))`);
  $ret = $R->read;
  $grab  = substr($ret, 4, 100);
  #print OUT "$grab\n";
  $R->stopR();
}
