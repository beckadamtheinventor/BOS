
include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/tiformat.inc'

include 'include/os.inc'
include 'include/defines.inc'

ROM_BUILD:
file '../noti-ez80/bin/NOTI.rom'
;-------------------------------------------------------------------------------
	os_rom
;-------------------------------------------------------------------------------

	file '../obj/bosos.bin'

;-------------------------------------------------------------------------------
	end os_rom
;-------------------------------------------------------------------------------

	write_os_binary

	file 'src/data/adrive/data.bin'

	db $040000-$ dup $FF

	db "bos512fsfs ", $14
	dw fs_root_dir_lba ; LBA of the root directory
	dw 512 ; directory section size
	db 512-16 dup $FF

	file 'data/adrive/main.bin'

