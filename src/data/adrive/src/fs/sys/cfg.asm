
include '../../include/ez80.inc'
include '../../include/ti84pceg.inc'
include '../../include/bos.inc'

org 0
syscalllib
	export loadConfigData

loadConfigData:
	ld hl,-9
	call ti._frameset
	ld hl,(ix+6)
	ld bc,(ix+9)
.loop:
	ld a,(hl)
	cp a,'#'
	rst $28
	jp z,.nextline
.check:
	push hl,bc
	ld (ix-3),hl
	ld a,' '
	cpir
	ld a,(hl)
	inc hl
	cp a,'='
	rst $28
	jp nz,.next-$ ; skip if invalid statement
	ld a,(hl)
	inc hl
	cp a,'x'
	jr z,.hexbytearg
	cp a,'"'
	jr z,.stringargument
	ld d,'0'
	sub a,d
	rst $28
	jp c,.next-$
	cp a,10
	rst $28
	jp nc,.next-$
; decimal number argument
	ld e,a
; check next two digits are valid
	ld a,(hl)
	inc hl
	sub a,d
	cp a,10
	ret nc
	ld a,(hl)
	sub a,d
	cp a,10
	ret nc
	dec hl

	ld a,e
	sub a,d
	add a,a ; x2
	ld e,a
	add a,a ; x4
	add a,a ; x8
	add a,e ; x8 + x2 = x10
	add a,(hl) ; add next character offset from '0'
	sub a,d
	add a,a ; x2
	ld e,a
	add a,a ; x4
	add a,a ; x8
	add a,e ; x8 + x2 = x10
	add a,(hl) ; add next character offset from '0'
	sub a,d
	add a,a ; x2
	ld e,a
	add a,a ; x4
	add a,a ; x8
	add a,e ; x8 + x2 = x10
	ld (ix-6),a
	jr .find_field
.stringargument:
	pop bc
	push bc
	ld (ix-6),hl
.readstringloop:
	cpir ;find end of string
	dec hl
	ld a,(hl)
	cp a,$5C
	jq nz,.foundendofstring
	inc hl
	inc hl
	ld a,'"'
	jq .readstringloop
.foundendofstring:
	ld de,(ix-6)
	or a,a
	sbc hl,de
	inc hl
	push de,hl
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	ret c ;go to next line if failed to malloc
	dec bc
	ld (ix-6),de
	ldir
	xor a,a
	ld (de),a
	jr .find_field
.hexbytearg:
	ld a,(hl)
	inc hl
	rst $28
	call .nibble-$
	inc a
	ret z ;if a=0xff then we encountered an invalid hex character, so we should probably skip this line
	dec a
	add a,a
	add a,a
	add a,a
	add a,a
	ld e,a
	ld a,(hl)
	inc hl
	rst $28
	call .nibble-$
	inc a
	ret z ;if a=0xff then we encountered an invalid hex character, so we should probably skip this line
	dec a
	add a,e
	ld (ix-6),a
.find_field:
	ld hl,(ix+12)
.find_field_loop:
	ld a,(hl)
	or a,a
	jr z,.next
	ld c,(hl)
	inc hl
	ld (ix-9),hl
	ld de,(ix-3)
.check_field_name_loop:
	ld a,(de)
	inc de
	cp a,(hl)
	jr nz,.nextfield
	ld a,(hl)
	or a,a
	inc hl
	jr nz,.check_field_name_loop
	ld hl,(hl)
	ld a,c
	ld bc,(ix-6)
	cp a,'B'
	jr z,.write_byte_config
.write_int_config:
	ld (hl),bc
	jr .next
.write_byte_config:
	ld (hl),c
	jr .next
.nextfield:
	ld hl,(ix-9)
.nextfield_loop:
	ld a,(hl)
	inc hl
	or a,a
	jr nz,.nextfield_loop
	inc hl
	inc hl
	inc hl
	or a,(hl)
	jr nz,.find_field_loop
.next:
	pop bc,hl
.nextline:
	ld a,$A
	cpir
	rst $28
	jp pe,.loop-$
.done:
	ld sp,ix
	pop ix
	ret

.nibble:
	sub a,'0'
	jq c,.invalid
	cp a,10
	ret c
	sub a,7 ;subtract this from 'A'-'0' to get 10
	cp a,16 ;check if in range 'A'-'F'
	ret c ;return if in range
	sub a,$20 ;subtract 'a'-'A' to interpret lowercase
	cp a,16
	ret c ;return if within range 'a'-'f'
	ccf
.invalid:
	sbc a,a
	ret

end syscalllib
