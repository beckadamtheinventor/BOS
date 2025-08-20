;@DOES Convert a string representation of a number to a signed 32-bit integer. See Notes for details.
;@INPUT int32_t str_IntStrToInt(const char *str);
;@OUTPUT euhl = number.
;@NOTE If str starts with $ or 0x, it will be processed as a hex string, otherwise a decimal string. If str starts with %, the value will be read from a variable from the current symlist. (defaulting to zero if the variable doesn't exist)
str_IntStrToInt:
	pop bc,hl
	ld a,(hl)
    sub a,'-'
    push af
    jr nz,.not_negative
    inc hl
.not_negative:
    ld a,(hl)
	inc hl
	cp a,'%'
	jr z,.var
	cp a,'$'
	jr z,.hex
	cp a,'0'
	jr nz,.insstr_to_int.dec
	ld a,(hl)
	cp a,'x'
	jr z,.hex
	dec hl
.insstr_to_int.dec:
	dec hl
	push hl,bc
	call str_ToInt
    jr .negate_if_was_negative
.hex:
	push hl,bc
    call str_HexToInt
.negate_if_was_negative:
    pop bc,bc
    pop af
    ret nz
    jq str_LongToStr.negate

.var:
	push hl
.var.loop:
	ld a,(hl)
	or a,a
	jr z,.var.found_end
	cp a,'%'
	jr nz,.var.loop
.var.found_end:
	pop de
	or a,a
	sbc hl,de
	inc hl
	push de,hl
	call sys_Malloc
	ex hl,de
	pop bc,hl
	dec hl
	push de
	ldir
	xor a,a
	ld (de),a
	ld hl,(variable_sym_list_ptr)
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.var.return_zero
	push hl
	call util_SearchSymList
	add hl,bc
	xor a,a
	sbc hl,bc
	jr z,.var.dont_load_value
	ld bc,symbol.flags
	add hl,bc
	ld a,(hl)
	inc hl
	ld hl,(hl)
.var.dont_load_value:
	pop bc
.var.return_zero:
	pop bc
	push af,hl,bc
	call sys_Free
	pop bc,hl,af
	ld e,a
	jr .negate_if_was_negative
