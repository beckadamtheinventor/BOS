
include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/tiformat.inc'

include 'include/os.inc'
include 'include/defines.inc'

ROM_BUILD:
file '../noti-ez80/bin/NOTI-autoboot.rom'
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

	; include 'src/data/root_partition.asm'
	; db $040100-$ dup $FF

	; file 'src/data/adrive/main.bin'
	; db $010000 - ($ and $FFFF) dup $FF

	; include 'src/data/root_dir_data.asm'
	; db "EXTRACT OPT", 0, $FF, $FF, $FF, $FF

; assert $ and $FF < $F0
	; db $F0 - ($ and $FF) dup $FF
	; db $FE, 15 dup $FF
