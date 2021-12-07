#!/bin/bash
currpath=`pwd`;
case $1 in
    0) ;;
    *platform*) tag=$1;;
    *) tag=11.0.0_r$1;;
esac

caf=$2;

function TagAosp() {
for i in $1;
do
cd $i; echo $i;
$echo pll aosp $tag $2;
cd $currpath;
done
}

function fullAosp() {
local list="
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

TagAosp "build/make" "build";
TagAosp "$list";
TagAosp "`repo list -r system/ -p | grep -v 'vendor/'`" ;
TagAosp "`repo list -r packages/ -p | grep -v 'vendor/'`" ;
}

function TagCAF(){
local_name_list=$3
local_path=$2
caf_path=$1

for local_name in $local_name_list;
do
full_path=$local_path/$local_name
cd $full_path; echo $full_path;
if [ -n "$4" ]; then local_name=""; fi
$echo pll caf $caf $caf_path/$local_name;
cd $currpath;
done
}

function fullCAF() {
local list="
audio-hal/st-hal
data-ipa-cfg-mgr
dataservices
healthd-ext
thermal-engine
usb
"

local list2="
audio
display
media"

TagCAF "hardware/qcom" "hardware/qcom-caf/sm8150" "$list2"
TagCAF "vendor/qcom-opensource" "vendor/qcom/opensource" "$list"
}

if [ -n "$tag" ]; then fullAosp; fi
if [ -n "$caf" ]; then fullCAF; fi
