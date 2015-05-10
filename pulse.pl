#!/usr/bin/perl
# ADT Pulse CGI Script
# (c) 2014, Christopher "ScribbleJ" Jansen
# scribblecj@gmail.com
#
# This script accesses ADT Pulse home automation devices.
#
# This program is not in any way endorsed by ADT or even by its author.  Use at your own risk.
#
#
use WWW::Mechanize;
use WWW::Mechanize::TreeBuilder;
use FileHandle;
use CGI;
use strict;

my $mech = new WWW::Mechanize;
WWW::Mechanize::TreeBuilder->meta->apply($mech);

# Possible config file locaitons:
my $fn;
if(-e "pulse.conf")
{
  $fn = "pulse.conf";
}
elsif(-e "~/.pulse.conf")
{
  $fn = "~/.pulse.conf";
}
elsif(-e "/etc/pulse/pulse.conf")
{
  $fn = "/etc/pulse/pulse.conf";
}


my $cgi = new CGI;
my $params = $cgi->Vars;
my $op = $params->{'OP'};

print $cgi->header("Content-type" => 'text/plain');

# Allow username/password to come from web, or local config.
my %conf;
if($params->{'PASS'} and $params->{'USER'})
{
  $conf{username} = $params->{'USER'};
  $conf{password} = $params->{'PASS'};
}
else
{
  if(!$fn)
  {
    print("Missing config file and no username/password provided.\n");
    exit;
  }

  my $fh = new FileHandle;
  if(!$fh->open("< $fn"))
  {
    print("Cannot read config file: $fn\n");
    exit;
  }

  # Read config
  while(my $foo = <$fh>)
  {
    $conf{$1} = $2 if($foo =~ m/([^=]*)=(.*)/o);
  }
  $fh->close();
}

my %opposite = 
( 
  'On'  =>  'Off',
  'Off' =>  'On',
  'Unlocked' => 'Locked',
  'Locked'   => 'Unlocked',
);

if($op eq 'GETSENSORS')
{
  login();
  my $sensors = get_sensors();
  foreach my $k (keys %{$sensors})
  {
    print $k . '=' . $sensors->{$k}->{status} . "\n";
  }
}
elsif($op eq 'GETDEVICES')
{
  login();
  my $devices = get_devices();
  foreach my $k (keys %{$devices})
  {
    print $k . '=' . $devices->{$k}->{status} . "\n";
  }
}
elsif($op eq 'TOGGLE')
{
  my $dev = $params->{'DEVICE'};
  login();
  my $devices = get_devices();
  toggle_device($devices->{$dev});
  print "$dev=$opposite{$devices->{$dev}->{status}}\n";
  #print "OK\n";
}

exit;

#login();
#my $sensors = get_sensors();
#my $devs = get_devices();
#toggle_device($devs->{'Back Security Lights'});
#exit;

sub login()
{
  $mech->get("https://portal.adtpulse.com");

  $mech->submit_form( with_fields => { usernameForm => $conf{username}, passwordForm => $conf{password} },
                      button => 'signin');
}                      

sub get_sensors()
{
  if($mech->uri()->as_string !~ m/summary\.jsp/)
  {
    $mech->get("https://portal.adtpulse.com/myhome/summary/summary.jsp");
  }
  my $table = $mech->look_down('_tag', 'div', sub { $_[0]->attr('id') eq 'orbSensorsList' });
  my @rows = $table->look_down('_tag', 'tr', sub { $_[0]->attr('class') eq 'p_listRow' });

  # Parse Controllable Objects
  my $sensors = {};
  foreach my $row (@rows)
  {
    my $name = $row->look_down('_tag', 'a', sub { $_[0]->attr('class') eq 'p_deviceNameText' });
    #print "Device: " . $name->as_text . "\n";

    my $value = $row->look_down('_tag', 'td', sub { $_[0]->attr('valign') eq 'middle' });
    #print "Value: " . substr($value->as_text,0,-1) . "\n";

    $sensors->{$name->as_text}->{status} = substr($value->as_text,0,-1);
  }
  return $sensors;
}



sub get_devices()
{
  if($mech->uri()->as_string !~ m/summary\.jsp/)
  {
    $mech->get("https://portal.adtpulse.com/myhome/summary/summary.jsp");
  }
  my $table = $mech->look_down('_tag', 'div', sub { $_[0]->attr('id') eq 'otherDevicesList' });
  my @rows = $table->look_down('_tag', 'tr', sub { $_[0]->attr('class') eq 'p_listRow' });

  # Parse Controllable Objects
  my $devices = {};
  foreach my $row (@rows)
  {
    my $name = $row->look_down('_tag', 'a', sub { $_[0]->attr('class') eq 'p_deviceNameText' });
    #print "Device: " . $name->as_text . "\n";

    my $value = $row->look_down('_tag', 'a', sub { $_[0]->attr('class') eq 'p_quickControlIcon' });
    #print "Value: " . $value->as_text . "\n";

    my $onclick = $value->attr('onclick');
    my $uri;
    if($onclick =~ m/(quickcontrol[^']*)/)
    {
      $uri = $1;
      #print("URI = " . $uri . "\n\n");
    }

    $devices->{$name->as_text}->{status} = $value->as_text;
    $devices->{$name->as_text}->{uri} = $uri;
  }
  return $devices;
}

sub toggle_device($)
{
  my $dev = shift || die("No device.");
  $mech->get("https://portal.adtpulse.com/myhome/" . $dev->{uri});
  $mech->submit_form( button => 'valueb');
}



