
include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/tiformat.inc'

include 'include/os.inc'
include 'include/defines.inc'
include 'include/bos.inc'


org ti.userMem

updater_start:
	call bos._ClrScrn
	call bos._HomeUp
	ld hl,installing_string
	call bos._PutS

;-------------------------------------------------------------------------------
	os_create
;-------------------------------------------------------------------------------

installing_string:
	db "Installing BOS...",0

;-------------------------------------------------------------------------------
	os_rom
;-------------------------------------------------------------------------------

include 'table.asm'
include 'boot.asm'
include 'gfx.inc'
include 'str.inc'
include 'sys.inc'
include 'util.inc'
include 'fs.inc'
include 'gui.inc'
include 'data.inc'
include 'compatibility.inc'

DONOTHING:
	ret

macro exaf
	db $08 ;why does the comma in ex af,af' have to screw with things? >_>
end macro


