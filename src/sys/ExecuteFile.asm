
;@DOES Execute a file.
;@INPUT int sys_ExecuteFile(const char *path, char *args);
;@OUTPUT -1 and Cf set if file does not exist or is not a valid executable format, or if malloc failed somewhere.
;@OUTPUT ExecutingFileFd set to point to file descriptor. -1 if file not found, -2 if /var/PATH not found.
;@DESTROYS All, OP5, OP6.
sys_ExecuteFile:
	xor a,a
	ld (fsOP5+10),a
	ld (fsOP6+10),a
.__entry:
	scf
	sbc hl,hl
	ld (ExecutingFileFd),hl
	ld (return_code_flags),a
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
	ld (fsOP6),de
	push hl
	call fs_OpenFile ; look for the file directly
	call c,sys_OpenFileInPath ;look for the file within dirs listed in $PATH
	pop bc
	jr nc,.entryfd
;fail if both fs_OpenFile and sys_OpenFileInPath failed to locate the file
	push de ; sys_OpenFileInPath returns pointer to "/var/PATH" in de
	call fs_OpenFile ; check for /var/PATH
	pop bc
	ccf
	sbc hl,hl
	ret c ; return -1 and ExecutingFileFD = -1 if file not found but /var/PATH was found
	ld a,$FE
	ld (ExecutingFileFd),a ; return -1 and ExecutingFileFD = -2 if /var/PATH not found
	dec hl
	scf
	ret
; .entry_ptr_hlbc:
	; call sys_GetExecType.entryhlbc
.entryfd:
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
; if it's neither a Flash Executable nor a Ram Executable, return -1
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
	ld a,(fsOP6+10)
	or a,a
	ret nz ; return if only set to load the program

	call sys_NextProcessId
	call sys_FreeRunningProcessId ;free memory allocated by the new process ID if there is any

	ld a,(fsOP5+10)
	or a,a
	ld de,(fsOP6) ;arguments string
	call z,.load_argc_argv_loop
	; call .normalize_lcd

	ld a,(threading_enabled)
	cp a,threadPrograms
	jr z,.run_threading
	cp a,threadAlways
	jr nz,.runnothreading

.run_threading:
	ld hl,threadMallocStackSize
	call sys_Malloc.entryhl
	jr nc,.run_thread_with_stack
	sbc hl,hl
	ret

.run_thread_with_stack:
	ld de,(fsOP6) ; argv
	ld bc,(fsOP5) ; argc
	push de,bc
	ld bc,(running_program_ptr)
	push hl,bc
	call th_CreateThread
	pop bc,bc,bc,bc
	or a,a
	ret nz
	scf
	sbc hl,hl
	ret
	
	; jq th_HandleNextThread.nosave
	; HandleNextThread ;handle the thread we just spawned
	; jr .ranthread
	; call .normalize_lcd
.runnothreading:
	ld de,(fsOP6) ; argv
	ld bc,(fsOP5) ; argc
	push de,bc
	call .jptoprogram
	ld (LastCommandResult),hl
	ld a,e
	ld (LastCommandResult+3),a
.ranthread:
	pop bc,bc
	push de,hl
	call .normalize_lcd_8bpp
	xor a,a
	sbc hl,hl
	ld (asm_prgm_size),hl
	ld hl,bos_UserMem
	ld (top_of_UserMem),hl
	call sys_FreeRunningProcessId ;free memory allocated by the program
	call sys_PrevProcessId
	pop hl,de
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
	ret z ; dont reinit the display if we're already in the correct lcd mode
	ld hl,ti.vRam
	ld l,a
	push hl
	call ti.boot.ClearVRAM
	pop hl
	ld a,l
	ld l,h
	ld (ti.mpLcdUpbase),hl
	ld (ti.mpLcdCtrl),a
	xor a,a
	ld (curcol),a
	ret

; .exec_threaded_rex:
	; ld hl,(running_program_ptr)
	; ld a,(hl)
	; cp a,$18
	; jq z,.threaded_rex_skipjr
	; inc hl
	; inc hl
