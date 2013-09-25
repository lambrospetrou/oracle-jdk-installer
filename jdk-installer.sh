#!/bin/bash

######################################
#
# author: Lambros Petrou
# github: https://github.com/lambrospetrou/oracle-jdk-installer.git
# version: 1.0
#
######################################

#set -x # to trace the script execution

installer=$( basename $0 );

## FUNCTIONS
function usage(){
	echo "Usage: sudo ./$installer <javaCompressedTarFile> <System-bits>"	
	format="\n%s\n\t%s"
	printf $format "<javaCompressedTarFile>" "Path to the downloaded jdk file"
	printf $format "<System-bits>" "-32 or -64 according to your system architecture"
	echo ; echo;	
	exit 1;
}

function install_required_packages(){
	echo -e "Notice: The command update-java-alternatives from package java-common is required but it's not installed. \n-> Installing it for you right now."
	apt-get install -q -y java-common
	echo "Installed."
}

## MAIN PROGRAM
if [ "$(id -u)" != "0" ]; then
	echo "Error: root privileges required!"
	echo "Try: sudo ./$installer"
	exit 1;
fi

if [ $# -ne 2 ]; then
	usage
fi

# install java-common if it's not installed
command -v update-java-alternatives >/dev/null 2>&1 || install_required_packages

arch=$2
arch=${arch:1}
libDir="/usr/lib/jvm/"
jdkFile=$1

	################################
	## Construct the name of the dir 
version=${jdkFile#*-} # remove the text before the first -
version=${version%%-*} # remove the text after the first -
major=${version%u*}
minor=${version#*u}
if [ "${#minor}" = "1" ]; then
	minor="0$minor"
fi
javaDirName="java-oracle-$major.$minor"
javaDirName="$libDir$javaDirName"
javaName=$( basename $javaDirName )

printf "\n:: Setup Information ::\n"
echo "System architecture: $arch-bit"
echo "Java JDK dir path name: $javaDirName"
echo "Java Setup Name: $javaName"
printf "::::\n\n"

	################################
	## Setup the Java Dir Folder
#mkdir $javaDirName; rmdir $javaDirName;

#jdkFile=$1
jdkFile=$( readlink -f $jdkFile )
echo "Changing directory to JDK lib: $libDir"
cd $libDir

echo "Uncompressing jdk: $jdkFile"
tar xzf $jdkFile
echo "Copying jdk to lib: $javaDirName"
folder="$( tar -tf $jdkFile | head -n 1 )"
mv $folder $javaDirName

	################################
	## Find the highest priority
priority=$( update-java-alternatives -l | cut -f 2 -d ' ' | sort -nr | head -n 1)
#echo "PRIORITY: $priority"
if [ "${#priority}" = "0" ]; then
	priority="1000"
fi
#echo "PRIORITY: $priority"


	################################
	## Create the .jinfo file
echo "Creating the required .jinfo file: $libDir/.$javaName.jinfo"

echo "alias=$javaName
priority=$priority
section=non-free

jre ControlPanel $javaDirName/jre/bin/ControlPanel
jre java $javaDirName/jre/bin/java
jre java_vm $javaDirName/jre/bin/java_vm
jre javaws $javaDirName/jre/bin/javaws
jre jcontrol $javaDirName/jre/bin/jcontrol
jre keytool $javaDirName/jre/bin/keytool
jre pack200 $javaDirName/jre/bin/pack200
jre policytool $javaDirName/jre/bin/policytool
jre rmid $javaDirName/jre/bin/rmid
jre rmiregistry $javaDirName/jre/bin/rmiregistry
jre unpack200 $javaDirName/jre/bin/unpack200
jre orbd $javaDirName/jre/bin/orbd
jre servertool $javaDirName/jre/bin/servertool
jre tnameserv $javaDirName/jre/bin/tnameserv
jre jexec $javaDirName/jre/lib/jexec
jdk appletviewer $javaDirName/bin/appletviewer
jdk apt $javaDirName/bin/apt
jdk extcheck $javaDirName/bin/extcheck
jdk idlj $javaDirName/bin/idlj
jdk jar $javaDirName/bin/jar
jdk jarsigner $javaDirName/bin/jarsigner
jdk java-rmi.cgi $javaDirName/bin/java-rmi.cgi
jdk javac $javaDirName/bin/javac
jdk javadoc $javaDirName/bin/javadoc
jdk javah $javaDirName/bin/javah
jdk javap $javaDirName/bin/javap
jdk jconsole $javaDirName/bin/jconsole
jdk jdb $javaDirName/bin/jdb
jdk jhat $javaDirName/bin/jhat
jdk jinfo $javaDirName/bin/jinfo
jdk jmap $javaDirName/bin/jmap
jdk jps $javaDirName/bin/jps
jdk jrunscript $javaDirName/bin/jrunscript
jdk jsadebugd $javaDirName/bin/jsadebugd
jdk jstack $javaDirName/bin/jstack
jdk jstat $javaDirName/bin/jstat
jdk jstatd $javaDirName/bin/jstatd
jdk native2ascii $javaDirName/bin/native2ascii
jdk rmic $javaDirName/bin/rmic
jdk schemagen $javaDirName/bin/schemagen
jdk serialver $javaDirName/bin/serialver
jdk wsgen $javaDirName/bin/wsgen
jdk wsimport $javaDirName/bin/wsimport
jdk xjc $javaDirName/bin/xjc" > "$libDir.$javaName.jinfo"

if [ "$arch" = "64" ]; then
	echo "plugin xulrunner-1.9-javaplugin.so $javaDirName/jre/lib/amd64/libnpjp2.so
plugin mozilla-javaplugin.so $javaDirName/jre/lib/amd64/libnpjp2.so" >> "$javaLib.$javaName.jinfo"
elif [ "$arch" = "32" ]; then
	echo "plugin xulrunner-1.9-javaplugin.so $javaDirName/jre/lib/i386/libnpjp2.so
plugin mozilla-javaplugin.so $javaDirName/jre/lib/i386/libnpjp2.so" >> "$javaLib.$javaName.jinfo"
fi

	################################
	## Installing the binary files
echo "Installing all necessary binaries for Oracle Java 7 JDK"

update-alternatives  --install /usr/bin/ControlPanel ControlPanel $javaDirName/jre/bin/ControlPanel 100 --slave /usr/share/man/man1/ControlPanel.1 ControlPanel.1 $javaDirName/man/man1/ControlPanel.1
update-alternatives  --install /usr/bin/java java $javaDirName/jre/bin/java 100 --slave /usr/share/man/man1/java.1 java.1 $javaDirName/man/man1/java.1
update-alternatives  --install /usr/bin/java_vm java_vm $javaDirName/jre/bin/java_vm 100 --slave /usr/share/man/man1/java_vm.1 java_vm.1 $javaDirName/man/man1/java_vm.1
update-alternatives  --install /usr/bin/javaws javaws $javaDirName/jre/bin/javaws 100 --slave /usr/share/man/man1/javaws.1 javaws.1 $javaDirName/man/man1/javaws.1
update-alternatives  --install /usr/bin/jcontrol jcontrol $javaDirName/jre/bin/jcontrol 100 --slave /usr/share/man/man1/jcontrol.1 jcontrol.1 $javaDirName/man/man1/jcontrol.1
update-alternatives  --install /usr/bin/keytool keytool $javaDirName/jre/bin/keytool 100 --slave /usr/share/man/man1/keytool.1 keytool.1 $javaDirName/man/man1/keytool.1
update-alternatives  --install /usr/bin/pack200 pack200 $javaDirName/jre/bin/pack200 100 --slave /usr/share/man/man1/pack200.1 pack200.1 $javaDirName/man/man1/pack200.1
update-alternatives  --install /usr/bin/policytool policytool $javaDirName/jre/bin/policytool 100 --slave /usr/share/man/man1/policytool.1 policytool.1 $javaDirName/man/man1/policytool.1
update-alternatives  --install /usr/bin/rmid rmid $javaDirName/jre/bin/rmid 100 --slave /usr/share/man/man1/rmid.1 rmid.1 $javaDirName/man/man1/rmid.1
update-alternatives  --install /usr/bin/rmiregistry rmiregistry $javaDirName/jre/bin/rmiregistry 100 --slave /usr/share/man/man1/rmiregistry.1 rmiregistry.1 $javaDirName/man/man1/rmiregistry.1
update-alternatives  --install /usr/bin/unpack200 unpack200 $javaDirName/jre/bin/unpack200 100 --slave /usr/share/man/man1/unpack200.1 unpack200.1 $javaDirName/man/man1/unpack200.1
update-alternatives  --install /usr/bin/orbd orbd $javaDirName/jre/bin/orbd 100 --slave /usr/share/man/man1/orbd.1 orbd.1 $javaDirName/man/man1/orbd.1
update-alternatives  --install /usr/bin/servertool servertool $javaDirName/jre/bin/servertool 100 --slave /usr/share/man/man1/servertool.1 servertool.1 $javaDirName/man/man1/servertool.1
update-alternatives  --install /usr/bin/tnameserv tnameserv $javaDirName/jre/bin/tnameserv 100 --slave /usr/share/man/man1/tnameserv.1 tnameserv.1 $javaDirName/man/man1/tnameserv.1
update-alternatives  --install /usr/bin/jexec jexec $javaDirName/jre/lib/jexec 100 --slave /usr/share/man/man1/jexec.1 jexec.1 $javaDirName/man/man1/jexec.1
update-alternatives  --install /usr/bin/appletviewer appletviewer $javaDirName/bin/appletviewer 100 --slave /usr/share/man/man1/appletviewer.1 appletviewer.1 $javaDirName/man/man1/appletviewer.1
update-alternatives  --install /usr/bin/apt apt $javaDirName/bin/apt 100 --slave /usr/share/man/man1/apt.1 apt.1 $javaDirName/man/man1/apt.1
update-alternatives  --install /usr/bin/extcheck extcheck $javaDirName/bin/extcheck 100 --slave /usr/share/man/man1/extcheck.1 extcheck.1 $javaDirName/man/man1/extcheck.1
update-alternatives  --install /usr/bin/idlj idlj $javaDirName/bin/idlj 100 --slave /usr/share/man/man1/idlj.1 idlj.1 $javaDirName/man/man1/idlj.1
update-alternatives  --install /usr/bin/jar jar $javaDirName/bin/jar 100 --slave /usr/share/man/man1/jar.1 jar.1 $javaDirName/man/man1/jar.1
update-alternatives  --install /usr/bin/jarsigner jarsigner $javaDirName/bin/jarsigner 100 --slave /usr/share/man/man1/jarsigner.1 jarsigner.1 $javaDirName/man/man1/jarsigner.1
update-alternatives  --install /usr/bin/java-rmi.cgi java-rmi.cgi $javaDirName/bin/java-rmi.cgi 100 --slave /usr/share/man/man1/java-rmi.cgi.1 java-rmi.cgi.1 $javaDirName/man/man1/java-rmi.cgi.1
update-alternatives  --install /usr/bin/javac javac $javaDirName/bin/javac 100 --slave /usr/share/man/man1/javac.1 javac.1 $javaDirName/man/man1/javac.1
update-alternatives  --install /usr/bin/javadoc javadoc $javaDirName/bin/javadoc 100 --slave /usr/share/man/man1/javadoc.1 javadoc.1 $javaDirName/man/man1/javadoc.1
update-alternatives  --install /usr/bin/javah javah $javaDirName/bin/javah 100 --slave /usr/share/man/man1/javah.1 javah.1 $javaDirName/man/man1/javah.1
update-alternatives  --install /usr/bin/javap javap $javaDirName/bin/javap 100 --slave /usr/share/man/man1/javap.1 javap.1 $javaDirName/man/man1/javap.1
update-alternatives  --install /usr/bin/jconsole jconsole $javaDirName/bin/jconsole 100 --slave /usr/share/man/man1/jconsole.1 jconsole.1 $javaDirName/man/man1/jconsole.1
update-alternatives  --install /usr/bin/jdb jdb $javaDirName/bin/jdb 100 --slave /usr/share/man/man1/jdb.1 jdb.1 $javaDirName/man/man1/jdb.1
update-alternatives  --install /usr/bin/jhat jhat $javaDirName/bin/jhat 100 --slave /usr/share/man/man1/jhat.1 jhat.1 $javaDirName/man/man1/jhat.1
update-alternatives  --install /usr/bin/jinfo jinfo $javaDirName/bin/jinfo 100 --slave /usr/share/man/man1/jinfo.1 jinfo.1 $javaDirName/man/man1/jinfo.1
update-alternatives  --install /usr/bin/jmap jmap $javaDirName/bin/jmap 100 --slave /usr/share/man/man1/jmap.1 jmap.1 $javaDirName/man/man1/jmap.1
update-alternatives  --install /usr/bin/jps jps $javaDirName/bin/jps 100 --slave /usr/share/man/man1/jps.1 jps.1 $javaDirName/man/man1/jps.1
update-alternatives  --install /usr/bin/jrunscript jrunscript $javaDirName/bin/jrunscript 100 --slave /usr/share/man/man1/jrunscript.1 jrunscript.1 $javaDirName/man/man1/jrunscript.1
update-alternatives  --install /usr/bin/jsadebugd jsadebugd $javaDirName/bin/jsadebugd 100 --slave /usr/share/man/man1/jsadebugd.1 jsadebugd.1 $javaDirName/man/man1/jsadebugd.1
update-alternatives  --install /usr/bin/jstack jstack $javaDirName/bin/jstack 100 --slave /usr/share/man/man1/jstack.1 jstack.1 $javaDirName/man/man1/jstack.1
update-alternatives  --install /usr/bin/jstat jstat $javaDirName/bin/jstat 100 --slave /usr/share/man/man1/jstat.1 jstat.1 $javaDirName/man/man1/jstat.1
update-alternatives  --install /usr/bin/jstatd jstatd $javaDirName/bin/jstatd 100 --slave /usr/share/man/man1/jstatd.1 jstatd.1 $javaDirName/man/man1/jstatd.1
update-alternatives  --install /usr/bin/native2ascii native2ascii $javaDirName/bin/native2ascii 100 --slave /usr/share/man/man1/native2ascii.1 native2ascii.1 $javaDirName/man/man1/native2ascii.1
update-alternatives  --install /usr/bin/rmic rmic $javaDirName/bin/rmic 100 --slave /usr/share/man/man1/rmic.1 rmic.1 $javaDirName/man/man1/rmic.1
update-alternatives  --install /usr/bin/schemagen schemagen $javaDirName/bin/schemagen 100 --slave /usr/share/man/man1/schemagen.1 schemagen.1 $javaDirName/man/man1/schemagen.1
update-alternatives  --install /usr/bin/serialver serialver $javaDirName/bin/serialver 100 --slave /usr/share/man/man1/serialver.1 serialver.1 $javaDirName/man/man1/serialver.1
update-alternatives  --install /usr/bin/wsgen wsgen $javaDirName/bin/wsgen 100 --slave /usr/share/man/man1/wsgen.1 wsgen.1 $javaDirName/man/man1/wsgen.1
update-alternatives  --install /usr/bin/wsimport wsimport $javaDirName/bin/wsimport 100 --slave /usr/share/man/man1/wsimport.1 wsimport.1 $javaDirName/man/man1/wsimport.1
update-alternatives  --install /usr/bin/xjc xjc $javaDirName/bin/xjc 100 --slave /usr/share/man/man1/xjc.1 xjc.1 $javaDirName/man/man1/xjc.1

if [ "$arch" = "64" ]; then
	update-alternatives  --install /usr/lib/xulrunner-addons/plugins/libjavaplugin.so xulrunner-1.9-javaplugin.so $javaDirName/jre/lib/amd64/libnpjp2.so 100
	update-alternatives  --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so $javaDirName/jre/lib/amd64/libnpjp2.so 100
elif [ "$arch" = "32" ]; then
	update-alternatives  --install /usr/lib/xulrunner-addons/plugins/libjavaplugin.so xulrunner-1.9-javaplugin.so $javaDirName/jre/lib/i386/libnpjp2.so 100
	update-alternatives  --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so $javaDirName/jre/lib/i386/libnpjp2.so 100
fi

	################################
	## FINALIZING SETUP
#echo ":: Configuring java"
#update-alternatives --config java
echo ":: Currently available java installations"
update-java-alternatives -l
echo
echo ":: Selecting the newly installed java setup as default!"
update-java-alternatives --set "$javaName"

echo "Success!"


printf "\nTo verify that everything has been set up ok type ( if these work it is propably ok ):"
printf "\n\tjava -version\n\tjavac -version\n"
printf "\nTo test the browser plugin visit: www.java.com/en/download/installed.jsp\n\n"
	

exit 0;


