
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

	db $040000-$ dup $FF

	file 'data/adrive/main.bin'

