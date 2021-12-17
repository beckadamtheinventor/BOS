
	jq cmd_exe_main
	db "FEX",0
cmd_exe_main:
	ld hl,-29
	call ti._frameset
	xor a,a
	sbc hl,hl
	ld (ix-10),a
	ld (ix-6),hl
	ld (ix-9),hl
	ld (ix-22),hl
	ld hl,(ix+6)
	push hl
	call ti._strlen
	ld (ix-19),hl
	pop hl
	ld a,(hl)
	or a,a
	jq z,cmd_no_cmd_args

	ld (ix-16),hl
	cp a,'-'
	jq nz,cmd_execute_next_line ;if first argument isn't a flag
	inc hl
	ld a,(hl)
	inc hl
	inc hl
	ld (ix-16),hl
	cp a,'h'
	jq z,cmd_print_help_info
	cp a,'x'
	jq nz,.not_exec_file
	push hl
	call bos.fs_GetFilePtr
	jq c,cmd_exit_retneg1
	ld (ix-16),hl
	ld (ix-19),bc
	pop hl
	jq cmd_execute_next_line
.not_exec_file:
	ld (ix-10),a
	cp a,'a'
	jq z,cmd_execute_next_line
	cp a,'i'
	jq z,cmd_execute_next_line

cmd_print_help_info:
	ld hl,cmd_help_info
	call bos.gui_PrintLine
	jq cmd_exit_retzero

;execute argument as if from command line if argument passed
cmd_execute_next_line:
.loop:
	ld bc,(ix-19)
	ld a,b
	or a,c
	jq z,cmd_exit_retzero
	ld de,(ix-22)
	push de
	call bos.sys_Free
	pop bc
	ld hl,(ix-16)
	ld (ix-25),hl
	ld bc,(ix-19)
	ld a,(hl)
	push af
	call .linelen
	pop af
	ld (ix-13),de
	ld (ix-16),hl
	ld (ix-19),bc
	cp a,'#'
	jq z,.nextline ;only copy line and execute if line not commented
	ld a,e
	or a,d
	jq z,.nextline
	push de
	call bos.sys_Malloc
	pop bc
	jq c,cmd_exit_retneg2 ;return if failed to malloc
	ld (ix-22),hl
	ex hl,de
	ld hl,(ix-25)
	ld bc,(ix-13)
	push de
	ldir ;copy the line from the file into a null-terminated buffer
	xor a,a
	ld (de),a
	pop hl
	call execute_program_string
	ld a,(ix-10)
	or a,a
	jq nz,.nextline
	ld hl,(ix-9)
	add hl,bc
	or a,a
	sbc hl,bc
	jq nz,cmd_exit
.nextline:
	ld hl,(ix-19)
	add hl,bc
	or a,a
	sbc hl,bc
	jq nz,.loop ;execute next line if there are more characters in the file to be read
	ld a,(ix-10)
	cp a,'i'
	jq nz,.returnerrorcode
	sbc hl,hl
	jq cmd_exit

.linelen:
	ld de,0
	ld a,b
	or a,c
	ret z
.linelenloop:
	ld a,(hl)
	or a,a
	ret z
	inc hl
	dec bc
	cp a,$A
	ret z
	inc de
	ld a,b
	or a,c
	jq nz,.linelenloop
	ret

;exit returning last executable's error code
.returnerrorcode:
	ld hl,(ix-9)
	jq cmd_exit

cmd_no_cmd_args:
	xor a,a
	ld (bos.lcd_text_bg),a
	ld (bos.lcd_text_bg2),a
	dec a
	ld (bos.lcd_text_fg),a
	ld a,5
	ld (bos.lcd_text_fg2),a
	ld (bos.cursor_color),a
	ld hl,bos.current_working_dir
	call bos.gui_DrawConsoleWindow
enter_input_clear:
	ld hl,bos.InputBuffer
if bos.InputBuffer and $FF
	ld b,0
else
	ld b,l
end if
	ld c,b
.clear_buffer_loop:
	ld (hl),c
	inc hl
	djnz .clear_buffer_loop
	; jq enter_input
recall_last: ; TODO: re-implement this in a less hacky way
	; ld hl,(ix-3)
	; add hl,bc
	; or a,a
	; sbc hl,bc
	; jq z,enter_input
	; push hl
	; call ti._strlen
	; add hl,bc
	; or a,a
	; sbc hl,bc
	; ex (sp),hl
	; pop bc
	; jq z,enter_input
	; ld de,bos.InputBuffer
	; ldir
enter_input:
	ld bc,255
	push bc
	ld bc,bos.InputBuffer
	push bc
	call bos.gui_InputNoClear
	pop hl,bc
	or a,a
	jq z,cmd_exit_retzero
	cp a,12
	jq z,recall_last
	cp a,10
	jq z,enter_input
	ld a,(hl)
	or a,a
	jq z,enter_input ;don't execute if the input is null
	ld bc,256
	push hl,bc
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	push de,de
	ldir
	pop hl
	call execute_program_string
	call bos.sys_Free
	pop bc
	jq enter_input_clear

