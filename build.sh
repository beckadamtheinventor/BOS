#!/bin/bash
mkdir bin
bash src/fs/adrive/build.sh
fasmg src/main.asm bin/BOS.8xp
read -p "Finished. Press enter to continue."
