oracle-jdk-installer
====================

A simple script that sets up your system to use Java 7+ since Oracle removed its packages from Ubuntu 12.04

Please download the JDK package according to your system from here:

http://www.oracle.com/technetwork/java/javase/downloads/index.html

From the 'Java Platform, Standard Edition' option choose the JDK download and then download the file for your system. Please note that this script is tested only on Ubuntu so you should download one of the 'Linux x86', 'Linux x64' and specifically the one that's compressed (ending in .tar.gz ).

Put the downloaded file in the same folder as the installer ( .sh ) file and run it with root privileges.

Usage
-----
<pre>
sudo ./jdk-installer.sh javaCompressedTarFile System-bits

javaCompressedTarFile
  Path to the downloaded jdk file
System-bits
  -32 or -64 according to your system architecture
</pre>


Examples
--------

<pre>
Used on my Thinkpad T430 64-bit Ubuntu 12.04 LTS ::

  The file I downloaded for my system is: jdk-7u5-linux-x64.tar.gz
  The command I executed: sudo ./jdk-installer jdk-7u5-linux-x64.tar.gz -64
  
Used on my Toshiba Satellite A300D 32-bit Ubuntu 12.04 LTS ::

  The file I downloaded for my system is: jdk-7u5-linux-i586.tar.gz
  The command I executed: sudo ./jdk-installer jdk-7u5-linux-i586.tar.gz -32
</pre>

Verify the setup
----------------
In order to verify that it got installed successfully you can try the following checks. Note that the following program is the most important but you could check all the binaries that are installed this way:

java -version

You should get a response like:
<pre>
java version "1.7.0_05"
Java(TM) SE Runtime Environment (build 1.7.0_05-b06)
Java HotSpot(TM) 64-Bit Server VM (build 23.1-b03, mixed mode)
</pre>
In order to verify that the browser plugin works visit the following webpage and click 'Verify Java version'
http://www.java.com/en/download/installed.jsp

Problems
--------
You may get some warnings for some manual pages trying to be set up and do not exist. Ignore them and you should be fine.
