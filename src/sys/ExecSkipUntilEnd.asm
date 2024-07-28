;@DOES Advance curPC until the corresponding "end" or "else"
;@INPUT void sys_ExecSkipUntilEnd(void);
sys_ExecSkipUntilEnd:
	push iy
	ld iy,1
	jr .entry
.loop:
	call sys_ExecContinue.advance_to_next_line
.entry:
	ld hl,(ti.curPC)
	ld de,(ti.endPC)
	or a,a
	sbc hl,de
	ret nc ; cur >= end
	add hl,de
	; ld hl,(ti.curPC)
	ld de,str_if
	call _StrCmpre0
	jr z,.found_if

	ld hl,(ti.curPC)
	ld de,str_end
	call _StrCmpre0
	jr z,.found_end

	ld hl,(ti.curPC)
	ld de,str_else
	call _StrCmpre0
	jr z,.found_else

	ld hl,(ti.curPC)
	ld de,str_repeat
	call _StrCmpre0
	jr z,.found_repeat

	ld hl,(ti.curPC)
	ld de,str_while
	call _StrCmpre0
	jr z,.found_while

	jr .loop
.found_else:
.found_end:
	dec iy
	lea hl,iy
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.done
	jr .loop
.found_if:
.found_repeat:
.found_while:
	inc iy
	jr .loop
.done:
	pop iy
	ret



