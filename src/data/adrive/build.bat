@echo off
mkdir obj
fasmg src/lib/libload/bos_libload.asm obj/bos_libload.bin
fasmg src/lib/fatdrvce/fatdrvce.asm obj/fatdrvce.bin
fasmg src/lib/fileioc/fileioc.asm obj/fileioc.bin
fasmg src/lib/graphx/graphx.asm obj/graphx.bin
fasmg src/lib/srldrvce/srldrvce.asm obj/srldrvce.bin
fasmg src/lib/usbdrvce/usbdrvce.asm obj/usbdrvce.bin
fasmg src/explorer.asm obj/explorer.bin
fasmg src/fexplore.asm obj/fexplore.bin
fasmg src/memedit.asm obj/memedit.bin


fasmg src/main.asm obj/main.bin
convbin -i obj/main.bin -o data.bin -j bin -k bin -c zx7