## solve broken dependencies
sudo apt install libnl-3-200=3.7.0-0.3build1 libnl-3-dev libnl-route-3-200=3.7.0-0.3build1 libnl-route-3-dev ibverbs-providers=50.0-2build2 libibverbs1=50.0-2build2 libnl-3-dev libnl-route-3-dev libibverbs-dev libicu74=74.2-1ubuntu3 libicu-dev libnuma1=2.0.18-1build1 libnuma-dev zlib1g=1:1.3.dfsg-3.1ubuntu2 zlib1g-dev libboost-all-dev libeigen3-dev
sudo apt install libpcre2-8-0=10.42-4ubuntu2 libpcre2-dev libselinux1=3.5-2ubuntu2 libselinux1-dev libzstd1=1.5.5+dfsg2-2build1 libzstd-dev libgstreamer1.0-dev gstreamer1.0-plugins-good gstreamer1.0-tools

## make test avi
gst-launch-1.0 -v -e v4l2src device=/dev/video0 ! jpegenc ! image/jpeg,width=640,height=480,framerate=30/1 ! avimux ! filesink location=file.avi

## make test yuv file
gst-launch-1.0 -v -e v4l2src device=/dev/video0 ! jpegenc ! image/jpeg,width=640,height=480,framerate=30/1 ! jpegdec ! filesink location=file.yuv

gst-launch-1.0 -v -e autovideosrc ! jpegenc ! image/jpeg,width=640,height=480,framerate=30/1 ! jpegdec ! filesink location=file.yuv

## play yuv with VLC
/Applications/_downloaded/VLC.app/Contents/MacOS/VLC --rawvid-fps 30 --rawvid-width 640 --rawvid-height 480 --rawvid-chroma I420 file.yuv

## play vid
gst-launch-1.0 -v -e autovideosrc ! jpegenc ! image/jpeg,width=640,height=480,framerate=30/1 ! jpegdec ! autovideosink

## Compile
gcc -Wall main.c -o main $(pkg-config --cflags --libs gstreamer-1.0)

## list caps of all camera devices
gst-device-monitor-1.0

## test streaming
gst-launch-1.0 -v videotestsrc ! jpegenc ! "image/jpeg,width=1280,height=720,framerate=30/1" ! rtpjpegpay ! udpsink host=192.168.1.155  port=5001

gst-launch-1.0 -e -v udpsrc port=5001 ! application/x-rtp,encoding-name=JPEG,payload=26 ! rtpjpegdepay ! jpegdec ! autovideosink

## compiling for Mac OS
export PKG_CONFIG_PATH=/Library/Frameworks/GStreamer.framework/Versions/1.0/lib/pkgconfig
export PATH=/Library/Frameworks/GStreamer.framework/Versions/1.0/bin:$PATH

## Compiling 
gcc $(find . -name '*.c') -pthread -lm $(pkg-config --cflags --libs gstreamer-1.0 gstreamer-app-1.0)

## Synthesising verilog
yosys -p 'synth_ice40 -top TopEntity -json ice40.json' TopEntity.v
nextpnr-ice40 --hx8k --json ice40.json --pcf ico-jiwy.pcf --asc ice40.asc
icepack ice40.asc ice40.bin

## Uploading veriolog
sudo modprobe spi-bcm2835 -r
./icoprog -R
./icoprog -p < ice40.bin
sudo modprobe spi-bcm2835