execute_program_string:
	push hl
	call cmd_get_arguments
	push hl
	call cmd_terminate_arguments ;check arguments string for eol characters so we can process multi-line commands
	pop hl
.noargs:
	ex (sp),hl ;store args, restore path
	push hl ;push path
	call bos.sys_ExecuteFile
	ld (bos.LastCommandResult),hl
	ld a,e
	ld (bos.LastCommandResult+3),a
	ld hl,(bos.ExecutingFileFd) ;check if the currently executing file descriptor is -1
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.file_not_found ;if the executing file descriptor is -1, the file could not be located
	pop bc,bc
	ld a,(ix-26)
	ld hl,(ix-29)
	or a,a
	jq nz,execute_program_string ;continue executing if an eol character was found before the null terminator
.at_eol:
	ld hl,(ix-6)
	push hl
	call bos.sys_Free
	pop bc
	or a,a
	sbc hl,hl
	ld (ix-6),hl
	xor a,a
	ld (bos.curcol),a
	ld a,(bos.return_code_flags)
	bit bos.bSilentReturn,a
	ret nz ;don't print anything if program returned silently
	bit bos.bReturnNotError,a
	jq nz,.program_returned_number
	ld hl,(bos.LastCommandResult)
	ld a,(bos.LastCommandResult+2)
	or a,h
	or a,l
	ret z ;don't print anything if program returned 0
	ld a,(ix-10)
	or a,a
	ret nz ;don't print anything if we're ignoring exit codes
	call bos.gfx_BlitBuffer
	ld a,(bos.return_code_flags)
	bit bos.bReturnHex,a
	jq nz,.program_returned_hex
	ld hl,str_ProgramFailedWithCode
	call bos.gui_PrintString
.program_returned_number:
	bit bos.bReturnHex,a
	jq nz,.program_returned_hex
	ld hl,(bos.LastCommandResult)
	call bos.gui_PrintInt
.newline_and_return:
	call bos.gui_NewLine
	jp bos.gfx_BlitBuffer
.program_returned_hex:
	ld hl,bos.LastCommandResult
	ld de,bos.gfx_string_temp
	bit bos.bReturnLong,a
	jq nz,.program_returned_long
	call osrt.int_to_hexstr
	jq .print_string_temp
.program_returned_long:
	call osrt.long_to_hexstr
.print_string_temp:
	xor a,a
	ld (de),a
	ld hl,bos.gfx_string_temp
	call bos.gui_PrintLine
	jp bos.gfx_BlitBuffer
.file_not_found:
	pop bc,bc
	ld a,(ix-10)
	cp a,'i'
	ret z ;return if ignoring errors
;if we got here then we failed to locate the executable
	ld (ix-9),hl
	ld hl,str_CouldNotLocateExecutable
	jp bos.gui_Print
cmd_exit_retneg1:
	scf
	sbc hl,hl
	jr cmd_exit
cmd_exit_retneg2:
	ld hl,-2
	db $01
cmd_exit_retzero:
	or a,a
	sbc hl,hl
cmd_exit:
	; push af,hl
	; ld hl,(ix-3)
	; push hl
	; call bos.sys_Free
	; pop bc
	; pop hl,af
	ld sp,ix
	pop ix
	ret

cmd_terminate_arguments:
	xor a,a
	ld (ix-26),a
	ld c,a
.loop:
	ld a,(hl)
	or a,a
	ret z
	cp a,':'
	jq z,.eol
	cp a,$A
	jq z,.eol
	inc hl
	cp a,$5C ;backslash
	jq nz,.loop
	inc hl
	jq .loop
.eol:
	ld (ix-26),a
	ld (hl),c
	inc hl
	ld (ix-29),hl
	ret

cmd_get_arguments.inc_twice:
	inc hl
cmd_get_arguments.loop:
	inc hl
cmd_get_arguments:
	ld a,(hl)
	or a,a
	ret z
	cp a,':'
	ret z
	cp a,$A
	ret z
	cp a,$5C ;backslash
	jq z,.inc_twice
	cp a,' '
	jq nz,.loop
	ld (hl),0
	inc hl
	ret

cmd_help_info:
	db " cmd -h",$A,$9,"show this info",$A
	db " cmd commands",$A,$9,"run command(s) but exit if one returns an error",$A
	db " cmd -a commands",$A,$9,"run all commands(s) regardless of error codes",$A
	db " cmd -i commands",$A,$9,"run commands(s), ignoring all errors",$A
	db " cmd -x file",$A,$9,"run a command file",$A,0

str_system_path:
	db "/bin/"
.len:=$-.
str_ProgramFailedWithCode:
	db "Error Code ",0
str_CouldNotLocateExecutable:
	db $9,"Could not locate executable",$A,0
