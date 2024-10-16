
	jq cmd_exe_main
	db "FEX",0
cmd_exe_main:
	ld hl,-29
	call ti._frameset
	call cmd_exe_init
	ld hl,(ix+6) ; argc
	ld bc,(ix+9) ; argv
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,cmd_no_cmd_args ; don't join argv if there's no arguments
	add hl,bc
	scf
	sbc hl,bc
	jq z,cmd_no_cmd_args ; don't join argv if there's only one argument
	inc hl
	push bc,hl
	call bos.sys_JoinArgv
	pop bc
	ld (ti.curPC),hl
	ld (ti.begPC),hl
	ex (sp),hl
	call ti._strlen
	ld (ix-19),hl
	add hl,bc
	or a,a
	sbc hl,bc
	pop bc
	add hl,bc
	ld (ti.endPC),hl
	jq z,cmd_no_cmd_args
	ld a,(bc)
	or a,a
	jq z,cmd_no_cmd_args

	cp a,'-'
	jq nz,cmd_execute_next_line ;if first argument isn't a flag
	inc bc
	ld a,(bc)
	inc bc
	inc bc
	ld (ti.curPC),bc
	ld (ti.begPC),bc
	cp a,'h'
	jq z,cmd_print_help_info
	cp a,'x'
	jq nz,.not_exec_file
	push bc
	call bos.fs_GetFilePtr
	jq c,cmd_exit_retneg1
	ld (ti.curPC),hl
	ld (ti.begPC),hl
	ld (ix-19),bc
	add hl,bc
	ld (ti.endPC),hl
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

cmd_exe_init:
	; ld hl,str_CmdConfigFile
	; push hl
	; call bos.fs_GetFilePtr
	; pop de
	; ld de,cmd_config_data_struct
	; push de,hl,bc
	; syscall _loadConfigData
	; pop bc,bc,bc
	xor a,a
	sbc hl,hl
	ld (ix-10),a
	ld (ix-6),hl
	ld (ix-9),hl
	ld (ix-16),hl
	ret

cmd_execute_next_line:
	call bos.sys_ExecContinue
	ld a,(bos.return_code_flags)
	bit bos.bReturnFromFullScreen,a
	call nz,cmd_redraw_console
	ld a,(ix-10)
	cp a,'i'
	jq nz,cmd_exit ; return the process exit code if not set to ignore
	sbc hl,hl
	jq cmd_exit

cmd_redraw_console:
	ld a,1
	call bos.gfx_SetDraw
	ld hl,bos.LCD_VRAM
	ld (ti.mpLcdUpbase),hl
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
	ret


cmd_no_cmd_args:
	; xor a,a
	; ld (bos.lcd_text_bg),a
	; ld (bos.lcd_text_bg2),a
	; dec a
	; ld (bos.lcd_text_fg),a
	; ld a,5
	; ld (bos.lcd_text_fg2),a
	; ld (bos.cursor_color),a
	xor a,a
	sbc hl,hl
	ld (ix-3),hl
	call cmd_redraw_console
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
	jr z,enter_input
	ld de,bos.InputBuffer
	ldir
enter_input_dec_currow:
	ld hl,ti.curRow
	dec (hl)
enter_input:
	; call bos.sys_WaitKeyUnpress
	ld bc,255
	push bc
	ld bc,bos.InputBuffer
	push bc
	call bos.gui_InputNoClear
	pop hl,bc
	or a,a
	jq z,cmd_exit_retzero
	cp a,12
	jr z,recall_last
	cp a,9
	jr z,enter_input_dec_currow
	ld a,(hl)
	or a,a
	jr z,enter_input ; don't execute if the input is null
	push hl
	ld hl,(ix-3)
	push hl
	call bos.sys_Free ; free the old malloc'd saved command if it exists
	pop hl
	call bos.sys_MallocDupStr ; malloc a new saved command using the contents of the input buffer
	ld (ix-3),hl
	call bos.sys_Exec
	pop bc
	; print the return code here
	call cmd_print_return_value
	call enter_input_clear
	jr enter_input

cmd_print_return_value:
	ld hl,(bos.ExecutingFileFd)
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.file_did_not_run
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	jr nz,.file_actually_ran
	ld hl,str_CouldNotLocatePath
	call bos.gui_PrintLine
.file_did_not_run:
	ld hl,str_CouldNotLocateExecutable
	jp bos.gui_PrintLine
.file_actually_ran:
	ld a,(bos.return_code_flags)
	bit bos.bSilentReturn,a
	ret nz
	bit bos.bReturnNotError,a
	jr nz,.print_number_result
.non_zero_is_error:
	ld hl,(LastCommandResult)
	ld a,(LastCommandResult+3)
	add hl,bc
	or a,a
	jr nz,.print_error_code
	sbc hl,bc
	ret z
.print_error_code:
	ld hl,str_ProgramFailedWithCode
	call bos.gui_Print
.print_number_result:
	ld hl,(LastCommandResult)
	ld a,(LastCommandResult+3)
.print_number_auhl:
	ld e,a
.print_number_euhl:
	push de,hl
	ld hl,bos.gfx_string_temp
	push hl
	ld a,(bos.return_code_flags)
	bit bos.bReturnHex,a
	jr nz,._print_hex
	bit bos.bReturnLong,a
	jr nz,._print_long
	call osrt.int_to_str
	jr ._done_printing
._print_long:
	call nc,osrt.long_to_str
	jr ._done_printing
._print_hex:
	bit bos.bReturnLong,a
	jr nz,._print_long_hex
	call osrt.int_to_hexstr
	jr ._done_printing
._print_long_hex:
	call osrt.long_to_hexstr
._done_printing:
	pop bc,bc,bc
	jp bos.gui_PrintLine


cmd_exit_retneg1:
	scf
	sbc hl,hl
	; jr cmd_exit
; cmd_exit_retneg2:
	; ld hl,-2
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

; cmd_config_data_struct:
	; db "BTBG", 0
	; dl bos.lcd_text_bg
	; db "BTFG", 0
	; dl bos.lcd_text_fg
	; db "BTFG2", 0
	; dl bos.lcd_text_fg2
	; db "BBGC", 0
	; dl bos.lcd_bg_color
	; db 0

cmd_help_info:
	db " cmd cmds",$A,$9,"run command(s) but exit if one returns an error",$A
	db " cmd -a cmds",$A,$9,"run all commands(s) regardless of error codes",$A
	db " cmd -i cmds",$A,$9,"run commands(s), ignoring all errors",$A
	db " cmd -x file",$A,$9,"run a command file",$A,0

; str_system_path:
	; db "/bin/"
; .len:=$-.
str_ProgramFailedWithCode:
	db "Error Code ",0
str_CouldNotLocateExecutable:
	db $9,"Could not locate executable",0
str_CouldNotLocatePath:
	db $9,"Missing /var/PATH",0
; str_CmdConfigFile:
	; db "/etc/config/cmd/cmd.cfg",0

; _loadConfigData:
	; db "cfg/loadConfigData",0
