#!/bin/bash
currpath=`pwd`;
tag=$1;

function foriin() {
for i in $1;
do
cd $i; echo $i;
$echo pll aosp 11.0.0_r$tag $2;
cd $currpath;
done
}

list="
art
bionic
build/soong
build/blueprint
bootable/recovery
development
libcore
external/boringssl
external/cldr
external/e2fsprogs
external/gptfdisk
external/guice
external/icu
external/libcxx
external/mksh
external/perfetto
external/tinyalsa
external/tinycompress
external/toybox
frameworks/av
frameworks/base
frameworks/libs/systemui
frameworks/native
frameworks/opt/net/ims
frameworks/opt/net/wifi
frameworks/opt/telephony
hardware/broadcom/libbt
hardware/interfaces
hardware/libhardware
hardware/nxp/nfc
hardware/ril
"
foriin "build/make" "build";
foriin "$list";
foriin "`repo list -r system/ -p | grep -v 'vendor/'`" ;
foriin "`repo list -r packages/ -p | grep -v 'vendor/'`" ;
