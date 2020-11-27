#!/bin/bash
mkdir bin
mkdir obj
echo "Building noti-ez80"
mkdir noti-ez80/obj
mkdir noti-ez80/bin
fasmg noti-ez80/src/main.asm noti-ez80/bin/NOTI.rom
echo "Building bos.inc"
python build_bos.inc.py
cp -f bos.inc src/include/bos.inc
cp -rf src/include src/data/adrive/src/
cp -rf src/data/adrive/src/include src/data/adrive/src/lib/
echo "Building filesystem"
cd src/data/adrive
chmod +x build.sh
./build.sh
cd ../../../
echo "Building OS"
fasmg src/main.asm obj/bosos.bin
echo "Building installer 8xp"
fasmg src/installer8xp.asm bin/BOSOS.8xp
echo "Building updater"
fasmg src/updater.asm bin/BOSUPDTR.BIN
echo "Building ROM"
fasmg src/rom.asm bin/BOSOS.rom
python build_docs.py
read -p "Finished. Press enter to continue."
