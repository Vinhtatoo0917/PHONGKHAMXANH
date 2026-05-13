#!/bin/bash

# Script chạy Flutter trên nhiều thiết bị cùng lúc

echo "Đang cài đặt dependencies..."
flutter pub get

echo "Đang khởi động Chrome..."
flutter run -d chrome &

echo "Đợi 5 giây..."
sleep 5

echo "Đang khởi động Android..."
flutter run -d android &

echo "Đã khởi động cả 2 thiết bị!"
echo "Nhấn Ctrl+C để dừng tất cả"

wait
