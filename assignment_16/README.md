## Set up the Raspberry Pi

These stepes were executed from a fresh Ubuntu 24.04 LTS server install 

### Install necessary dependencies
```bash
apt install yosys nextpnr-ice40-qt
apt install libboost-all-dev libeigen3-dev
apt install qtcreator qtbase5-dev qt5-qmake fpga-icestorm g++ raspi-config
apt install git libgpiod-dev gpiod
apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-good gstreamer1.0-tools
apt install libunwind-dev
```
> At time of writing, apt fails to install dependencies for `libboost-all-dev`, `libeigen3-dev`, `libunwind-dev` and `libgstreamer1.0-dev` automatically, if this happens install the dependencies manually with the required versions, as indicated by apt.

### Clone and compile IcoProg
```bash
git clone https://git.ram.eemcs.utwente.nl/repository-esl/icoprog.git
cd icoprog 
g++ src/icoprog.cpp src/gpio_interface.cpp -o icoprog -lgpiodcxx
```

## Verilog FPGA

### Synthesising verilog
```bash
cd verilog
yosys -p 'synth_ice40 -top TopEntity -json ice40.json' TopEntity.v
nextpnr-ice40 --hx8k --json ice40.json --pcf ico-jiwy.pcf --asc ice40.asc
icepack ice40.asc ice40.bin
```

### Uploading veriolog
```bash
sudo modprobe spi-bcm2835 -r
./icoprog -R
./icoprog -p < ice40.bin
sudo modprobe spi-bcm2835
```

## C-code

> To specific which IP and port to stream the video to, set `STREAM_IP` and `STREAM_PORT` on `c/constants.h`.
> To run without a video stream, set the `STREAM_IMAGE` constant to 0.

### Compile and run code

```bash
cd c
gcc $(find . -name '*.c') -pthread -lm $(pkg-config --cflags --libs gstreamer-1.0 gstreamer-app-1.0) -o output.o
./output.o
```

### Watch stream (on the specified IP)

````bash
gst-launch-1.0 -e -v udpsrc port=5001 ! application/x-rtp,encoding-name=JPEG,payload=26 ! rtpjpegdepay ! jpegdec ! autovideosink
```