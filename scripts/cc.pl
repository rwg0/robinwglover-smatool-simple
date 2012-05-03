#!/usr/bin/perl -w

# Reads data from a Current Cost device via serial port.

use strict;
use IO::Socket;
use IO::Select;
use threads;
use threads::shared;

my $import :shared= "0";
my $abs :shared= "0";
my $panel2 :shared= "U";
my $gen :shared = "0";
my $gentotal :shared = "U";
my $importtotal :shared= "U";
my $temp :shared = "U";
my $lock : shared = "lock";

sub processCCLine {
	(my $line) = @_;
#	print "$line\n";
    	if ($line =~ m!<time>([0-9:]+)</time>.*<tmpr> *([\-\d.]+)</tmpr>.*<sensor>(\d+)</sensor>.*(?:<ch1><watts>0*(\d+)</watts></ch1>|<imp>(\d+)</imp>)!) {
		lock($lock);
        	my $time = $1;
	        my $watts = $4;
        	$temp = $2;
	        my $sensor = $3;
		my $imp = $5;
#		print "$time, $sensor, $watts, $temp, $imp\n";
	        if ($sensor == "0") {
        	        $import = $watts;
	        }
	        if ($sensor == "1") {
        	        $abs = $watts * 1.1; # fudge for inaccuracy of the clamp sensor
	        }
        	if ($sensor == "2") {
                	$panel2 = $watts;
	        }
		if ($sensor == "9") {
			$importtotal = $imp;
		}
	}
	return 10;
}

sub processSolarLine {
	(my $line) = @_;
#    	print $line;
    	if ($line =~ m!Power=([0-9]+).*Total=([0-9\.]+).*!) {
		lock($lock);
		my $power = $1;
        	my $total = $2;
		$gen = $power;
		$gentotal = $total * 1000;
#        	print "$power $total\n";
		return 10;
	}
	return 90;
}

sub readFromPort {
	(my $sock, my $process) = @_;

	my $select = IO::Select->new($sock) or die "IO::Select $!";
	my $limit = 120;
	while (1) {
		my @ready_clients = $select->can_read($limit);
		if (@ready_clients) {
			foreach my $fh (@ready_clients)  {
				if($fh == $sock)  {
					my $line=<$sock>;
					if ($line)
					{
		    				chomp($line);
					        $limit = $process->($line);
					}
				}
			}
		} else {
			die "Read timeout from port.";
		}
	}
}

sub monitor
{
	(my $HOST, my $PORT, my $process) = @_;

	while (1)
	{
		eval {
			my $sock = new IO::Socket::INET(PeerAddr => $HOST, PeerPort => $PORT, Proto => 'tcp');
			die "Could not create socket: $!\n" unless $sock;
			readFromPort($sock, $process);
		} or do {
			my $time = localtime;
			my $err = $@;
			chomp($err);
			print "$time: Monitoring PORT=$PORT: failed with error: '$err'\n";
			sleep 15;
		}
	}
}

my $HOST = "slug";

threads->create( sub {monitor($HOST, "1100", \&processSolarLine);});
threads->create( sub {monitor($HOST, "1099", \&processCCLine);});

while (1)
{
	sleep 5;
	{
		lock($lock);		
		my $i = $import;
		my $a = $abs;
		my $g = $gen;
		my $p2 = $panel2;
		my $t = $temp;
		my $gt = $gentotal;
		my $it = $importtotal;
		if ($i > 0 && $i > $a * 4)
		{
			$i = $a; # filter out spikes in the optismart reading
		}
        	system("rrdtool update powertemp.rrd N:$i:$a:$g:$p2:$t:$gt:$it");
#        	print("rrdtool update powertemp.rrd N:$i:$a:$g:$p2:$t:$gt:$it\n");
	}

}
