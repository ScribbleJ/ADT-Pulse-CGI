ADT Pulse CGI
=============

This is a simple Perl CGI that allows you to access your ADT Pulse devices in an automated fashion.


Disclaimer
----------

I am not employed bt ADT, and this code is not endorsed by ADT or by myself.  By using this code, you accept all responsibilty for anything it may or may not do.


Requirements
------------

* This Script
* An ADT Pulse login, and one or more ADT Pulse devices
* Some webserver (tested with Apache) to run this under

Perl modules:

* WWW::Mechanize
* WWW::Mechanize::TreeBuilder
* FileHandle
* CGI

Config
------

You need to provide an ADT Pulse website login.  You can provide this one of two ways.  

0. Placed into a configuration file like the included sample, no spaces!  The configuration file can live in /etc/pulse/pulse.conf, ~/.pulse.conf, or ./pulse.conf
0. Submitted as CGI parameters, e.g. https://yourserver/cgi-bin/pulse.pl?OP=GETDEVICES&USER=myusername&PASS=mypassword

Usage
-----

https://yourserver/cgi-bin/pulse.pl?OP=GETDEVICES

Returns a list of your ADT Pulse devices.

https://yourserver/cgi-bin/pulse.pl?OP=GETSENSORS

Returns a list of your ADT Pulse sensors.

https://yourserver/cgi-bin/pulse.pl?OP=TOGGLE&DEVICE=devicename

Changes the state of a device.  devicename is the same as what's returned from GETDEVICES.


Ideas for Using this Script
---------------------------

Personally, I use it to control my ADT Pulse devices from my Android phone and Android Wear watch.  

0. Install Tasker ( https://play.google.com/store/apps/details?id=net.dinglisch.android.taskerm&hl=en )
0. If you have an Android Wear device, install Small Wearables.  This provides the ability to call Tasker from Android Wear ( https://play.google.com/store/apps/details?id=com.smallrocksoftware.smallwearables&hl=en )
0. Make sure you know the names of your devices as returned by the GETDEVICES command above.
0. For each device you want to control, create a Tasker TASK.  The task should contain an HTTP Get item.  The HTTP Get should be configured with "Server:Port" equal to your server's name ("yourserver" in the example above) and "Path" configured to the rest of the URI ( e.g.  cgi-bin/pulse.pl?OP=TOGGLE&DEVICE=Bedroom Light )  Yes - it's fine with spaces in the DEVICE.
0. You're done.  You can use this TASK in a Tasker PROFILE, or call the TASK directly from your Android Wear device (e.g "OK Google, Start Tasker, Bedroom Light")


