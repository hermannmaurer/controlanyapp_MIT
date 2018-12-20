# controlanyapp_MIT

A free (MIT licensed) shell driven control interface for admins, integrators and testers - pre-defined task execution - minimizing commands to remember in grouping tasks inside a so called controlanyapp script.

This concept has emerged from my daily work as a solution integrator over many years being tired of stopping, starting, restarting, seing logs, greping logs, tailing logs for the purpose of testing, troubleshooting, maintaining and operating applications and Linux services. To handle these chores you have to remember and recall a lot of details and the admin guide is your best friend, but not any longer!

First of all, convenient is an abstraction layer. An effective abstraction layer easy to manage. 

For example, "Start( up an application)" is what someone wants to do, and the person basically does not care about what's happening at the shell level. And there needs to be the freedom to add other tasks like Stop, Restart, Status - there is no limit, except useful tasks. And everything what is executable via terminal on the shell can be used for task execution - a tcpdump statement or netstat to see whether traffic works etc.

The REAL WORLD EXAMPLE below shows how to control tinyproxy and its related tasks with a single controlanyapp script. And the exectuable script is at the same time the configuration. So easy to manage. Get started with CONTROL_TEMPLATE.pl <mycontrolscript.pl>

This way of working is effective and scales to a high degree as the commandline tasks required to be known for any kind of application are often identical from an abstraction point of view and they are preserved once written in a controlanyapp script. This is the concept supported and materialized by controlanyapp. Common tasknames are for example: stop, start, restart, status and what else comes into someone's mind. Those pre-defined tasks will be helpful for people working on CLI level for Linux applications just with the knowledge of the existance of a controlanyapp script.

The user interface keeps track of task execution in a log file recording the timestamp and taskname.

At any given time the user interface display can be switched to verbose mode so the taskname is expanded with the detailed task information revealing the real command execution on a shell.

By the way controlanyapp is Perl driven, but you don't need to know much of it. The advantage is that Perl is available on Linux and no extra CPAN module is required.

MASTER YOUR SCRIPT CONFIGURATION
================================

This is basically one pre-defined task linked with a taskname: taskname => predefined task (may include shell cmds, operators and statements as well as scripts and binaries)

To get the definition of the tasks done users edit inside their controlanyapp script using an editor (vim) the @TASKS array. During configuration time someone determines and notes tasknames infront of "=>" and to the right of it the real command or a group of commands being executed, like you would type the commands into a terminal for execution. 

If you need to have a sequence of commands within a single task shell operators like '&&' and '||' may prove beneficial between single cmds forcing a conditional sequence, instead of putting one shell command next ot each other terminated by semicolons. Keep in mind the sequence execution with operators depends on the return value of the individual cmd being executed.

	task1 => q( cmd1; cmd2) # cmd1 and cmd2 are executed not depending on exit code of cmd1
	task2 => q( cmd1 && cmd2) # cmd1 and possibily cmd2 are executed depending on true exit code of cmd1
	task3 => q( cmd1 || cmd2) # cmd1 and possibily cmd2 are executed depending on false exit code of cmd1

A task is any pre-defined shell cmd/script/binary execution that may be combined with a statement, pipe, subshell, shell operator and a combination of thereof.

To the configuration, the right value of "=>" is embedded in one of the Perl q() or qq() functions. q() behaves like single quote and qq() behaves like double quote. This also gives you the freedom to use quotation marks without escapes in your task definition.

Example:

	...
	my $VAR="Perl"; # Perl Variable
	
	our @TASKS= (
		singleQuote => [0,  q(VAR="Shell"; echo "VAR is replaced by $VAR")], # Will display "Shell"
		doubleQuote => [0, qq(VAR="Shell"; echo "VAR is replaced by $VAR")], # Will display "Perl"
	);
	...
	
To comment a task, text with a heading hash can be placed almost everywhere. 
To close this, here is also a safety mechanism which needs to be managed in the task configuration. 

Example: 
  
    safe =>   [1, qq(echo "Hurray you confirmed with yes!!")],
    normal => [0, qq(echo "I know you didn't have to confirm me being executed.")],

The 1 after the square bracket requires the user to confirm with an explicit y(es) to be executed. While a 0 will execute the task without asking reconfirmation from the user once chosen.

Example with handy && || sequence:

	trueSequenceTest   => [0, qq(true && echo "I am always called" || echo "Lucky you, I am not")],
	falseSequenceTest  => [0, qq(false && echo "I am never called" || echo "I am always called")],

AND HOW TO GET STARTED?
=======================

1) Transfer and execute on your Linux machine the self-extracting script.

	Look up the project root directory, to find the latest version for installation.

		chmod u+x controlanyapp_MIT.d_1_Installer.sh
		sudo ./controlanyapp_MIT.d_<VERSION>_Installer.sh

	1.1) The controlanyapp code - which is plain readable Perl source code - is exclusively copied into the /opt/CONTROL directory. The code is in clear text with comments and without obfuscation.

	1.2) Under both /usr/local/bin and /usr/local/sbin directories is a logical link created referring to CONTROL_TEMPLATE.pl.

	If one of these directories is in the user's PATH ENV variable that makes it simple to call for CONTROL_TEMPLATE.pl without directory name infront.
	This works even simpler and faster, by using "CONTROL_ tab tab" Linux PATH autocompletion. Linux administrators will know what I mean here.
	Verify if /usr/local/bin or /usr/local/sbin is part of the user's PATH environment variable: echo $PATH

2) Create your first controlanyapp.d executeable script:

		CONTROL_TEMPLATE.pl <myScriptName.pl

   Usually I always start my scriptname with a prefix, like "CONTROL_". 
   
   Example:
   
		CONTROL_TEMPLATE.pl CONTROL_helloWorld.pl

