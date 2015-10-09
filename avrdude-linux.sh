export CC=${CROSS_COMPILE}gcc
export CXX=${CROSS_COMPILE}g++
export AR=${CROSS_COMPILE}ar

export OS=$1

export GLIBC_VERSION=`ldd --version | head -n1 | awk '{print $NF}'`
export BASE=`pwd`
mkdir -p ${BASE}/build/$OS/share/
mkdir ${BASE}/build/$OS/include/
mkdir ${BASE}/build/$OS/lib/
mkdir ${BASE}/build/$OS/bin/
touch ${BASE}/build/$OS/share/config.site
mkdir -p ${BASE}/distrib/${OS}/

cat << EOF > `pwd`/build/$OS/share/config.site
CPPFLAGS=-I`pwd`/build/$OS/include/
LDFLAGS=-L`pwd`/build/$OS/lib/
EOF

cd build

if [ ! -f .glibc_done ]
then
mkdir glibc_build
cd glibc_build
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ../../src/glibc-${GLIBC_VERSION}/configure --prefix=${BASE}/build/$OS --enable-static-nss --disable-werror
make -j4 && make install
if [ $? == 0 ]; then
touch ../.glibc_done
fi
cd ..
fi

if [ ! -f .udev_done ]
then
cd ../src/eudev/
./autogen.sh
cd -
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ../src/eudev/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch .udev_done
fi
fi

if [ ! -f .libelf_done ]
then
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ../src/libelf-0.8.9/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch .libelf_done
fi
fi

if [ ! -f .libusb1_done ]
then
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ../src/libusb-1.0.19/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch .libusb1_done
fi
fi

if [ ! -f .libusb0_done ]
then
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ../src/libusb-compat-0.1.4/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch .libusb0_done
fi
fi

if [ ! -f .readline_done ]
then
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ../src/readline-6.3/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch .readline_done
fi
fi

if [ ! -f .ncurses_done ]
then
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ../src/ncurses-6.0/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch .ncurses_done
fi
fi

if [ ! -f .libftdi_done ]
then
cmake -DCMAKE_INSTALL_PREFIX=${BASE}/build/$OS/ ${BASE}/src/libftdi1-1.2/
make && make install
if [ $? == 0 ]; then
touch .libftdi_done
fi
fi

cd ../src/avrdude-6.1
for p in ${BASE}/patches/*.patch; do echo Applying $p; patch -p1 < $p; done
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ./configure --prefix=${BASE}/build/$OS --enable-linuxgpio
make

$CC -Wall -Wno-pointer-sign -g -O2   -o avrdude avrdude-main.o avrdude-term.o ./libavrdude.a -lusb-1.0 -lusb -lftdi1 -lelf -lpthread -lm -lreadline -lncurses -lc --static -lc --static -ludev -L${BASE}/build/$OS/lib/

strip avrdude
cp avrdude avrdude.conf ${BASE}/distrib/${OS}/
