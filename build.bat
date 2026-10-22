@echo off
mkdir "build"
mkdir "build/resources"
robocopy "resources" "build/resources/" /E
robocopy "src" "build/" /E
powershell -Command "Compress-Archive -Path 'build/*' -DestinationPath 'SpaceStation15.zip' -Force"
del SpaceStation15.love
ren SpaceStation15.zip SpaceStation15.love
del build
pause