3) Adjust the script configuration to your needs, by default it has pre-defined ntp.service tasks inside
   
		vim CONTROL_helloWorld.pl

	HINT: if you want to control another systemctl service, just adjust the $service variable.
	Or remove the tasks and write your own from scratch.
		
		my $service="ntp.service"; # specify systemctl service

4) Call your script
   
		./CONTROL_helloWorld.pl
   
5) That is all, have fun!

PREREQUISITES
=============

Linux standard Perl installation

What is it not?
===============
This piece of software does not work with Windows. It was never designed to work with Windows.

REAL WORLD EXAMPLE
==================

	+++ CONTROL01 CONTROL_tinyproxy.pl BEGIN +++
	 1 [start]
	 2 [stop]
	 3 [status]
	 4 [restart]
	 5 [follow]
	 6 [dump]
	 7 [catService]
	 8 [tailf]
	 9 [viconfig]
	 0 [tcpdump8888]
	 a [tcpdumpnot22]
	
	 : [less log]
	 . [toggle verbose]
	 q [quit] # [license]
	+++ CONTROL01 CONTROL_tinyproxy.pl END +++


Toggle verbose, press key '.'
=============================

	+++ CONTROL01 CONTROL_tinyproxy.pl BEGIN +++
	 1 [start]        task [sudo systemctl start tinyproxy.service]
	 2 [stop]         task [sudo systemctl stop  tinyproxy.service]
	 3 [status]       task [systemctl status  tinyproxy.service]
	 4 [restart]      task [sudo systemctl restart tinyproxy.service]
	 5 [follow]       task [journalctl -b -ef -u tinyproxy.service]
	 6 [dump]         task [journalctl -b -e -u  tinyproxy.service]
	 7 [catService]   task [systemctl cat tinyproxy.service]
	 8 [tailf]        task [sudo tailf /var/log/tinyproxy/tinyproxy.log]
	 9 [viconfig]     task [sudo vim /etc/tinyproxy/tinyproxy.conf]
	 0 [tcpdump8888]  task [sudo tcpdump -i eth0 port 8888]
	 a [tcpdumpnot22] task [sudo tcpdump -i eth0 -nn not port 22 and not icmp]
	
	 : [less log] logPath [/home/pi/.controlanyapp.d/CONTROL_tinyproxy.pl.log]
	 . [toggle verbose]
	 q [quit] # [license]
	+++ CONTROL01 CONTROL_tinyproxy.pl END +++

Display the log, press key ':'
==============================

	20181201 16:39:58 Sat: Key [b] [tcpdump80443] Result [OK]
	20181201 16:40:25 Sat: Key [0] [tcpdump8888] Result [OK]
	20181201 16:40:39 Sat: Key [8] [tailf] Result [NOK]
	20181201 16:40:41 Sat: Key [8] [tailf] Result [NOK]
	20181201 16:41:17 Sat: Key [8] [tailf] Result [NOK]
	20181201 16:42:14 Sat: Key [9] [viconfig] Result [OK]
	20181201 16:42:18 Sat: Key [4] [restart] Result [OK]
	20181201 16:42:46 Sat: Key [b] [tcpdump80443] Result [OK]
	20181201 16:42:57 Sat: Key [0] [tcpdump8888] Result [OK]
	20181201 16:43:59 Sat: Key [8] [tailf] Result [NOK]
	20181202 09:02:05 Sun: Key [c] [tcpdumpnot22] Result [OK]
	20181202 10:12:27 Sun: Key [2] [stop] Result [OK]
	20181202 10:18:43 Sun: Key [1] [start] Result [OK]
	20181202 10:29:59 Sun: Key [4] [restart] Result [OK]

License, press key '#'
======================

	+++ CONTROL01 CONTROL_tinyproxy.pl END +++
	
	MIT License
	
	Copyright (c) 2018 Hermann Maurer
	
	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:
	
	The above copyright notice and this permission notice shall be included in all
	copies or substantial portions of the Software.
	
	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
	SOFTWARE.
	
	        << Press Space to move on >>

Manage your configuration
=========================

	pi@demo:~/bin $ vim CONTROL_tinyproxy.pl 
	#! /bin/perl

	use strict; use warnings;
	use lib qw( /opt/CONTROL/controlanyapp_MIT.d/module.d);
	use Control::ScriptConnector;

	################
	# SETTINGS BEGIN
	# our( $ID,@TASKS,$LOGPATH)

	my $service="tinyproxy.service"; # specify systemctl service

	our @TASKS= (
		#key       => [Safety question, task to execute on shell]
		#falsetest => [0, qq(false)],
		#truetest  => [0, qq(true)],
		start      => [1, qq(sudo systemctl start $service)],
		stop       => [1, qq(sudo systemctl stop  $service)],
		status     => [0, qq(systemctl status  $service)],
		restart    => [1, qq(sudo systemctl restart $service)],
		follow     => [0, qq(journalctl -b -ef -u $service)],
		dump       => [0, qq(journalctl -b -e -u  $service)],
		catService => [0, qq(systemctl cat $service)],
		tailf      => [0, qq(sudo tailf /var/log/tinyproxy/tinyproxy.log)],
		viconfig   => [0, qq(sudo vim /etc/tinyproxy/tinyproxy.conf)],
		tcpdump8888    => [0, qq(sudo tcpdump -i eth0 port 8888)],
		tcpdumpnot22   => [0, qq(sudo tcpdump -i eth0 -nn not port 22 and not icmp)],
	);
	
	# SETTINGS END
	################


Enough of the words - get a copy of the MIT licensed self-extracting script and hate it or love it... 

