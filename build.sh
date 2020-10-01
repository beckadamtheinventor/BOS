#!/bin/bash
mkdir bin
python build_bos.inc.py
cp -f bos.inc src/include/bos.inc
cp -rf src/include src/data/adrive/src/include/
cp -rf src/data/adrive/src/include src/data/adrive/src/lib/include/
cd src/data/adrive
bash build.sh
cd ../../../
fasmg src/main.asm bin/BOS.8xp
python build_docs.py
read -p "Finished. Press enter to continue."
