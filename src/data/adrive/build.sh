mkdir obj
fasmg src/lib/libload/bos_libload.asm src/lib/bos_libload.bin
fasmg src/lib/fatdrvce/fatdrvce.asm src/lib/fatdrvce.bin
fasmg src/lib/fileioc/fileioc.asm src/lib/fileioc.bin
fasmg src/lib/graphx/graphx.asm src/lib/graphx.bin
fasmg src/lib/srldrvce/srldrvce.asm src/lib/srldrvce.bin
fasmg src/lib/usbdrvce/usbdrvce.asm src/lib/usbdrvce.bin
fasmg src/explorer.asm src/explorer.bin
fasmg src/main.asm obj/main.bin
convbin -i obj/main.bin -o data.bin -j bin -k bin -c zx7
