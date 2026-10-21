@echo off
powershell -Command "Compress-Archive -Path 'src/*' -DestinationPath 'SpaceStation15.zip' -Force"
ren SpaceStation15.zip SpaceStation15.love
pause
