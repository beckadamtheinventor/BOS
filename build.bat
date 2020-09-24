@echo off
mkdir bin
python build_bos.inc.py
xcopy /Y bos.inc src\include\
xcopy /Y src\include src\data\adrive\src\include\
cd src\data\adrive\
call build.bat
cd ..\..\..\
fasmg src/main.asm bin/BOSOS.8xp
python build_docs.py
pause