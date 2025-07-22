
include "../include/ez80.inc"
include "../include/ti84pceg.inc"
include "../include/bos.inc"

; shared str<-->num code

syscalllib "numstr"
	export osrt.str_to_int, "str_to_int", "_str_to_int", "int osrt.str_to_int(const char *str);"
	export osrt.hexstr_to_int, "hexstr_to_int", "_hexstr_to_int", "int osrt.hexstr_to_int(const char *str);"
	export osrt.nibble, "nibble"
	export osrt.byte_to_hexstr, "byte_to_hexstr"
	export osrt.int_to_hexstr, "int_to_hexstr"
	export osrt.long_to_hexstr, "long_to_hexstr"
	export osrt.b_to_hexstr, "b_to_hexstr"
	export osrt.byte_to_str, "byte_to_str", "_byte_to_str", "char *osrt.byte_to_str(char *dest, uint8_t num);"
	export osrt.int_to_str, "int_to_str", "_int_to_str", "char *osrt.int_to_str(char *dest, unsigned int num);"
	export osrt.long_to_str, "long_to_str", "_long_to_str", "char *osrt.long_to_str(char *dest, uint32_t num);"
	export osrt.intstr_to_int, "intstr_to_int", "_intstr_to_int", "int osrt.intstr_to_int(const char *str);"


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
; if str starts with $ or 0x, it will be processed as a hex string, otherwise a decimal string.
; if str starts with %, the value will be read from a variable (or zero if the variable doesn't exist)
osrt.intstr_to_int:
	pop bc,hl
	ld a,(hl)
	inc hl
	cp a,'%'
	jr z,osrt.intstr_to_int.var
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

osrt.intstr_to_int.var:
	push hl
osrt.intstr_to_int.var.loop:
	ld a,(hl)
	or a,a
	jr z,osrt.intstr_to_int.var.found_end
	cp a,'%'
	jr nz,osrt.intstr_to_int.var.loop
osrt.intstr_to_int.var.found_end:
	pop de
	or a,a
	sbc hl,de
	inc hl
	push de,hl
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	dec hl
	push de
	ldir
	xor a,a
	ld (de),a
	ld hl,(bos.variable_sym_list_ptr)
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,osrt.intstr_to_int.var.return_zero
	push hl
	call bos.util_SearchSymList
	add hl,bc
	xor a,a
	sbc hl,bc
	jr z,osrt.intstr_to_int.var.dont_load_value
	ld bc,bos.symbol.flags
	add hl,bc
	ld a,(hl)
	inc hl
	ld hl,(hl)
osrt.intstr_to_int.var.dont_load_value:
	pop bc
osrt.intstr_to_int.var.return_zero:
	pop bc
	push af,hl,bc
	call bos.sys_Free
	pop bc,hl,af
	ld c,a
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
	ld a,c
	add hl,hl ;auhl * 2
	adc a,a
	add hl,hl ;auhl * 4
	adc a,a
	add hl,hl ;auhl * 8
	adc a,a
	add hl,hl ;auhl * 16
	adc a,a
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
	xor a,a
	ld (de),a
	ret

; input hl pointer to input byte + 1
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

end syscalllib