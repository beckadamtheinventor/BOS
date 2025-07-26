
	jq if_main
	db "FEX",0
if_main:
	scf
	sbc hl,hl
	ld (hl),2
	ld hl,-6
	call ti._frameset
	xor a,a
	ld (ix-5),a
	ld (ix-6),a
	ld a,(ix+6)
	cp a,2
	jq c,.info
	syscall _argv_1
	ld a,(hl)
	or a,a
	jq z,.info
	inc hl
	cp a,'!'
	jr nz,.not_inverted
	ld a,(hl)
	inc hl
	set 0,(ix-5)
.not_inverted:
	call .readexpr
	ld (ix-3),hl
	ld (ix-4),a
	ex hl,de
	bit 1,(ix-5)
	jr z,.non_negative_left
	xor a,a
	ld l,a
	mlt hl
	ld de,(ix-3)
	ld c,(ix-4)
	sbc hl,de
	sbc a,c
	ld (ix-3),hl
	ld (ix-4),a
.non_negative_left:
	ld a,(hl)
	inc hl
	cp a,'<'
	jr z,.check_second_operator
	inc (ix-6)
	cp a,'>'
	jr z,.check_second_operator
	cp a,'='
	jq nz,.info
	ld (ix-6),4
	jr .read_right
.check_second_operator:
	ld a,(hl)
	cp a,'='
	jr nz,.read_right
	inc hl
	set 1,(ix-6)
.read_right:
	ld a,(hl)
	inc hl
	call .readexpr
	bit 1,(ix-5) ; right side negative
	jr z,.non_negative_right
	ld c,a
	ex hl,de
	xor a,a
	ld l,a
	mlt hl
	sbc hl,de
	sbc a,c
.non_negative_right:
	dec (ix-6)
	jr c,.check_lt
	jr z,.check_gt
	dec (ix-6)
	jr z,.check_lteq
	dec (ix-6)
	jr z,.check_gteq
	; or a,a ; carry flag probably will never be set here anyways
	call .compare
	jr z,.condition_true
	jr .condition_false
; A < B if (B - A) > 0
.check_lt:
	scf
	call .compare
	jr nc,.condition_true
	jr .condition_false
; A > B if (B - A) < 0
.check_gt:
	or a,a
	call .compare
	jr c,.condition_true
	jr .condition_false
; A <= B if (B - A) >= 0
.check_lteq:
	or a,a
	call .compare
	jr nc,.condition_true
	jr .condition_false
; A >= B if (B - A) <= 0
.check_gteq:
	scf
	call .compare
	jr c,.condition_true
	; jr .condition_false
	
.condition_false:
	bit 0,(ix-5)
	jq z,.condition_actually_false
.condition_true:
	bit 0,(ix-5)
	jq z,.exit_0
.condition_actually_false:
	call bos.sys_ExecSkipUntilEnd
	jq .exit_0
	
; .skipspace.next:
	; inc hl
; skip whitespace (advance) HL
; .skipspace:
	; ld a,(hl)
	; or a,a
	; ret z
	; cp a,' '
	; jr z,.skipspace.next
	; cp a,$9
	; ret nz
	; jr .skipspace.next


; subtract AUHL minus 32 bits from (ix-4)
; does not set/reset carry flag prior to subtraction
.compare:
	ld de,(ix-3)
	sbc hl,de
	sbc a,(ix-4)
	ret

; read expression from HL, storing result in AUHL and character where parsing stopped in DE.
.readexpr:
	cp a,'-'
	jr nz,.not_negative
	set 1,(ix-5)
	ld a,(hl)
	inc hl
.not_negative:
	push hl
	cp a,'$'
	jr nz,.not_hex
	syscall _hexstr_to_int
	jr .number
.not_hex:
	sub a,'0'
	jr c,.info
	cp a,10
	jr nc,.not_base_10_number
	syscall _str_to_int
	jr .number
.not_base_10_number:
	sub a,'A'-'0'
	jr c,.info
	cp a,26
	jr nc,.info
	pop hl
	dec hl
	push hl
	call ti.Mov9ToOP1
	call ti.ChkFindSym
	jr c,.var_not_found
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld a,(hl)
.bypass_var_name:
	pop hl
	push af,de,hl
	call bos.fs_PathLen
	pop hl,hl,af
	ret
.var_not_found:
	xor a,a
	sbc hl,hl
	ex hl,de
	jr .bypass_var_name
.number:
	pop bc
	ret

.info:
	ld hl,.infostr
	call bos.gui_PrintLine
.exit_0:
	or a,a
	sbc hl,hl
.exit_hl:
	ld sp,ix
	pop ix
	ret
.infostr:
	db "Usage:",$A
	db "if expr[<>=]expr",$A
	db "...",$A
	db "end",$A
	db "expr: [!][-][A-Z|[$]0-9A-F]",$A
	db 0
