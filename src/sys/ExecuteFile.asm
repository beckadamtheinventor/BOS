
;@DOES Execute a file.
;@INPUT int32_t sys_ExecuteFile(const char *path, char *args);
;@OUTPUT -1 and Cf set if file does not exist or is not a valid executable format, or if malloc failed somewhere.
;@OUTPUT ExecutingFileFd set to point to file descriptor. -1 if file not found, -2 if /var/PATH not found.
;@DESTROYS All, OP5, OP6.
sys_ExecuteFile:
	xor a,a
	ld (fsOP5+10),a
.__entry:
	scf
	sbc hl,hl
	ld (ExecutingFileFd),hl
	pop bc
	pop hl
	pop de
	push de
	push hl
	push bc
.entryhlde:
	ld a,(hl)
	or a,a
	jq z,.fail
	ld (fsOP6+3),hl
	push de,hl
	call fs_OpenFile ; look for the file directly
	call c,sys_OpenFileInPath ;look for the file within dirs listed in $PATH
	pop bc,bc
	ld (fsOP6),bc ; pop then store argument string
	jr nc,.entryfd
.fail_file_not_found:
;fail if both fs_OpenFile and sys_OpenFileInPath failed to locate the file
	ld hl,string_path_variable
	push hl
	call fs_OpenFile ; check for /var/PATH
	pop bc
	ccf
	sbc hl,hl
	ld (LastExitCode),hl
	ld (ExecutingFileFd),hl
	ret c ; return -1 and ExecutingFileFD = -1 if file not found but /var/PATH was found
	ld a,$FE
	ld (ExecutingFileFd),a ; return -1 and ExecutingFileFD = -2 if /var/PATH not found
	dec hl
	scf
	ret
; .entry_ptr_hlbc:
	; call sys_GetExecType.entryhlbc
.entryfd:
	push hl
	ld de,(fsOP6) ;arguments string
	call .load_argc_argv_loop
	ld de,(fsOP6+3) ; const char *path
	ld (hl),de ; argv[0]
	ex hl,de
	pop hl
	jr c,.fail
.entryfd_argcargv:
	ld (fsOP6+3),de
	ld (fsOP6+9),bc
	ld (ExecutingFileFd),hl
	call fs_GetFilePtr.entryfd
	bit fd_subdir,a
	jq nz,.fail ;can't execute a directory
.exec_check_loop:
	call sys_GetExecType.entryhlbc
	jq c,.fail ; fail if unrecognized executable type
	ld (running_program_ptr),de
	ld a,(hl)
	cp a,$EF
	jr nz,.not_ef7b
	inc hl
	ld a,(hl)
	dec hl
	cp a,$7B
	jr nz,.not_ef7b
.normalize_16_bpp_and_execute:
	push bc,de
	call .normalize_lcd_16bpp
	pop hl,bc
	jq .exec_copy_to_usermem ; execute if valid header and there is program data to copy
.not_ef7b:
	ld a,(hl)
	cp a,'#'
	jr nz,.not_executable_text
	inc hl
	ld a,(hl)
	cp a,'!'
	jq z,.executable_text
	dec hl
.not_executable_text:
	ld de,(hl)
	push hl
	db $21, 'CRX' ;ld hl, 'CRX' ;Compressed Ram eXecutable
	or a,a
	sbc hl,de
	jr z,.exec_compressed_rex
	pop hl
	db $21, 'FEX' ;ld hl, 'FEX' ;Flash EXecutable
	or a,a
	sbc hl,de
	jq z,.exec_fex
	db $21, 'REX' ;ld hl, 'REX' ;Ram EXecutable
	or a,a
	sbc hl,de
	jr z,.exec_rex
	db $21, 'TFX' ;ld hl, 'TFX' ;Threadable Flash eXecutable
	or a,a
	sbc hl,de
	jq z,.exec_fex
	db $21, 'TRX' ;ld hl, 'TRX' ;Threadable Ram eXecutable
	or a,a
	sbc hl,de
	jr z,.exec_rex
; if it's not a recognized executable, return -1
.fail:
	scf
	sbc hl,hl
	ret
.exec_compressed_rex:
	pop hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	push hl,bc
	ld de,(asm_prgm_size)
	ld a,(asm_prgm_size+2)
	or a,d
	or a,e
	ld hl,ti.userMem
	call nz,_DelMem
	pop hl
	ld (asm_prgm_size),hl
	add hl,bc
	or a,a
	sbc hl,bc
	ld de,ti.userMem
	call nz,_InsertMem
	ld de,ti.userMem
	ld (running_program_ptr),de
	push de
	call util_Zx7Decompress
	pop hl,de
	jr .exec_fex_entry_hl
.exec_rex:
	ld hl,(running_program_ptr)
; no need to reload BC with the program executable length
	; push hl
	; ld iy,(ExecutingFileFd)
	; ld hl,(iy+fsentry_filelen)
	; ex.s hl,de
	; push de
	; pop bc
	; pop hl
