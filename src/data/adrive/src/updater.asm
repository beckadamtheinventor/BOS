

include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org $D1A881
	jq updater_main
	db "REX",0
updater_main:
	ld hl,str_UpdateProgram
	ld bc,str_UpdateFile
	push bc,hl
	call bos.sys_ExecuteFile
	pop bc,bc
	ret
str_UpdateProgram:
	db "usbrun",0
str_UpdateFile:
	db "/BOSUPDTR.BIN",0
