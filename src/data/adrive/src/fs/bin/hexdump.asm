
	jr _hexdump_main
	db "FEX",0

_hexdump_main:
	ld hl,-9
	call ti._frameset
	or a,a
	sbc hl,hl
	ld (ix-3),hl
	ld (ix-6),hl
	ld a,(ix+6)
    cp a,2
    jp c,.display_info
	cp a,3
	jr c,.no_offset_len
	call osrt.argv_2
	push hl
	call osrt.intstr_to_int
	pop bc
	ld (ix-3),hl
	ld a,(ix+6)
	cp a,4
	jr c,.no_offset_len
	call osrt.argv_3
	push hl
	call osrt.intstr_to_int
	pop bc
	ld (ix-6),hl
.no_offset_len:
	call osrt.argv_1
	push hl
	call bos.fs_GetFilePtr
	pop de
	jr c,.error_not_found
	ld (ix-9),hl ; data pointer
	ld hl,(ix-3) ; offset
	; or a,a
	sbc hl,bc
	add hl,bc
	jr c,.offset_in_range
	ld (ix-3),bc
.offset_in_range:
	ex hl,de
	ld hl,(ix-6) ; length
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.length_zero
	add hl,de ; offset + length
	or a,a
	sbc hl,bc
	jr c,.length_in_range
.length_zero:
	push bc
	pop hl
	; or a,a
	sbc hl,de
	ld (ix-6),hl
.length_in_range:
	ld hl,(ix-9) ; data pointer
	ld bc,(ix-3) ; offset
	add hl,bc
	ld bc,(ix-6) ; length

	ld a,' '
	ld (bos.gfx_string_temp+2),a
	xor a,a
	ld (bos.gfx_string_temp+3),a
	inc hl
	ld iyl,8
.loop:
	ld de,bos.gfx_string_temp
	push iy,bc,hl,de
	call osrt.byte_to_hexstr
	pop hl
	push hl
	call bos.gui_Print
	pop de,hl,bc,iy
	dec iyl
	jr nz,.next
	push hl,de,bc
	call bos.gui_NewLine
	call bos.sys_AnyKey
	pop bc,de,hl
	jr nz,.exit
	ld iyl,8
.next:
	cpi
	jp pe,.loop
	call bos.gui_NewLine
	jr .exit
.error_not_found:
	ld hl,str_FileNotFound ; string stored elsewhere
	jr .display
.display_info:
	ld hl,.str_display_info
.display:
	call bos.gui_PrintLine
.exit:
	xor a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret

.str_display_info:
	db "Usage: hexdump file [offset [length]]",0
