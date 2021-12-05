
include 'include/ti84pceg.inc'
include 'include/ez80.inc'

include 'include/os.inc'
include 'include/defines.inc'
include 'include/bos.inc'

org ti.userMem

os_rom
	file '../obj/bosos.bin'
end os_rom

	jr updater_start
	db "REX",0
updater_start:
	ld hl,installing_string
	call bos.gui_DrawConsoleWindow
	ld hl,os_second_binary_file
	push hl
	call bos.fs_GetFilePtr
	ld (os_second_binary),hl
	ld (os_second_binary.len),bc
	pop bc
	jr nc,.update
	ld hl,missing_second_binary
	call bos.gui_PrintLine
	jp bos.sys_WaitKeyCycle
.update:
	os_create $04 ;just overwrite OS sectors, let the boot process do the rest
	ld a,(bos._UnpackUpdates)
	cp a,$C3
	jp z,bos._UnpackUpdates
	rst 0


installing_string:
	db "Updating BOS...",0
missing_second_binary:
	db "Missing "
os_second_binary_file:
	db "BOSOSPT2.BIN",0

write_os_binary

