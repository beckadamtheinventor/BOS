@echo off
mkdir obj
fasmg src/lib/libload/bos_libload.asm obj/bos_libload.bin
fasmg src/lib/fatdrvce/fatdrvce.asm obj/fatdrvce.bin
fasmg src/lib/fileioc/fileioc.asm obj/fileioc.bin
fasmg src/lib/fontlibc/fontlibc.asm obj/fontlibc.bin
fasmg src/lib/graphx/graphx.asm obj/graphx.bin
fasmg src/lib/keypadc/keypadc.asm obj/keypadc.bin
fasmg src/lib/srldrvce/srldrvce.asm obj/srldrvce.bin
fasmg src/lib/usbdrvce/usbdrvce.asm obj/usbdrvce.bin

fasmg src/lib/libload_alt/libload_alt.asm obj/libload_alt.bin

fasmg src/explorer.asm obj/explorer.bin
fasmg src/files.asm obj/files.bin
fasmg src/fexplore.asm obj/fexplore.bin
fasmg src/memedit.asm obj/memedit.bin
fasmg src/usbrun.asm obj/usbrun.bin
fasmg src/usbsend.asm obj/usbsend.bin

fasmg src/dev_mnt/init.asm src/dev_mnt/init.bin
fasmg src/dev_mnt/deinit.asm src/dev_mnt/deinit.bin
fasmg src/dev_mnt/read.asm src/dev_mnt/read.bin
fasmg src/dev_mnt/write.asm src/dev_mnt/write.bin

fasmg src/main.asm obj/main.bin
convbin -i obj/main.bin -o data.bin -j bin -k bin -c zx7
