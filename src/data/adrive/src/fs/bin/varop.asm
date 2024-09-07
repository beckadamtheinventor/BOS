	jq var_main
	db "FEX",0
var_main:
	ld hl,-14
	call ti._frameset
	ld (ix-11),0
	ld a,(ix+6)
	dec a
	jr z,.help
	dec a
	jr z,.define_int_0
	dec a
	jr z,.help
	dec a
	jr z,.define_var_with_value

.help:
	ld hl,.helpstr
	call bos.gui_PrintLine
	ld hl,1
	jr .done

.define_int_0:
	xor a,a
	sbc hl,hl
	ld (ix-6),hl
	ld (ix-7),a
	jr .define_var

.define_var_with_value:
	call osrt.argv_3
	ld a,(hl)
	cp a,'0'
	jr nz,.grab_dec
	inc hl
	cp a,'x'
	jr z,.grab_hex
	dec hl

.grab_dec:
	push hl
	call osrt.str_to_int
	jr .define_var_with_value_set_value

.grab_hex:
	inc hl
	push hl
	call osrt.hexstr_to_int

.define_var_with_value_set_value:
	pop bc
	ld (ix-6),hl
	xor a,a
	ld (ix-7),a
	call osrt.argv_2
	ld a,(hl)
	cp a,'='
	jr z,.set_to_value

	push hl
	call osrt.argv_1
	push hl
	call varptr_main
	ld (ix-14),hl
	ld hl,(hl)
	pop bc
	pop de

	ld a,(de)
	inc de

	ld bc,(ix-6)
	cp a,'/'
	jr z,.div_val
	cp a,'%'
	jr z,.mod_val
	cp a,'*'
	jr z,.mul_val

	push bc
	pop de

	cp a,'+'
	jr z,.add_val
	cp a,'-'
	jr z,.sub_val
	jq .help

.mod_val:
	call ti._iremu
	jr .set_to_value_hl

.div_val:
	push de
	call ti._idvrmu
	ld (ix-10),hl
	ex hl,de
	pop bc
	ld a,(bc)
	cp a,'/'
	jr z,.set_to_value_hl ; integer division
	inc (ix-11)
	jr .set_to_value_hl

.mod_val:
	call ti._iremu
	jr .set_to_value_hl

.mult_val:
	call ti._imulu
	jr .set_to_value_hl

.sub_val:
	or a,a
	sbc hl,de
	jr .set_to_value_hl

.add_val:
	add hl,de

.set_to_value_hl:
	ld (ix-6),hl

.set_to_value:
	call osrt.argv_3
	jr .define_var_hl

.define_var_arg1:
	call osrt.argv_1

.define_var_hl:
	push hl
	call bos.fs_PathLen
	ld a,l
	or a,h
	jr z,.fail
	push hl
	inc hl  ; TODO: change this for different kinds of variable
	inc hl
	inc hl
	inc hl  ; account for null terminator
	push hl
	call bos.sys_Malloc
	jr c,.fail
	ld a,(ix-7)
	ld de,(ix-6)
	ld (hl),a
	inc hl
	ld (hl),de  ; TODO: change this for different kinds of variable
	inc hl
	inc hl
	inc hl
	ex hl,de
	pop bc,bc,hl
	ldir
	xor a,a
	ld (de),a

.success:
	or a,a
	db $3E
.fail:
	scf
	sbc hl,hl
.done:
	push hl
	ld hl,(ix-10)
	ld a,(ix-11)
	or a,a
	jr z,.done_dont_return_num
	ld a,(bos.return_code_flags)
	set bos.bReturnNotError,a
	ld (bos.return_code_flags),a
	db $3E
.done_dont_return_num:
	pop hl
	ld sp,ix
	pop ix
	ret

.helpstr:
	db "varop name [+-*//%] [val|var]",$A,$9,"set var to var [+ - * / // %] value/var",$A
; TODO: and, bit#, equal, greater, less, or, xor
	db "values are in base 10, or base 16 if prefixed with 0x", 0
