@echo off
REM Script chạy Flutter trên nhiều thiết bị cùng lúc (Windows)

echo Dang cai dat dependencies...
call flutter pub get

echo Dang khoi dong Chrome...
start cmd /k "flutter run -d chrome"

timeout /t 3 /nobreak

echo Dang khoi dong Android...
start cmd /k "flutter run -d android"

echo Da khoi dong ca 2 thiet bi!
pause
