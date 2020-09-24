
include 'include/ti84pceg.inc'
include 'include/ti84pce.inc'
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

	jp boot_os

include 'table.asm'
include 'boot.asm'
include 'gfx.inc'
include 'str.inc'
include 'sys.inc'
include 'util.inc'
include 'fs.inc'
include 'gui.inc'
include 'usb.inc'
include 'data.inc'
DONOTHING:
	ret
