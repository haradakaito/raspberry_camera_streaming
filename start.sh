#!/bin/sh

PORT="8080"
WINDOWSIZE="640x480"
FRAMERATE="30"
export LD_LIBRARY_PATH=/usr/local/lib
mjpg_streamer -i "input_uvc.so -f $FRAMERATE -r $WINDOWSIZE -d /dev/video0 -y -n" \ -o "output_http.so -w /usr/local/share/mjpg-streamer/www -p $PORT"

export LD_LIBRARY_PATH="$(pwd)"
./mjpg_streamer -i "./input_uvc.so" -o "./output_http.so -w ./www"