; .threaded_rex_skipjr:
	; ld de,7 ; length of short jump + length of magic number + length of stack frame chunks indicator
	; add hl,de
	; ld e,(hl) ; get size of space needed for program
	; inc hl
	; ld d,(hl)
	; inc hl
	; push hl,de
	; ld a,(running_process_id)
	; ld (fsOP5+9),a
	; call sys_NextProcessId
	; call sys_Malloc
	; pop bc
	; ex (sp),hl
	; push bc
	; ld c,(hl) ; get number of entries in relocations table
	; inc hl
	; ld b,(hl)
	; inc hl
	; ld (fsOP6+3),hl
	; ld (fsOP6+6),bc
	; add hl,bc
	; add hl,bc ;each entry is 2 bytes. hl should now point to code needing relocation
	; pop bc,de
	; ld (fsOP5+6),de
	; ldir
	; ld bc,(fsOP6+6)
	; ld a,b
	; or a,c
	; jq z,.no_relocations
	; push iy
	; ld iy,(fsOP6+3)
; .relocations_loop:
	; push bc
	; ld c,(iy)
	; ld b,(iy+1)
	; lea iy,iy+2
	; ld hl,(fsOP5+6)
	; add hl,bc
	; ld bc,(hl)
	; ex hl,de
	; ld hl,(fsOP5+6)
	; add hl,bc
	; ex hl,de
	; ld (hl),de
	; pop bc
	; dec bc
	; ld a,c
	; or a,b
	; jq nz,.relocations_loop
	; pop iy
; .no_relocations:
	; ld hl,(running_program_ptr)
	; ld de,(fsOP5+6)
	; ld (running_program_ptr),de
	; jq .exec_threaded_hl
; .exec_threaded_fex:
	; ld a,(running_process_id)
	; ld (fsOP5+9),a
	; ld a,1
	; ld (running_process_id),a
	; ld hl,(running_program_ptr)
; .exec_threaded_hl:
	; ld a,(hl)
	; cp a,$18 ;jr
	; jq z,.threaded_skipjr
	; inc hl
	; inc hl
; .threaded_skipjr:
	; ld de,6 ;length of short jump + length of magic number
	; add hl,de
	; ld l,(hl) ;the byte following the magic number should indicate how many 32-byte chunks of stack frame the program requires, minus 1.
	; ld h,32
	; ld e,h
	; mlt hl
	; add hl,de ;chunks * 32 + 32
	; push hl
	; call sys_Malloc
	; pop bc
	; ret c ;return if failed to malloc

	; add hl,bc ;malloc'd pointer for the stack + length because it grows downwards
	; ld de,(running_program_ptr)
	; push hl,de
	; call th_CreateThread ; queue the thread to be run on the next thread switch
	; ld a,(fsOP5+9)
	; ld (running_process_id),a
	; ld hl,return_code_flags
	; set bSilentReturn,(hl) ;return to caller silently
	; pop hl,de
	; ret

; input de = string
.load_argc_argv_loop:
	ld	bc,1
	ld	a,(de)
	or	a,a
	jr	z,.doneargv
	jr	.argvappend
.argvloop:	; loop over argument string
	inc de
	ld	a,(de)
	or	a,a
	jr	z,.doneargv
	cp	a,' '
	jr	nz,.argvloop
	xor	a,a
	ld	(de),a
.argvspacesloop:
	inc	de
	ld	a,(de)
	cp	a,' '
	jr	z,.argvspacesloop
	or	a,a
	jr	z,.doneargv
.argvappend:
	inc	bc
	push	de
	jr	.argvloop
.doneargv:
	sbc hl,hl
	add hl,bc
	add hl,bc
	add hl,bc
	push bc,hl
	call sys_Malloc
	push hl
	ld	hl,(ExecutingFileFd)
	push	hl
	call	fs_CopyFileName	; get file name from running file descriptor
	ex hl,de
	pop	bc
	pop hl ; char *argv[]
	ld (fsOP6),hl
	pop bc ; argc*3
	add hl,bc
	pop bc	; int argc
	ld (fsOP5),bc
	ld (fsOP5+3),de
	dec bc
	ld a,c
	or a,b
	jr z,.argv_no_args
.argv_copy_loop:
	pop de
	dec hl
	dec hl
	dec hl
	ld (hl),de
	dec bc
	ld a,c
	or a,b
	jq nz,.argv_copy_loop
.argv_no_args:
	ld de,(fsOP5+3)
	dec hl
	dec hl
	dec hl
	ld (hl),de
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


