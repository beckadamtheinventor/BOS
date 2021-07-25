	jq updater_main
	db "FEX",0
updater_main:
	ld hl,str_UpdateProgram
	ld bc,str_UpdateFile
	push bc,hl
	call bos.sys_ExecuteFile
	pop bc,bc
	ret
str_UpdateProgram:
	db "/bin/usbrun",0
str_UpdateFile:
	db "/BOSUPDTR.BIN",0

