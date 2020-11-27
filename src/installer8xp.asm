
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
	os_create
;-------------------------------------------------------------------------------

installing_string:
	db "Installing BOS...",0

;-------------------------------------------------------------------------------
	os_rom
;-------------------------------------------------------------------------------

file '../obj/bosos.bin'

