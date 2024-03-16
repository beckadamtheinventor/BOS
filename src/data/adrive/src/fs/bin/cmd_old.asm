
	jq cmd_exe_main
	db "FEX",0
cmd_exe_main:
	ld hl,-29
	call ti._frameset
	call cmd_exe_init
	ld hl,(ix+6)
	ld bc,(ix+9)
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

;execute argument as if from command line if argument passed
cmd_execute_next_line.entry:
	ld hl,-29
	call ti._frameset
	call cmd_exe_init
cmd_execute_next_line:
.loop:
	ld hl,(ti.endPC)
	ld bc,(ti.curPC)
	or a,a
	sbc hl,bc
	jq c,cmd_exit_retzero
	ld de,(ix-16)
	push de
	call bos.sys_Free
	pop bc
	ld hl,(ti.endPC)
	ld de,(ti.curPC)
	or a,a
	sbc hl,de
	ld b,h
	ld c,l
	ex hl,de
; bc = endpc-curpc, hl = curpc
	ld (ix-25),hl
	ld a,(hl)
	push af
	inc bc
	call .linelen
	pop af
	ld (ix-13),de ; length of line
	ld (ti.curPC),hl ; pointer to next line
	cp a,'#'
	jr z,.nextline ;only copy line and execute if line not commented
	ld a,e
	or a,d
	jr z,.nextline
	push de
	call bos.sys_Malloc
	pop bc
	jq c,cmd_exit_retneg2 ;return if failed to malloc
	ld (ix-16),hl
	ex hl,de
	ld hl,(ix-25)
	; ld bc,(ix-13)
	push de
	ldir ;copy the line from the file into a null-terminated buffer
	xor a,a
	ld (de),a
	pop hl
	call execute_program_string
	ld a,(ix-10)
	or a,a
	jr nz,.nextline
	ld hl,(ix-9)
	add hl,bc
	or a,a
	sbc hl,bc
	jq nz,cmd_exit
.nextline:
	ld hl,(ti.endPC)
	ld bc,(ti.curPC)
	or a,a
	sbc hl,bc
	jq nc,.loop ;execute next line if there are more characters in the file to be read
	ld a,(ix-10)
	cp a,'i'
	jq nz,.returnerrorcode
	sbc hl,hl
	jq cmd_exit

.linelen:
	ld de,0
.linelenloop:
	ld a,c
	or a,b
	ret z
	ld a,(hl)
	inc hl
	cp a,$A
	ret z
	or a,a
	ret z
	inc de
	dec bc
	jr .linelenloop

;exit returning last executable's error code
.returnerrorcode:
	ld hl,(ix-9)
	jq cmd_exit

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
	call bos.sys_WaitKeyUnpress
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
	pop hl
	call execute_program_string
	jq enter_input_clear

execute_program_string:
	push ix,hl
	push hl
	call cmd_terminate_line ;check arguments string for eol characters so we can process multi-line commands
	pop hl
	call cmd_get_arguments
	ex (sp),hl ;store args, restore path
	push hl ;push path
	ld a,(hl)
	cp a,'A' ; Check if path is uppercase alpha. If it is, check the VAT for the file first.
	jr c,.execute_file
	cp a,'Z'+1
	jr nc,.execute_file
	dec hl
	call ti.Mov9ToOP1
	ld a,$FF
	ld (ti.OP1),a ; set the type byte as a wildcard
	call bos._SearchSymTable ; just search the symbol table
	jr c,.execute_file ; if the file wasn't found in the VAT, attempt to run it normally.
	cp a,ti.ProgObj
	jr z,.execute_file
	cp a,ti.ProtProgObj
	jr z,.execute_file
	cp a,ti.AppVarObj
	jr z,.parse_string
	cp a,ti.StrngObj
	jr z,.parse_string
	cp a,ti.EquObj
	jr z,.parse_string
	cp a,ti.RealObj
	jr nz,.unimplemented_error
	ex hl,de
	ld a,(hl)
	inc hl
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld c,(hl)
	ex hl,de
	or a,a
	jr nz,.unimplemented_error
	ld de,11
	push bc,hl,de
	call bos.sys_Malloc
	ex (sp),hl
	call osrt.long_to_str
	pop bc,bc,bc
	; jr .parse_string_hl
; .parse_float:
	; call ti.ftoa
	call .print_string_hl
	db $3E
.parse_string:
	ex hl,de
.parse_string_hl:
	ld a,1 shl bos.bReturnData or 1 shl bos.bReturnNotError
