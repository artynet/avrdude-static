export CC=${CROSS_COMPILE}gcc
export CXX=${CROSS_COMPILE}g++
export AR=${CROSS_COMPILE}ar

export OS="linux"

export GLIBC_VERSION=`ldd --version | head -n1 | awk '{print $NF}'`
export BASE=`pwd`
mkdir -p ${BASE}/build/$OS/share/
mkdir -p ${BASE}/build/$OS/include/
mkdir -p ${BASE}/build/$OS/lib/
mkdir -p ${BASE}/build/$OS/bin/
touch ${BASE}/build/$OS/share/config.site
mkdir -p ${BASE}/distrib/${OS}/

cat << EOF > `pwd`/build/$OS/share/config.site
CPPFLAGS=-I`pwd`/build/$OS/include/
LDFLAGS=-L`pwd`/build/$OS/lib/
EOF

export SRCDIR=${BASE}/src
export PREFIX=${BASE}/build/linux

CFLAGS="$CFLAGS -I$PREFIX/include -I$PREFIX/include/libusb-1.0 -I$PREFIX/include/libelf"
CXXFLAGS="$CXXFLAGS -I$PREFIX/include -I$PREFIX/include/libusb-1.0/ -I$PREFIX/include/libelf"
LDFLAGS="$LDFLAGS -L$PREFIX/lib"

echo $CFLAGS
echo $CXXFLAGS

# exit 0

# cd ${BASE}/build

if [ ! -f ${BASE}/build/.glibc_done ]
then
mkdir -p ${BASE}/build/glibc_build
cd ${BASE}/build/glibc_build
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ${SRCDIR}/glibc-${GLIBC_VERSION}/configure --prefix=${BASE}/build/$OS --enable-static-nss --disable-werror
make -j4 && make install
if [ $? == 0 ]; then
touch ${BASE}/build/.glibc_done
fi
fi

if [ ! -f ${BASE}/build/.udev_done ]
then
mkdir -p ${BASE}/build/eudev_build
cd ${SRCDIR}/eudev/
./autogen.sh
cd ${BASE}/build/eudev_build
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ${SRCDIR}/eudev/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch ${BASE}/build/.udev_done
fi
fi

if [ ! -f ${BASE}/build/.libelf_done ]
then
mkdir -p ${BASE}/build/libelf_build
cd ${BASE}/build/libelf_build
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ${SRCDIR}/libelf-0.8.13/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch ${BASE}/build/.libelf_done
fi
fi

if [ ! -f ${BASE}/build/.libusb1_done ]
then
mkdir -p ${BASE}/build/libusb1_build
cd ${BASE}/build/libusb1_build
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ${SRCDIR}/libusb-1.0.19/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch ${BASE}/build/.libusb1_done
fi
fi

if [ ! -f ${BASE}/build/.libusb0_done ]
then
mkdir -p ${BASE}/build/libusb0_build
cd ${BASE}/build/libusb0_build
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ${SRCDIR}/libusb-compat-0.1.4/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch ${BASE}/build/.libusb0_done
fi
fi

if [ ! -f ${BASE}/build/.readline_done ]
then
mkdir -p ${BASE}/build/readline_build
cd ${BASE}/build/readline_build
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ${SRCDIR}/readline-6.3/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch ${BASE}/build/.readline_done
fi
fi

if [ ! -f ${BASE}/build/.ncurses_done ]
then
mkdir -p ${BASE}/build/ncurses_build
cd ${BASE}/build/ncurses_build
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ${SRCDIR}/ncurses-6.0/configure --prefix=${BASE}/build/$OS
make -j4 && make install
if [ $? == 0 ]; then
touch ${BASE}/build/.ncurses_done
fi
fi

if [ ! -f ${BASE}/build/.libftdi_done ]
then
mkdir -p ${BASE}/build/libftdi1_build
cd ${BASE}/build/libftdi1_build
cmake -DCMAKE_INSTALL_PREFIX=${BASE}/build/$OS/ ${SRCDIR}/libftdi1-1.2/
make && make install
if [ $? == 0 ]; then
touch ${BASE}/build/.libftdi_done
fi
fi

# HIDAPI

# if [ ! -f ${BASE}/build/.hidapi_done ]
# then
# mkdir -p ${BASE}/build/hidapi_build
# cd ${SRCDIR}/hidapi && ./bootstrap
# cd ${BASE}/build/hidapi_build
# LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ libusb_CFLAGS="-I${BASE}/build/$OS/include/libusb-1.0" \
#             libusb_LIBS="-L${BASE}/build/$OS/lib -lusb-1.0" ${SRCDIR}/hidapi/configure --prefix=${BASE}/build/$OS
# make && make install
# if [ $? == 0 ]; then
# touch ${BASE}/build/.hidapi_done
# fi
# fi

# LIBHID

# if [ ! -f ${BASE}/build/.libhid_done ]
# then
# mkdir -p ${BASE}/build/libhid_build
# cd ${SRCDIR}/libhid-0.2.16
# # patch -p1 < ${BASE}/patches/60-no-werror.patch
# cd ${BASE}/build/libhid_build
# LDFLAGS="$LDFLAGS -lusb-1.0" ${SRCDIR}/libhid-0.2.16/configure --prefix=${BASE}/build/$OS
# make && make install
# if [ $? == 0 ]; then
# touch ${BASE}/build/.libhid_done
# fi
# fi

if [ ! -f ${BASE}/build/.avrdude_done ]
then

mkdir -p ${BASE}/build/avrdude_build
cd ${SRCDIR}/avrdude-6.1
for p in ${BASE}/patches/*.patch; do echo Applying $p; patch -p1 < $p; done
cd ${BASE}/build/avrdude_build
#configuring avrdude
LD_LIBRARY_PATH=${BASE}/build/$OS/lib/ ${SRCDIR}/avrdude-6.1/configure --prefix=${PREFIX} --enable-linuxgpio
make
if [ $? == 0 ]; then
touch ${BASE}/build/.avrdude_done
fi
fi

$CC -Wall -Wno-pointer-sign -g -O2 -o avrdude avrdude-main.o avrdude-term.o ./libavrdude.a -lusb-1.0 -lusb -lftdi1 -lelf -lpthread -lm -lreadline -lncurses -lc --static -lc --static -ludev -L${BASE}/build/$OS/lib/

# stripping executable
strip avrdude

cp avrdude avrdude.conf ${BASE}/distrib/${OS}/