.exec_copy_to_usermem:
	push hl,bc
	ld de,(asm_prgm_size)
	ld a,(asm_prgm_size+2)
	or a,d
	or a,e
	ld hl,ti.userMem
	call nz,_DelMem
	pop hl
	push hl
	add hl,bc
	or a,a
	sbc hl,bc
	ld de,ti.userMem
	call nz,_InsertMem
	pop bc,hl
	ld de,ti.userMem ; where to copy the executable
	push de ;save jump address
	push bc
	ldir
	pop bc
.exec_setup_usermem_bc:
	ld (asm_prgm_size),bc
	pop hl  ;usermem
	ld (running_program_ptr),hl
.exec_fex:
	ld hl,(running_program_ptr)
.exec_fex_entry_hl:
	ld a,(fsOP5+10)
	or a,a
	ret nz ; return if only loading the program

	; xor a,a
	ld (return_code_flags),a

	call sys_NextProcessId
	; call sys_FreeRunningProcessId
	; call .normalize_lcd

	ld a,(threading_enabled)
	cp a,threadPrograms
	jr z,.run_thread_with_stack
	cp a,threadAlways
	jr nz,.runnothreading

.fail_running_thread:
	scf
	sbc hl,hl
	ret

.run_thread_with_stack:
	call .init_thread_with_stack
	ret c
	HandleNextThread
	ret

.init_thread_with_stack:
	ld hl,threadMallocStackSize
	push hl
	call sys_Malloc
	pop bc
	jr c,.fail_running_thread
	add hl,bc
.init_thread_stack_hl:
	ld bc,(fsOP6+3) ; argv
	push bc
	ld bc,(fsOP6+9) ; argc
	push bc
	ld bc,(running_program_ptr)
	push hl,bc
	xor a,a
	ld (return_code_flags),a
	call th_CreateThread
	pop bc,bc
	pop bc,bc
	or a,a
	jr z,.fail_running_thread
	ret

.runnothreading:
	; ld de,(fsOP6+3) ; argv
	; ld bc,(fsOP6+9) ; argc
	; push de,bc
	ld iy,ti.OP3
	ld bc,(color_primary)
	ld (iy),bc
	ld bc,(lcd_text_fg)
	ld (iy+2),bc
	ld bc,(lcd_text_fg2)
	ld (iy+4),bc
	ld a,(cursor_color)
	ld (iy+6),a
	call ti.PushOP3
	ld a,(threading_enabled)
	or a,a
	jr z,.runnothreading_actually
	call .actuallyrunprogram_thread
	; save exit code handled in th_CreateThread thread return handler when running as thread
	jr .restore_colors
.runnothreading_actually:
	call .actuallyrunprogram_nothread
.restore_colors:
	call ti.PopOP3
	ld iy,ti.OP3
	ld a,(iy)
	ld (color_primary),a
	ld a,(iy+1)
	ld (color_primary+1),a
	ld a,(iy+2)
	ld (lcd_text_fg),a
	ld a,(iy+3)
	ld (lcd_text_fg+1),a
	ld a,(iy+4)
	ld (lcd_text_fg2),a
	ld a,(iy+5)
	ld (lcd_text_fg2+1),a
	ld a,(iy+6)
	ld (cursor_color),a
.done_running_program:
	; call .deinit
	; pop hl,de
	; ret

.deinit:
	call .normalize_lcd_8bpp
	call sys_FreeRunningProcessId ; free memory allocated by the program
	call sys_PrevProcessId
	ld de,(asm_prgm_size)
	ld a,(asm_prgm_size+2)
	or a,d
	or a,e
	ld hl,ti.userMem
	call nz,_DelMem ; free usermem allocated by the program
	xor a,a
	sbc hl,hl
	ld (asm_prgm_size),hl
	ld hl,bos_UserMem
	ld (top_of_UserMem),hl
	ret

.actuallyrunprogram_nothread:
	ld hl,(fsOP6+3) ; argv
	push hl
	ld hl,(fsOP6+9) ; argc
	push hl
	call .jptoprogram
	ld (LastExitCode),hl ; save exit code
	ld a,e
	ld (LastExitCode+3),a
	pop bc,hl ; argc, argv
	ret
	; jp sys_Free.entryhl ; free argv


.actuallyrunprogram_thread:
	or a,a
	sbc hl,hl
	call .init_thread_stack_hl
	ret c
	ld iyl,a
.trap: ; trap this thread here until the thread we spawned exits
	HandleNextThread ; handle the thread we just spawned
	ld a,iyl ; handling next thread preserves ix, iy, pc, sp
	call th_GetThreadStatus.entrya
	bit bThreadAlive,a
	jr nz,.trap
	ret

.jptoprogram:
	ld hl,(running_program_ptr)
sys_jphl := $
	jp (hl)

.normalize_lcd_16bpp:
	ld a,ti.lcdBpp16
	jr .setlcdmode