.return_value:
	ld (bos.return_code_flags),a
	ld (bos.LastCommandResult),hl
.return_value_return:
	pop bc,bc,ix
	ret
.unimplemented_error:
	call ti.ErrDataType
	jr .return_value_return
.execute_file:
	ld iy,ti.OP3
	ld bc,(ti.begPC)
	ld (iy),bc
	ld bc,(ti.curPC)
	ld (iy+3),bc
	ld bc,(ti.endPC)
	ld (iy+6),bc
	call ti.PushOP3
	ld bc,(bos.color_primary)
	ld (iy),bc
	ld bc,(bos.lcd_text_fg)
	ld (iy+2),bc
	ld bc,(bos.lcd_text_fg2)
	ld (iy+4),bc
	ld a,(bos.cursor_color)
	ld (iy+6),a
	call ti.PushOP3
	call bos.sys_ExecuteFile
	call ti.PopOP3
	ld iy,ti.OP3
	ld a,(iy)
	ld (bos.color_primary),a
	ld a,(iy+1)
	ld (bos.color_primary+1),a
	ld a,(iy+2)
	ld (bos.lcd_text_fg),a
	ld a,(iy+3)
	ld (bos.lcd_text_fg+1),a
	ld a,(iy+4)
	ld (bos.lcd_text_fg2),a
	ld a,(iy+5)
	ld (bos.lcd_text_fg2+1),a
	ld a,(iy+6)
	ld (bos.cursor_color),a
	call ti.PopOP3
	ld bc,(iy)
	ld (ti.begPC),bc
	ld bc,(iy+3)
	ld (ti.curPC),bc
	ld bc,(iy+6)
	ld (ti.endPC),bc
	ld hl,(bos.ExecutingFileFd) ;check if the executed file descriptor is -1
	inc hl
	add hl,bc
	or a,a
	sbc hl,bc
	pop bc,bc,ix
	jr nz,.check_if_at_eol
;if the executing file descriptor is -1, the file could not be located
	ld a,(ix-10)
	cp a,'i'
	jq nz,.file_not_found_no_recheck ; only error if not ignoring errors
.check_if_at_eol:
	ld a,(ix-20)
	ld hl,(ix-19)
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
.print_string_hl:
	call bos.gui_PrintLine
	jp bos.gfx_BlitBuffer
; .file_not_found:
	; ld a,(ix-10)
	; cp a,'i'
	; ret z ;return if ignoring errors
;if we got here then we failed to locate the executable
.file_not_found_no_recheck:
	ld (ix-9),hl
	ld hl,str_CouldNotLocateExecutable
	jp bos.gui_PrintLine
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

; input hl pointer to line
; output hl pointer to character following EOL, replacing the EOL with NULL
cmd_terminate_line:
	xor a,a
	ld (ix-20),a
	ld c,a
.loop:
	ld a,(hl)
	or a,a
	ret z
	cp a,':'
	jr z,.eol
	cp a,$A
	jr z,.eol
	; cp a,'>'
	; jr z,.eol
	inc hl
	cp a,$5C ;backslash
	jr nz,.loop
	inc hl
	jr .loop
.eol:
	ld (ix-20),a
	ld (hl),c
	inc hl
	ld (ix-19),hl ; save eol ptr
	ret

cmd_get_arguments.inc_twice:
	inc hl
cmd_get_arguments.loop:
	inc hl
; input hl pointer to first char of argument string
; output hl pointer to character following EOL, replacing spaces (outside of quotes) with NULL
cmd_get_arguments:
	ld a,(hl)
	or a,a
	ret z
	cp a,':'
	ret z
	cp a,$A
	ret z
	cp a,'"'
	jr z,.process_quotes
	cp a,$27 ; single quote
	jr z,.process_quotes
	cp a,$5C ; backslash
	jr z,.inc_twice
	cp a,' '
	jr nz,.loop
	ld (hl),0
.done:
	inc hl
	ret

.process_quotes:
	ld c,a
	dec hl
.process_quotes_loop:
	inc hl
	ld a,(hl)
	or a,a
	jr z,.done
	cp a,$5C ; backslash
	jr z,.process_quotes_loop ; handle escaped characters
	cp a,c
	jr nz,.process_quotes_loop
	jr .loop

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
; str_CmdConfigFile:
	; db "/etc/config/cmd/cmd.cfg",0

; _loadConfigData:
	; db "cfg/loadConfigData",0
