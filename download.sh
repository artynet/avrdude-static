function downloadAndUntar {
    if [ ! -e $2 ]
    then
        wget $1/$2
    fi
    tar xvf $2
}

GLIBC_VERSION=`ldd --version | head -n1 | awk '{print $NF}'`

if [ ! -f src/.downloaded ]
then
mkdir src
cd src
downloadAndUntar http://download.savannah.gnu.org/releases/avrdude avrdude-6.1.tar.gz
downloadAndUntar http://www.intra2net.com/en/developer/libftdi/download libftdi1-1.2.tar.bz2
downloadAndUntar http://downloads.sourceforge.net/project/libusb/libusb-1.0/libusb-1.0.19 libusb-1.0.19.tar.bz2
downloadAndUntar http://downloads.sourceforge.net/project/libusb/libusb-compat-0.1/libusb-compat-0.1.4 libusb-compat-0.1.4.tar.bz2
downloadAndUntar ftp://ftp.gnu.org/gnu/ncurses ncurses-6.0.tar.gz
downloadAndUntar ftp://ftp.cwru.edu/pub/bash readline-6.3.tar.gz
downloadAndUntar http://www.mr511.de/software libelf-0.8.13.tar.gz
downloadAndUntar http://mirror2.mirror.garr.it/mirrors/gnuftp/gnu/libc glibc-${GLIBC_VERSION}.tar.bz2
git clone https://github.com/gentoo/eudev.git

#download precompiled dll for windows
wget http://downloads.sourceforge.net/project/picusb/libftdi1-1.1_devkit_mingw32_12Feb2014.zip
wget http://downloads.sourceforge.net/project/libusb-win32/libusb-win32-releases/0.1.12.2/libusb-win32-device-bin-0.1.12.2.tar.gz
wget http://downloads.sourceforge.net/project/libusb-win32/libusb-win32-releases/1.2.6.0/libusb-win32-bin-1.2.6.0.zip
touch .downloaded
cd ..
fi