.normalize_lcd_8bpp:
	ld a,ti.lcdBpp8
.setlcdmode:
	ld hl,ti.mpLcdCtrl
	cp a,(hl)
	jr nz,.reinit_display
; dont reinit the display if we're already in the correct lcd mode
; unless we're returning from a fullscreen program (turns on when gfx_Begin is called, unless the program says otherwise)
	ld hl,return_code_flags
	bit bReturnFromFullScreen, (hl)
	ret z
.reinit_display:
	ld hl,ti.vRam
	push af,hl
	call gfx_ZeroVRAM
	pop hl,af
	ld (ti.mpLcdUpbase),hl
	ld (ti.mpLcdCtrl),a
	ret

.copy_to_op1:
	ld de,fsOP1
	ld a,ti.ProtProgObj
	ld (de),a
	inc de
	ld b,8
.copy_to_op1_loop:
	ld a,(hl)
	cp a,'.'
	jr z,.copy_to_op1_eos
	ld (de),a
	or a,a
	ret z
	inc hl
	inc de
	djnz .copy_to_op1_loop
.copy_to_op1_eos:
	xor a,a
	ld (de),a
	ret

; input de = string
; output hl -> argv
; output bc -> argc
.load_argc_argv_loop:
	ld bc,(running_process_id)
	push bc
	; malloc as the next process ID so argc/argv get freed when it exits
	call sys_NextProcessId
	ld (running_process_id),a
	call .load_argc_argv_loop_entry
	ex (sp),hl
	ld a,l
	ld (running_process_id),a
	pop hl
	ret

.load_argc_argv_loop_entry:
	ex hl,de
	push hl
	inc sp
	pop af
	dec sp
	cp a,$D0
	call c,sys_MallocDupStr.entryhl ; malloc a duplicate of the string in RAM if the original is stored in flash
	ret c
	ex hl,de
.load_argc_argv:
	ld bc, 1
	push de
	dec de
.argc_argv_loop:
	inc de ; increment past null byte (only after the first iteration of the loop)
	ex hl,de ; de -> hl = current text pointer
	ld a,(hl)
	or a,a
	jr z,.doneargv
	call .terminate_argument
	inc bc ; increment argc
	push hl ; push processed argument
	; de contains new text pointer, loop if we aren't at the end of the arguments
	jr nc,.argc_argv_loop
.doneargv:
	or a,a
	sbc hl,hl
	add hl,bc
	add hl,bc
	add hl,bc
	push bc,hl
	call sys_Malloc
	pop de ; argc*3
	pop bc	; int argc
	ld (ti.scrapMem),bc ; save argc
	add hl,de
	; dec bc
	; ld a,c
	; or a,b
	; jr z,.argv_no_args
.argv_copy_loop:
	pop de ; pop previously processed argument off the stack
	dec hl
	dec hl
	dec hl
	ld (hl),de
	dec bc
	ld a,c
	or a,b
	jq nz,.argv_copy_loop
.argv_no_args:
	ld bc,(ti.scrapMem) ; restore argc
	ret

; input hl pointer to string
; output hl pointer to null-terminated argument
; output de pointer to argument's null terminator
; output Cf set if found final argument
.terminate_argument:
	push hl
	db $3E ; ld a,... dummify next instruction (1 byte)
.terminate_argument_loop:
	inc hl
	ld a,(hl)
	or a,a
	scf
	jr z,.terminate_argument_loop_done_no_terminate
    cp a,$A
    jr z,.terminate_argument_loop_done
	inc hl
	cp a,$5C ; backslash
	jr z,.terminate_argument_loop
	cp a,'"'
	jr nz,.terminate_argument_not_quote
	dec hl
	ld (hl),0
	inc hl
	pop af
	push hl
	inc hl
.terminate_argument_quote_loop:
	dec hl
.terminate_argument_quote_loop_no_dec:
	ld a,(hl)
	inc hl
	inc hl
	cp a,$5C ; backslash
	jr z,.terminate_argument_quote_loop_no_dec
	sub a,'"'
	jr nz,.terminate_argument_quote_loop
	dec hl
	or a,(hl) ; check byte following quote
	scf
	jr z,.terminate_argument_quote_loop_final
	xor a,a ; unset Zf and Cf
.terminate_argument_quote_loop_final:
	dec hl
	jr .terminate_argument_loop_done
.terminate_argument_not_quote:
	dec hl
	cp a,' '
	jr nz,.terminate_argument_loop
.terminate_argument_loop_done:
	ld (hl),0
.terminate_argument_loop_done_no_terminate:
	ex hl,de
	pop hl
	ret

.executable_text:
	ld a,c
	or a,b
	jr nz,.executable_text_has_contents
	sbc hl,hl
	ret

.executable_text_has_contents:
	ex hl,de
	call sys_PushExecutableText
	ld hl,str_CmdContinueExecutable
	ld de,$FF0000
	call .entryhlde
	jq sys_PopExecutableText


