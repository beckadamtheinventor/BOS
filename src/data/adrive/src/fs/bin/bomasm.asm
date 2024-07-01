
	jr _bomasm_main
	db "FEX", 0
_bomasm_main:
	call ti._frameset0
	ld a,(ix+6)
	cp a,3
	jr nc,.has_enough_args
	ld hl,.str_info
	or a,a
	sbc hl,hl
	pop ix
	ret
.has_enough_args:
	call osrt.argv_1

.exit0:
	or a,a
	sbc hl,hl
.exithl:
	ld sp,ix
	pop ix
	ret
.exit1:
	ld hl,1
	jr .exithl

; returns number of bytes written
; size_t assemble(char *src, size_t len, uint8_t *out, size_t *org)
.assemble:
	ld hl,-24
	call ti._frameset
	; init local symtbl
	or a,a
	sbc hl,hl
	ld (ix-3),hl
	ld (ix-6),hl
	ld (ix-21),hl ; out_offset
	ld (ix-9),hl ; src offset
	inc hl
	ld (ix-18),hl ; lineno
	ld hl,(ix+6)
	ld (ix-12),hl ; src
	ld hl,(ix+9)
	ld (ix-15),hl ; src len
	ld hl,(ix+15)
	ld hl,(hl)
	ld (ix-24),hl ; org
.assemble_loop:
	call .peekchar
	jr c,.assemble.done
	call .isidentifier
	jr c,.not_identifier
	call .readidentifier
	push hl
	pea ix-6
	call bos.util_SearchSymList
	pop bc,de
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.error_undefined_identifier
	push hl,de
	call bos.sys_Free
	pop de,hl
	call .parse_identifier_contents
.not_identifier:
	cp a,'@'
	jr z,.setorg
	cp a,'$'
	jr z,.macrodef
	cp a,'='
	jr z,.valuedefine
	jq .error_unexpected_token

.valuedefine:
	call .readidentifier
	push hl
	call .readint
	pop de
	ld c,0
	push bc,hl,de
	pea ix-6
	call bos.util_AppendSymList
	pop bc,bc,bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.error_out_of_memory
	jr .assemble_loop

.setorg:
	call .readint
	ld (ix-24),hl
	jr .assemble_loop

.macrodef:
	call .readidentifier ; macro name
	push hl
	
	pop hl
	jr .assemble_loop

.assemble.done:
	ld hl,(ix+15) ; return org
	ld de,(ix-24)
	ld (hl),de
	ld hl,(ix-21) ; return out_offset
	ld sp,ix
	pop ix
	ret

; bool isidentifier(void)
; check if A is the start of an identifier
; return Cf set if A is *not* the start of an identifier
.isidentifier:
	cp a,'_'
	ret z
	sub a,'A' ; check uppercase
	cp a,26
	ccf
	ret c
	sub a,$20 ; check lowercase
	cp a,26
	ccf
	ret

; char peekchar(void)
; note: skips whitespace
; returns Cf set if EOF reached
.peekchar:
	ld hl,(ix-12) ; src
	ld de,(ix-9) ; src offset
	add hl,de
.peekchar.skipspaces.loop:
	call .check_hl_eof
	ret c
	ld a,(hl)
	cp a,' '
	jr z,.peekchar.skipspaces
	cp a,$9
	jr z,.peekchar.skipspaces
	cp a,$A
	jr z,.peekchar.skipnewline
	or a,a
	ret
.peekchar.skipnewline:
; increment lineno
	ld bc,(ix-18)
	inc bc
	ld (ix-18),bc
.peekchar.skipspaces:
	inc hl
	inc de
	jr .peekchar.skipspaces.loop

; error if hl >= eof
.error_if_hl_eof:
	call .check_hl_eof
	ret nc
	jq .error_unexpected_eof

; returns Cf set if hl >= eof
.check_hl_eof:
	push de,hl
	ld hl,(ix-12) ; src
	ld de,(ix-15) ; src len
	add hl,de
	ex hl,de
	pop hl
	or a,a
	sbc hl,de
	ccf
	add hl,de
	pop de
	ret

.parse_identifier_contents:
	ld bc,bos.symbol.flags
	add hl,bc
