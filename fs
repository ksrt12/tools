#!/bin/bash
dev=`cat .localconfig | grep "dev=" | cut -d '=' -f 2`
echo $dev
rom=RR
#rtr=1
function rff() {
sudo fastboot reboot
if [ "$rtr" == "1" ]; then rtrc="adb wait-for-device;adb reboot recovery"; fi
}
function rebtl() {
if [ "`fastboot devices`" == "" ]; then adb reboot bootloader;fi
}
function flimg() {
rebtl;
for i in $@
do
out=out;
#if [ "$i" == "recovery" ]; then out=out_twrp; rtrc=1; else out=out; fi
echo sudo fastboot flash $i `pwd`/$out/target/product/$dev/$i.img
sudo fastboot flash $i `pwd`/$out/target/product/$dev/$i.img
done
rff;
if [ "$rtr" == "1" ]; then
adb wait-\for-device
adb reboot recovery
fi
};

function pshim() {
adb remount;
adb push `pwd`/out/target/product/cherryplus/system/lib64/libshim.so /system/lib64
adb push `pwd`/out/target/product/cherryplus/system/lib/libshim.so /system/lib
fs b;
}
function args() {
case $1 in
br) flimg boot recovery;;
b) flimg boot;;
r) flimg recovery;;
s) pshim;;
*) flboot;;
esac
}
 
for arg in $@
do
args $arg
done
