
include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/tiformat.inc'
format ti executable 'BOSOS'

include 'include/os.inc'
include 'include/defines.inc'


	call ti.ClrLCD
	call ti.HomeUp
	ld hl,installing_string
	call ti.PutS

;-------------------------------------------------------------------------------
	os_create $05 ;erase up until sector $05 to erase OS sectors and trigger BOS to format the filesystem.
;-------------------------------------------------------------------------------

installing_string:
	db "Installing BOS...",0

;-------------------------------------------------------------------------------
	os_rom
;-------------------------------------------------------------------------------

file '../obj/bosos.bin'

