@echo off
mkdir bin
call src/fs/adrive/build.bat
fasmg src/main.asm bin/BOSOS.8xp
pause