;@DOES Continue Execution from curPC.
;@INPUT int32_t sys_ExecContinue(void);
;@OUTPUT process exit code.
;@OUTPUT exit code also stored in bos.LastCommandResult
sys_ExecContinue:
	ld hl,-23
	call ti._frameset
	ld (ix-6),iy
	ld (ix-10),0
	ld (ix-20),0
	call util_InitAllocSymList
	ld (ix-16),hl
.execute_program_string:
	ld hl,(ti.curPC)
	push hl
	call .advance_to_next_line
	pop hl
	jq z,.done
	ld a,(hl)
	cp a,'#'
	jr z,.execute_program_string ; don't execute comments
	push hl
	ld bc,(hl)
	ex hl,de
	db $21,"end" ; ld hl,"end"
	or a,a
	sbc hl,bc
	jr nz,.not_end
	inc de
	inc de
	inc de
	ld a,(hl)
	cp a,$A
	jr z,.is_end
	cp a,$9
	jr z,.is_end
	cp a,' '
.is_end:
	jq nz,.done ; branch will only be taken if A is ' ', '\x09', or '\x0A'
.not_end:
	ld hl,(ix-3)
	call sys_Malloc.entryhl
	ex hl,de
	pop hl
	jq c,.fail
	ld bc,(ix-3)
	push de
	ldir
	xor a,a
	ld (de),a
	pop de
; build argc/argv (string in de)
.build_argc_argv:
	call sys_ExecuteFile.load_argc_argv
	; bit 0,(ix-20)
; 	jr z,.argv_not_forwarding_return_code

; 	push bc ; push argc
; 	push bc ; push argc
; 	ex (sp),hl ; hl = argc, (sp) = argv
; 	add hl,hl
; 	add hl,bc
; 	push hl ; push argc*3
; 	call sys_Malloc.entryhl
; 	jq c,.fail
; 	ex hl,de
; 	pop bc,hl ; pop argc*3, old argv
; 	dec bc
; 	dec bc
; 	dec bc
; 	push de ; push new argv
; 	push hl ; push old argv
; 	ldir ; copy old argv (argc*3 - 3 bytes)
; 	push de
; 	ld hl,12 ; number of base-10 characters needed to represent a 32-bit integer
; 	call sys_Malloc.entryhl
; 	jq c,.fail
; 	ld (ix-23),hl ; save so we can free later
; 	ld de,(LastCommandResult)
; 	ld a,(LastCommandResult+3)
; 	push de
; 	ld e,a
; 	push de
; 	push hl
; 	call str_FromLong ; convert 32-bit unsigned result
; 	pop bc,bc,bc
; 	ex hl,de ; stringified result -> de
; 	pop hl
; 	ld (hl),de ; store stringified last command result
; 	pop hl ; pop old argv
; 	call sys_Free.entryhl ; free old argv
; 	pop hl ; pop new argv
; 	pop bc ; pop old argc
; 	db $3E ; dummify dec bc
; .argv_not_forwarding_return_code:
	dec bc ; decrement argc because otherwise there's an extra argument for some reason
	; grab program name from argv[0]
	ld de,(hl)
	inc hl
	inc hl
	inc hl
.push_and_call_execv:
	push hl ; &argv[1]
	push bc ; argc
	push de ; program name
; execute the program with argc/argv
	call sys_ExecV
	bit 0,(ix-20)
	ld hl,(ix-23)
	call nz,sys_Free.entryhl ; free space used to store return code if we're not going to use it
	call sys_Free ; free program name (also stores argv entries)
	pop bc,bc,hl
; free argv (starting at index 1) used to call the program after the program's been run
; 	jr .free_argv_loop_entry
; .free_argv_loop:
; 	push hl,bc
; 	ld hl,(hl)
; 	call sys_Free.entryhl
; 	pop bc,hl
; 	inc hl
; 	inc hl
; 	inc hl
; .free_argv_loop_entry:
; 	dec bc
; 	ld a,b
; 	or a,c
; 	jr nz,.free_argv_loop
; .check_if_at_eol:
.next_line:
	ld a,(ix-10)
	cp a,'~' ; check if maybe forwarding return
	jr z,.maybe_forward_return
	or a,a
	jq nz,.execute_program_string ;continue executing if an eol character was found before the null terminator
.done:
	ld hl,(ix-16)
	call sys_Free.entryhl
	; xor a,a
	; ld (curcol),a
	ld hl,(LastCommandResult)
	ld a,(LastCommandResult+3)
	ld e,a
	db $01 ; ld bc,... dummify scf / sbc hl,hl (3 bytes)
.fail:
	scf
	sbc hl,hl

	ld iy,(ix-6)
	ld sp,ix
	pop ix
	ret

.maybe_forward_return:
	ld hl,(ix-19) ; pointer to char following eol
	ld a,(hl)
	cp a,'>'
	jq nz,.execute_program_string
	inc hl
	ld (ti.curPC),hl
	set 0,(ix-20) ; indicate that the next program's arguments should contain the prior return code
	jq .execute_program_string

;; eventually allow for forwarding command output,
;; would require me to redo how text printing works so it goes through
;; a device file of some kind.
; .forward_output:
	; ld hl,(ix-3)
	; push hl
	; call fs_WriteNewFile

; returns Zf set if reached EOF or null terminator
.advance_to_next_line:
	xor a,a
	ld (ix-10),a
	ld c,a
	call .advance_to_next_line_loop
	jr nc,.advance_to_next_line_eol
.advance_to_next_line_eof:
	ld hl,(ti.endPC)
	xor a,a
	ld (ix-10),a
	ld (ix-19),hl
	jr .advance_return_line_length
.advance_to_next_line_eol:
	inc hl
	ld (ix-10),a
	ld (ix-19),hl
	cp a,':'
	jr z,.advance_return_line_length
	cp a,$A
	jr z,.advance_return_line_length
	call .advance_to_next_line_loop
	jr c,.advance_to_next_line_eof
	inc hl
.advance_return_line_length:
	ld bc,(ti.curPC)
	ld (ti.curPC),hl
	or a,a
	sbc hl,bc
	ld (ix-3),hl ; save length of processed line
	ret

.advance_to_next_line_loop:
; check if we've reached the end of the program
	ld bc,(ti.endPC)
	or a,a
	sbc hl,bc
	ccf
	ret c
	add hl,bc
	ld a,(hl)
	or a,a
	ret z
	cp a,'"'
	jr nz,.advance_to_next_line_not_quoted
.advance_to_next_line_quote_loop:
	inc hl
.advance_to_next_line_quote_loop_no_inc:
; check if we've reached the end of the program
	ld bc,(ti.endPC)
	or a,a
	sbc hl,bc
	ccf
	ret c
	add hl,bc
	ld a,(hl)
	or a,a
	ret z
	inc hl
	cp a,$5C ; backslash
	jr z,.advance_to_next_line_quote_loop
	cp a,'"'
	jr nz,.advance_to_next_line_quote_loop_no_inc
.advance_to_next_line_not_quoted:
	cp a,':'
	ret z
	cp a,$A
	ret z
	cp a,'~'
	ret z
	cp a,'>'
	ret z
	inc hl
	cp a,$5C ; backslash
	jr nz,.advance_to_next_line_loop
	inc hl
	jr .advance_to_next_line_loop
