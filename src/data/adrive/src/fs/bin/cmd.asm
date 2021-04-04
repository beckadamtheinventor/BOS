
	jq cmd_exe_main
	db "FEX",0
cmd_exe_main:
	ld hl,bos.current_working_dir
	call bos.gui_DrawConsoleWindow
	ld hl,-6
	call ti._frameset
	or a,a
	sbc hl,hl
	ld (ix-6),hl
	ld hl,256
	push hl
	call bos.sys_Malloc
	pop bc
	ret c
	ld (ix-3),hl
	ld bc,256
	call bos._MemClear
enter_input_clear:
	ld hl,bos.InputBuffer
	ld bc,256
	call bos._MemClear
	jq enter_input
recall_last:
	ld hl,(ix-3)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,enter_input
	push hl
	call ti._strlen
	add hl,bc
	or a,a
	sbc hl,bc
	ex (sp),hl
	pop bc
	jq z,enter_input
	ld de,bos.InputBuffer
	ldir
enter_input:
	ld bc,255
	push bc
	ld bc,bos.InputBuffer
	push bc
	call bos.gui_InputNoClear
	pop bc,hl
	or a,a
	jq z,.exit
	cp a,12
	jq z,recall_last
	cp a,10
	jq z,enter_input
	push hl,bc
	call ti._strlen
	ex (sp),hl
	pop bc
	push bc,hl
	inc bc
	ld de,(ix-3)
	ldir
	pop hl,bc,de
.get_args:
	push hl
	ld a,' '
	cpir
	jq nz,.noargs
	dec hl
	ld (hl),0 ;replace the space with null so the file is easier to open
	inc hl ;bypass the space lol
.noargs:
	ex (sp),hl ;args
	push hl ;path
	ld a,(hl)
	or a,a
	jq z,.dont_execute_null
	call bos.fs_OpenFile
	jq c,.system_exe
.execute:
	call bos.sys_ExecuteFile
	pop bc,bc
	push hl
	ld hl,(ix-6)
	push hl
	call bos.sys_Free
	pop bc
	or a,a
	sbc hl,hl
	ld (ix-6),hl
	pop hl
	ld (bos.ScrapMem),hl
	ld a,(bos.ScrapMem+2)
	or a,h
	or a,l
	jq z,enter_input_clear
	push hl
	call bos.gfx_BlitBuffer
	xor a,a
	ld (bos.curcol),a
	ld hl,str_ProgramFailedWithCode
	call bos.gui_PrintString
	pop hl
	call bos.gui_PrintInt
	call bos.gui_NewLine
	ld a,$FF
	call bos.gfx_BlitBuffer
	jq enter_input_clear
.dont_execute_null:
	pop bc,bc
	jq enter_input_clear
.exit:
	ld hl,(ix-3)
	push hl
	call bos.sys_Free
	pop bc
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
.system_exe:
	call ti._strlen
	ex (sp),hl
	pop bc
	push bc,hl
	ld hl,str_system_drive.len
	add hl,bc
	push hl
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl,bc
	jq c,.exit
	push de,bc,hl
	ld hl,str_system_drive
	ld bc,str_system_drive.len
	ldir
	pop hl,bc
	ldir
	xor a,a
	ld (de),a
	call bos.fs_OpenFile
	jq nc,.execute
.fail:
	pop bc,bc
	ld hl,str_CouldNotLocateExecutable
	call bos.gui_Print
	jq enter_input
str_system_drive:
	db "/bin/"
.len:=$-.
str_ProgramFailedWithCode:
	db "Error Code ",0

str_CouldNotLocateExecutable:
	db $9,"Could not locate executable",$A,0
