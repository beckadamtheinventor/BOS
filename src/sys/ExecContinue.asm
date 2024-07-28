;@DOES Continue Execution from curPC.
;@INPUT int32_t sys_ExecContinue(void);
;@OUTPUT process exit code.
;@OUTPUT exit code also stored in bos.LastCommandResult
sys_ExecContinue:
	ld hl,-13
	call ti._frameset
	ld (ix-6),iy
	ld (ix-10),0
.execute_program_string:
	ld hl,(ti.curPC)
	push hl
	call .advance_to_next_line
	pop hl
	jr z,.done
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
	jr c,.fail
	ld bc,(ix-3)
	push de
	ldir
	dec de
	xor a,a
	ld (de),a
	pop de
; build argc/argv (string in de)
.build_argc_argv:
	call sys_ExecuteFile.load_argc_argv
	; grab program name from argv[0]
	ld de,(hl)
	dec bc ; decrement argc because otherwise there's an extra argument for some reason
	inc hl
	inc hl
	inc hl
	push hl ; argv
	push bc ; argc
	push de ; program name
; execute the program with argc/argv
	call sys_ExecV
	pop bc,bc,bc
; .check_if_at_eol:
.next_line:
	ld a,(ix-10)
	; cp a,'>' ; check if forwarding output
	; jr z,.forward_output
	or a,a
	jr nz,.execute_program_string ;continue executing if an eol character was found before the null terminator
.done:
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
.advance_to_next_line_loop:
; check if we've reached the end of the program
	ld bc,(ti.endPC)
	or a,a
	sbc hl,bc
	jr nc,.advance_to_next_line_eof
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
	jr nc,.advance_to_next_line_eof
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
	jr z,.advance_to_next_line_eol
	cp a,$A
	jr z,.advance_to_next_line_eol
	; cp a,'>'
	; jr z,.advance_to_next_line_eol
	inc hl
	cp a,$5C ; backslash
	jr nz,.advance_to_next_line_loop
	inc hl
	jr .advance_to_next_line_loop
.advance_to_next_line_eof:
	ld hl,(ti.endPC)
	xor a,a
.advance_to_next_line_eol:
	ld (ix-10),a
	inc hl
	ld bc,(ti.curPC)
	ld (ti.curPC),hl
	or a,a
	sbc hl,bc
	ld (ix-3),hl ; save length of processed line
	ret
