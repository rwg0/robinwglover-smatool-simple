#!/usr/bin/perl -w

# Reads data from a Current Cost device via serial port.

use strict;
use IO::Socket;
use IO::Select;
use threads;
use threads::shared;

my $import :shared= "U";
my $abs :shared= "U";
my $panel2 :shared= "U";
my $gen :shared = "0";
my $gentotal :shared = "U";
my $importtotal :shared= "U";
my $temp :shared = "U";

sub processCCLine {
	(my $line) = @_;
#	print "$line\n";
    	if ($line =~ m!<time>([0-9:]+)</time>.*<tmpr> *([\-\d.]+)</tmpr>.*<sensor>(\d+)</sensor>.*(?:<ch1><watts>0*(\d+)</watts></ch1>|<imp>(\d+)</imp>)!) {
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
        	        $abs = $watts;
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
		my $power = $1;
        	my $total = $2;
		$gen = $power;
		$gentotal = $total;
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
	    				chomp(my $line=<$sock>);
				        $limit = $process->($line);
				}
			}
		} else {
			$gen = "U";
			$gentotal = "U";
			die "Read timeout.";
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
			print "failed with error $@\n";
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
        system("rrdtool update powertemp.rrd N:$import:$abs:$gen:$panel2:$temp:$gentotal:$importtotal");
#        print("rrdtool update powertemp.rrd N:$import:$abs:$gen:$panel2:$temp:$gentotal:$importtotal\n");

}
