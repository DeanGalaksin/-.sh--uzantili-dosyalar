#!/bin/bash

echo "Hangi kamerayı görüntülemek istiyorsunuz? (RK/DRIVE/BILIM)"
read CAMERA

terminate() {
  echo "Kameralar durduruluyor..."
  pkill -f gst-launch-1.0
  exit 0
}

trap terminate SIGINT

if [ "$CAMERA" == "DRIVE" ]; then
  gst-launch-1.0 -e udpsrc port=1234 ! application/x-rtp,encoding-name=H264,payload=26 ! rtph264depay ! avdec_h264 ! videoflip method=rotate-180 ! queue ! autovideosink  -e udpsrc port=1235 ! application/x-rtp,encoding-name=H264,payload=26 ! rtph264depay ! avdec_h264 ! videoflip method=rotate-180 ! queue ! autovideosink -e udpsrc port=1236 ! application/x-rtp,encoding-name=H264,payload=26 ! rtph264depay ! avdec_h264 ! videoflip method=rotate-180 ! queue ! autovideosink

elif [ "$CAMERA" == "RK" ]; then
  gst-launch-1.0 -e udpsrc port=1234 ! application/x-rtp,encoding-name=H264,payload=26 ! rtph264depay ! avdec_h264 ! queue ! autovideosink -e udpsrc port=1235 ! application/x-rtp,encoding-name=H264,payload=26 ! rtph264depay ! avdec_h264 ! videoflip method=rotate-180 ! queue ! autovideosink -e udpsrc port=1236 ! application/x-rtp,encoding-name=H264,payload=26 ! rtph264depay ! avdec_h264 ! videoflip method=rotate-180 ! queue ! autovideosink

elif [ "$CAMERA" == "BILIM" ]; then
  gst-launch-1.0 -e udpsrc port=1237 ! application/x-rtp,encoding-name=H264,payload=26 ! rtph264depay ! avdec_h264 ! queue ! autovideosink -e udpsrc port=1235 ! application/x-rtp,encoding-name=H264,payload=26 ! rtph264depay ! avdec_h264 ! videoflip method=rotate-180 ! queue ! autovideosink -e udpsrc port=1238 ! application/x-rtp,encoding-name=H264,payload=26 ! rtph264depay ! avdec_h264 ! queue ! autovideosink -e udpsrc port=1239 ! application/x-rtp,encoding-name=H264,payload=26 ! rtph264depay ! avdec_h264 ! queue ! autovideosink

else
  echo "Geçersiz seçim. Lütfen RK, DRIVE veya BILIM giriniz."
fi

