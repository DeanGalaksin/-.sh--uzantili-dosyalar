#!/bin/bash

echo "Hangi kamerayı çalıştırmak istiyorsunuz? (RK/DRIVE/BILIM)"
read CAMERA

# Bilgisayarın IP adresini al
TARGET_IP=$(hostname -I | awk '{print $1}')

echo "Veriler $TARGET_IP adresine gönderilecek."

# DRIVE kamerasını başlat
if [ "$CAMERA" == "DRIVE" ]; then
  sshpass -p "iturover123" ssh iturover_drive@192.168.1.96 << EOF &
gst-launch-1.0 -e v4l2src device=/dev/v4l/by-path/platform-xhci-hcd.0-usbv2-0:2:1.0-video-index0 ! image/jpeg, width=320, height=240, framerate=30/1 ! jpegparse ! jpegdec ! videoconvert ! videorate ! video/x-raw,framerate=24/1 ! videoconvert ! video/x-raw,format=I420 ! x264enc tune=zerolatency speed-preset=0 bitrate=250 ! h264parse ! rtph264pay ! udpsink host=$TARGET_IP port=1235 -e v4l2src device=/dev/v4l/by-path/platform-xhci-hcd.1-usbv2-0:2:1.0-video-index0 ! image/jpeg, width=320, height=240, framerate=30/1 ! jpegparse ! jpegdec ! videoconvert ! videorate ! video/x-raw,framerate=24/1 ! videoconvert ! video/x-raw,format=I420 ! x264enc tune=zerolatency speed-preset=0 bitrate=250 ! h264parse ! rtph264pay ! udpsink host=$TARGET_IP port=1236 -e v4l2src device=/dev/v4l/by-path/platform-xhci-hcd.0-usbv2-0:1:1.0-video-index0 ! image/jpeg, width=320, height=240, framerate=30/1 ! jpegparse ! jpegdec ! videoconvert ! videorate ! video/x-raw,framerate=24/1 ! videoconvert ! video/x-raw,format=I420 ! x264enc tune=zerolatency speed-preset=0 bitrate=250 ! h264parse ! rtph264pay ! udpsink host=$TARGET_IP port=1234
drive_pid=$!
EOF

# RK kamerasını başlat
elif [ "$CAMERA" == "RK" ]; then
  sshpass -p "iturover123" ssh iturover_drive@192.168.1.98 << EOF &
gst-launch-1.0 -e v4l2src device=/dev/v4l/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.1:1.0-video-index0 ! image/jpeg, width=320, height=240, framerate=30/1 ! jpegparse ! jpegdec ! videoconvert ! videorate ! video/x-raw,framerate=24/1 ! videoflip method=rotate-180 ! videoconvert ! video/x-raw,format=I420 ! x264enc tune=zerolatency speed-preset=0 bitrate=250 ! h264parse ! rtph264pay ! udpsink host=$TARGET_IP port=1234 -e v4l2src device=/dev/v4l/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.2:1.0-video-index0 ! image/jpeg, width=1024, height=768, framerate=30/1 ! jpegparse ! jpegdec ! videoconvert ! videorate ! video/x-raw,framerate=24/1 ! videoconvert ! video/x-raw,format=I420 ! xf264enc tune=zerolatency speed-preset=0 bitrate=250 ! h264parse ! rtph264pay ! udpsink host=$TARGET_IP port=1235 -e v4l2src device=/dev/v4l/by-path/platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.3:1.0-video-index0 ! image/jpeg, width=1024, height=768, framerate=30/1 ! jpegparse ! jpegdec ! videoconvert ! videorate ! video/x-raw,framerate=24/1 ! videoconvert ! video/x-raw,format=I420 ! x264enc tune=zerolatency speed-preset=0 bitrate=250 ! h264parse ! rtph264pay ! udpsink host=$TARGET_IP port=1236
rk_pid=$!
EOF

# BILIM kamerasını başlat
elif [ "$CAMERA" == "BILIM" ]; then
  sshpass -p "123123" ssh itu-rover@192.168.1.7 << EOF &
gst-launch-1.0 -e v4l2src device=/dev/v4l/by-path/pci-0000:00:14.0-usb-0:2:1.0-video-index0 ! image/jpeg, width=320, height=240, framerate=30/1 ! jpegparse ! jpegdec ! videoconvert ! videorate ! video/x-raw,framerate=24/1 ! videoflip method=rotate-180 ! videoconvert ! video/x-raw,format=I420 ! x264enc tune=zerolatency speed-preset=0 bitrate=250 ! h264parse ! rtph264pay ! udpsink host=$TARGET_IP port=1237 -e v4l2src device=/dev/v4l/by-path/pci-0000:00:14.0-usb-0:3:1.0-video-index0 ! image/jpeg, width=1024, height=768, framerate=30/1 ! jpegparse ! jpegdec ! videoconvert ! videorate ! video/x-raw,framerate=24/1 ! videoconvert ! video/x-raw,format=I420 ! x264enc tune=zerolatency speed-preset=0 bitrate=750 ! h264parse ! rtph264pay ! udpsink host=$TARGET_IP port=1235 -e v4l2src device=/dev/v4l/by-path/pci-0000:00:14.0-usb-0:5:1.0-video-index0 ! image/jpeg, width=1024, height=768, framerate=30/1 ! jpegparse ! jpegdec ! videoconvert ! videorate ! video/x-raw,framerate=24/1 ! videoconvert ! video/x-raw,format=I420 ! x264enc tune=zerolatency speed-preset=0 bitrate=750 ! h264parse ! rtph264pay ! udpsink host=$TARGET_IP port=1236 -e v4l2src device=/dev/v4l/by-path/pci-0000:00:14.0-usb-0:6:1.0-video-index0 ! image/jpeg, width=320, height=240, framerate=30/1 ! jpegparse ! jpegdec ! videoconvert ! videorate ! video/x-raw,framerate=24/1 ! videoconvert ! video/x-raw,format=I420 ! x264enc tune=zerolatency speed-preset=0 bitrate=250 ! h264parse ! rtph264pay ! udpsink host=$TARGET_IP port=1237
bilim_pid=$!
EOF

else
  echo "Geçersiz seçim. Lütfen RK, DRIVE veya BILIM giriniz."
  exit 1
fi

# Kameraları kapat
terminate() {
  echo "Kameralar durduruluyor..."
  if [ "$CAMERA" == "DRIVE" ]; then
    sshpass -p "iturover123" ssh iturover_drive@192.168.1.96 'pkill -f gst-launch-1.0'
  elif [ "$CAMERA" == "RK" ]; then
    sshpass -p "iturover123" ssh iturover_drive@192.168.1.98 'pkill -f gst-launch-1.0'
  elif [ "$CAMERA" == "BILIM" ]; then
    sshpass -p "123123" ssh itu-rover@192.168.1.7 'pkill -f gst-launch-1.0'
  fi
  exit 0
}

# Ctrl+C sinyalini yakala ve terminate fonksiyonunu çağır
trap terminate SIGINT

# Sonsuz döngüde bekleyin
while true; do
  sleep 1
done

