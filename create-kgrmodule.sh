#!/bin/bash

TOOLPATH=`dirname $0`
KGRAFTBUILD=kgrafttmp

if ! test -f vmlinux.o; then
    echo "vmlinux.o needs to exist in cwd"
    exit 1
fi
if test -z "$1"; then
    echo "usage: $0 [list of symbols to extract]"
    exit 2
fi

$TOOLPATH/extract-syms.sh $@
mkdir -p $KGRAFTBUILD
mv extracted.o $KGRAFTBUILD

$TOOLPATH/create-stub.sh $@ > $KGRAFTBUILD/kgrstub.c

cd $KGRAFTBUILD
cat <<EOF > Makefile
obj-m = kgrmodule.o
kgrmodule-y += kgrstub.o extracted.o

all:
	make -C .. M=\$(PWD) modules
EOF

make

cd ..
ls -l $KGRAFTBUILD/kgrmodule.ko
