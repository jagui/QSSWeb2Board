#!/bin/bash

if [ -z "${1}" ];then
	echo "PLEASE INTRODUCE VERSION"
    exit
else
	version=${1}
fi


#INSTALL dependencies

echo "UPDATING THE SYSTEM..."

if apt clean && apt update && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y; then 
    echo "System succesfully Updated"
else 
    exit $?
fi

echo "INSTALLING DEPENDENCIES..."
if apt install wget gdebi qt5-qmake qt5-default libqt5core5a libqt5network5 libqt5websockets5 libqt5websockets5-dev libqt5serialport5 libqt5serialport5-dev build-essential zip unzip -y ; then 
    echo "Dependencies installed"
else 
    exit $?
fi    


#GET VERSION AND NAME OF OS
if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    VER=$(cat /etc/debian_version)
elif [ -f /etc/SuSe-release ]; then
    # Older SuSE/etc.
    ...
elif [ -f /etc/redhat-release ]; then
    # Older Red Hat, CentOS, etc.
    ...
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
fi

case $(uname -m) in
x86_64)
    ARCH=amd64  # or AMD64 or Intel64 or whatever
    BITS='64'
    ;;
i*86)
    ARCH=i386  # or IA32 or Intel32 or whatever
    BITS='32'
    ;;
*)
    # leave ARCH as-is
    ;;
esac


#packageDir=qssweb2board_${version}${OS}${VER}_${ARCH}
packageDir=QSSWeb2BoardOnlineCompiler

#create packageDir form template
rm -fr ${packageDir}
cp -fr qssweb2board_2.0-template ${packageDir}

#Download arduino BQ version

echo "DOWNLOADING arduino_BQ_Linux_${ARCH}.zip"
cd ${packageDir}/opt/QSSWeb2Board/res/
if wget https://github.com/bitbloq/QSSWeb2Board/releases/download/${version}/arduino1.8.5_BQ_Linux_${ARCH}.zip; then
    echo "Arduino Downloaded"
else
    exit $?
fi


echo "UNZIPPING ARDUINO..."
if unzip arduino1.8.5_BQ_Linux_${ARCH}.zip > /dev/null ; then
    echo "Arduino unzipped"
else
    exit $?
fi

rm arduino1.8.5_BQ_Linux_${ARCH}.zip > /dev/null
cd -

#build application
baseDir=$(pwd)

if [ -d build ]; then
  rm -fr build
fi

mkdir build
cd build > /dev/null

echo "RUNNING qmake on ../../src/QSSWeb2Board/QSSWeb2Board.pro"
if qmake ../../src/QSSWeb2Board/QSSWeb2Board.pro "ONLINE_COMPILER=true" CONFIG+=release; then
    echo "qmake OK"
else
    exit $?
fi

echo "RUNNING make..."
if make; then
    echo "QSSWeb2Board Built"
else
    exit $?
fi

cd ${baseDir}

#copy application into packageDir
cp build/QSSWeb2Board ${packageDir}/opt/QSSWeb2Board/

sed -i -e "s/###ARCH###/${ARCH}/g" ${packageDir}/DEBIAN/control
sed -i -e "s/###VERSION###/${version}/g" ${packageDir}/DEBIAN/control

#build deb package
#echo "BUILD DEB PACKAGE..."
#if dpkg --build ${packageDir}; then
#    echo "Deb package built"
#else
#    exit $?
#fi

echo "Installing Online Compiler".

if sh QSSWeb2BoardOnlineCompiler/DEBIAN/preinst ; then
    echo "Preinstall script OK"
else
    echo "Preinstall script ERROR"
    exit $?
fi

if cp -fr QSSWeb2BoardOnlineCompiler/etc/* /etc/ && cp -fr QSSWeb2BoardOnlineCompiler/opt/* /opt/ && cp -fr QSSWeb2BoardOnlineCompiler/usr/* /usr/ ; then
    echo "Copying files OK"
else
    echo "Copyting files ERROR"    
    exit $?
fi

if sh QSSWeb2BoardOnlineCompiler/DEBIAN/postinst ; then
    echo "Postinstall script OK"
else
    echo "Postinstall script ERROR"
    exit $?
fi



#if gdebi --non-interactive QSSWeb2BoardOnlineCompiler.deb; then
#    echo "QSSWeb2Board properly installed"
#else   
#    exit $?
#fi

echo "Removing Temp files"
#remove all temp files

cd ${baseDir}
cd build
make clean
cd ${baseDir}
rm -fr build
rm -fr ${packageDir}
#rm -fr ${packageDir}.deb