assert bos.symbol.flags < 256
	ld c,(hl)
	ld a,.parse_identifier_contents_jt_size
	cp a,c
	ccf
	ret c ; don't parse if symbol type is out of range
	inc hl
	ld iy,(hl)
	ld hl,.parse_identifier_contents_jt
	add hl,bc
	add hl,bc
	add hl,bc
	ld hl,(hl)
	jp (hl)

.parse_identifier_contents_jt:
	dl .error_unexpected_identifier_type_is_value
	dl .parse_id_1
	dl .parse_id_2
.parse_identifier_contents_jt_size := ($ - .parse_identifier_contents_jt) / 3

; write literal data
; { uint8_t len; uint8_t data[len]; }
.parse_id_1:
assert bos.symbol.flags < 256
	ld c,(iy)
	ld hl,(ix-21) ; out_offset
	push hl
	add hl,bc
	ld (ix-21),hl ; advance out_offset
	pop hl
	ld de,(ix+12) ; uint8_t *out
	add hl,de
	ex hl,de
	lea hl,iy+1
	ldir
	ret

; write data from source data
; { uint8_t chunk_size; }
.parse_id_2:
	call .readint
	ld a,(iy)
	call .write_a_bytes_from_cuhl
	call .peekchar
	cp a,','
	
	ret

.write_a_bytes_from_cuhl:
	push hl
	ld hl,(ix+12) ; out
	ld de,(ix-21) ; out_offset
	add hl,de
	pop de
	ld (hl),de
	ld de,(ix-21)
	inc hl
	inc de
	dec a
	jr z,.write_a_bytes_from_cuhl.done
	inc hl
	inc de
	dec a
	jr z,.write_a_bytes_from_cuhl.done
	inc hl
	inc de
	dec a
	jr z,.write_a_bytes_from_cuhl.done
	ld (hl),c
	inc de
.write_a_bytes_from_cuhl.done:
	ld (ix-21),de ; advance out_offset
	ret

; uint32_t readint(void)
; note: returns in auhl / cuhl
.readint:
	ld hl,(ix-12) ; src
	ld bc,(ix-9) ; src offset
	add hl,bc
	push hl
	call osrt.intstr_to_int
	ex (sp),hl
	ex hl,de
	or a,a
	sbc hl,de ; get length of number parsed
	ld de,(ix-9)
	add hl,de
	ld (ix-9),hl
	pop hl ; pop low 24 bits of number
	ret


; char *readidentifier(void)
.readidentifier:
	ld hl,(ix-15) ; src len
	push hl
	ld hl,(ix-9) ; src offset
	push hl
	ld hl,(ix-12) ; src
	push hl
	call osrt.sreadidentifier
	pop bc,bc,bc
	add hl,bc
	xor a,a
	sbc hl,bc
	jr z,.error_invalid_identifier ; fail if str == 0
	push hl
	call ti._strlen
	ld bc,(ix-9) ; offset
	add hl,bc
	ld (ix-9),hl ; advance offset
	pop hl
	ld a,(hl)
	or a,a
	ret nz
	; also fail if str[0] == 0

.error_invalid_identifier:
	ld hl,.str_error_invalid_identifier
.error_print_and_return:
	call bos.gui_PrintLine
	ld hl,.str_error_on_line
	call bos.gui_Print
	ld hl,(ix-18)
	call bos.gui_PrintUInt
	call bos.gui_NewLine
	jq .exit1

.error_undefined_identifier:
	ld hl,.str_error_undefined_identifier
	jr .error_print_and_return

.error_unexpected_token:
	ld hl,.str_error_unexpected_token
	jr .error_print_and_return

.error_unexpected_eof:
	ld hl,.str_error_unexpected_eof
	jr .error_print_and_return

.error_unexpected_identifier_type_is_value:
	ld hl,.str_error_unexpected_identifier_type_is_value
	jr .error_print_and_return

.error_out_of_memory:
	ld hl,.str_error_out_of_memory
	jr .error_print_and_return

.str_error_on_line:
	db "Error on line ", 0

.str_error_undefined_identifier:
	db "Undefined identifier", 0

.str_error_invalid_identifier:
	db "Invalid identifier", 0

.str_error_unexpected_token:
	db "Unexpected token", 0

.str_error_unexpected_eof:
	db "Unexpected end of file", 0

.str_error_unexpected_identifier_type_is_value:
	db "Unexpected identifier type (value define)", 0

.str_error_out_of_memory:
	db "Out of memory", 0

.str_info:
	db "bomasm src.asm bin", 0
