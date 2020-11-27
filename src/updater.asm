
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

file '../obj/bosos.bin'

