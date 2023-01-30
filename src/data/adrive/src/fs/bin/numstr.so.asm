
; shared str<-->num code for os executables

_osrt_numstr_so:
	dd 2
	jp osrt.str_to_int
	jp osrt.hexstr_to_int
	jp osrt.nibble
	jp osrt.byte_to_hexstr
	jp osrt.int_to_hexstr
	jp osrt.long_to_hexstr
	jp osrt.b_to_hexstr
	jp osrt.byte_to_str
	jp osrt.int_to_str
	jp osrt.long_to_str
	jp osrt.intstr_to_int

virtual
	db "osrt.str_to_int       rb 4",$A
	db "osrt.hexstr_to_int    rb 4",$A
	db "osrt.nibble           rb 4",$A
	db "osrt.byte_to_hexstr   rb 4",$A
	db "osrt.int_to_hexstr    rb 4",$A
	db "osrt.long_to_hexstr   rb 4",$A
	db "osrt.b_to_hexstr      rb 4",$A
	db "osrt.byte_to_str      rb 4",$A
	db "osrt.int_to_str       rb 4",$A
	db "osrt.long_to_str      rb 4",$A
	db "osrt.intstr_to_str    rb 4",$A
	load _routines_osrt_numstr_so: $-$$ from $$
end virtual


; convert a base-10 string into an integer
; input int osrt.str_to_int(const char *str);
; output hl = number, de = character where parsing stopped
osrt.str_to_int:
	pop bc,de
	push de,bc
	or a,a
	sbc hl,hl
.loop:
	ld a,(de)
	or a,a
	ret z
	sub a,'0'
	ret c
	cp a,10
	ccf
	ret c
	inc de
	add hl,hl ;x2
	push hl
	add hl,hl ;x4
	add hl,hl ;x8
	pop bc
	add hl,bc ;x10
	ld bc,0
	ld c,a
	add hl,bc
	jr .loop


; input int osrt.intstr_to_int(const char *str);
; output auhl / cuhl.
; is str starts with $ or 0x, it will be processed as a hex string, otherwise a decimal string.
osrt.intstr_to_int:
	pop bc,hl
	ld a,(hl)
	inc hl
	cp a,'$'
	jr z,osrt.intstr_to_int.hex
	cp a,'0'
	jr nz,osrt.insstr_to_int.dec
	ld a,(hl)
	cp a,'x'
	jr z,osrt.intstr_to_int.hex
	dec hl
osrt.insstr_to_int.dec:
	dec hl
	push hl,bc
	jr osrt.str_to_int
osrt.intstr_to_int.hex:
	push hl,bc
assert $ = osrt.hexstr_to_int

; convert a base-16 string into an integer
; input int osrt.hexstr_to_int(const char *str);
; output auhl/cuhl = number, de = character where parsing stopped
osrt.hexstr_to_int:
	pop bc,de
	push de,bc
	or a,a
	sbc hl,hl
	ld c,l
	call osrt.hexstr_to_int.loop
	ld a,c
	ret

osrt.hexstr_to_int.loop:
	ld a,(de)
	or a,a
	ret z
	cp a,'F'+1
	ccf
	ret c
	cp a,'A'
	jr nc,osrt.hexstr_to_int.between_af
	sub a,'0'
	ret c
	cp a,10
	ccf
	ret c
	jr osrt.hexstr_to_int.add_a
osrt.hexstr_to_int.between_af:
	sub a,'A'-10
osrt.hexstr_to_int.add_a:
	inc de
	ld b,a    ;b = (de)
	xor a,a
	add hl,hl ;auhl * 2
	adc a,c
	add hl,hl ;auhl * 4
	adc a,c
	add hl,hl ;auhl * 8
	adc a,c
	add hl,hl ;auhl * 16
	adc a,c
	ld c,a    ;cuhl = auhl
	ld a,l    ;l = l + b
	add a,b
	ld l,a
	jr osrt.hexstr_to_int.loop

; input hl pointer to number
; input de pointer to output buffer
osrt.long_to_hexstr:
	ld b,4
	jr osrt.b_to_hexstr

; input hl pointer to number
; input de pointer to output buffer
osrt.int_to_hexstr:
	ld b,3

; input hl pointer to number
; input de pointer to output buffer
; input b number of input bytes
osrt.b_to_hexstr:
	ld a,b
osrt.int_to_hexstr.incloop:
	inc hl
	djnz osrt.int_to_hexstr.incloop
	ld b,a
osrt.int_to_hexstr.loop:
	call osrt.byte_to_hexstr
	djnz osrt.int_to_hexstr.loop
	ret

; input hl pointer to input
; input de pointer to output
osrt.byte_to_hexstr:
	dec hl
	ld a,(hl)
	rrca
	rrca
	rrca
	rrca
	call osrt.nibble
	ld (de),a
	inc de
	ld a,(hl)
	call osrt.nibble
	ld (de),a
	inc de
	ret

; input A nibble (upper 4 bits are ignored)
; output A hex character
osrt.nibble:
	and a,$F
	cp a,10
	jq nc,osrt.nibble.over9
	add a,'0'
	ret
osrt.nibble.over9:
	add a,'A'-10
	ret

; input char *osrt.int_to_str(char *dest, unsigned int num);
osrt.int_to_str:
	pop bc,de,hl
	push hl,de,bc
	push de,de
	ex (sp),iy
	xor a,a
	ld e,a
	jr osrt.long_to_str_10m

; input char *osrt.byte_to_str(char *dest, uint8_t num);
osrt.byte_to_str:
	pop bc,de,hl
	push hl,de,bc
	push de,de
	ex (sp),iy
	ld a,l
	or a,a
	sbc hl,hl
	ld l,a
	xor a,a
	ld e,a
	jr osrt.long_to_str_100

; input char *osrt.long_to_str(char *dest, uint32_t num);
osrt.long_to_str:
	push iy
	ld iy,0
	add iy,sp
	ld hl,(iy+9)
	ld a,(iy+12)
	ld iy,(iy+6)
	pop bc
	push iy,bc
	ld e,1000000000 shr 24
	ld bc,1000000000 and $FFFFFF
	call osrt.num_to_str_aqu
	ld e,100000000 shr 24
	ld bc,100000000 and $FFFFFF
	call osrt.num_to_str_aqu
	ld e,0
osrt.long_to_str_10m:
	ld bc,10000000
	call osrt.num_to_str_aqu
	ld bc,1000000
	call osrt.num_to_str_aqu
	ld bc,100000
	call osrt.num_to_str_aqu
osrt.long_to_str_10k:
	ld bc,10000
	call osrt.num_to_str_aqu
	ld bc,1000
	call osrt.num_to_str_aqu
osrt.long_to_str_100:
	ld bc,100
	call osrt.num_to_str_aqu
	ld c,10
	call osrt.num_to_str_aqu
	ld c,1
	call osrt.num_to_str_aqu
	ld (iy),0
	pop iy,hl
.skip_zeroes_loop:
	ld a,(hl)
	or a,a
	jr z,.return_single_zero
	cp a,'0'
	ret nz
	inc hl
	jr .skip_zeroes_loop
.return_single_zero:
	dec hl
	ret

osrt.num_to_str_aqu:
	ld d,'0'-1
osrt.num_to_str_aqu.loop:
	inc d
	or a,a
	sbc hl,bc
	sbc a,e
	jr nc,osrt.num_to_str_aqu.loop
	add hl,bc
	adc a,e
	ld (iy),d
	inc iy
	ret
