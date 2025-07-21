
	jr _asmcomp_exe
	db "FEX", 0
_asmcomp_exe:
	; scf
	; sbc hl,hl
	; ld (hl),2
	ld hl,-25
	call ti._frameset
	ld a,(ix+6)
	cp a,3
	jr nc,.has_enough_arguments
	ld hl,.str_info
	call bos.gui_PrintLine
	or a,a
	jq .exit_cf
.has_enough_arguments:
	syscall _argv_1
	push hl
	call bos.fs_GetFilePtr
	pop de
	; jq c,.exit_cf
	jr nc,.file_exists
	ld hl,.test_program_src
	ld bc,.test_program_src.len
	xor a,a
.file_exists:
	bit bos.fd_subdir, a
	scf
	jq nz,.exit_cf
	ld (ix-3),hl
	ld (ix-6),bc
	or a,a
	sbc hl,hl
	ld (ix-12),hl
	inc hl
	ld (ix-19),hl
	ld hl,ti.pixelShadow
	ld (ix-9),hl
	ld iy,ti.pixelShadow + 69090 - .j_size+1 ; end of pixelShadow
	ld (ix-22),iy
	ld (iy+.j_size),0
.assemble:
	ld hl,(ix-6)
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.finalize
	call .getc
	call .handle_not_byte
	jr nc,.assemble
	call .nibble
	add a,a
	add a,a
	add a,a
	add a,a
	ld e,a
	call .getc
	call .nibble
	add a,e
	ld hl,(ix-9)
	ld (hl),a
	inc hl
	ld (ix-9),hl
	jr .assemble
.finalize:
	ld iy,(ix-22)
.finalize_loop:
	ld a,(iy+.j_size)
	or a,a
	jr z,.success
	ld a,(iy+.j_addr+2)
	cp a,$80
	jq z,.undefined_label
	ld hl,(iy+.j_sym)
repeat .j_addr
	inc hl
end repeat
	ld de,(hl)
	ld hl,(iy+.j_addr)
	ld a,(iy+.j_size)
	bit 7,a
	jr z,.finalize_loop_not_offset
	; negate value to be written
	push hl
	or a,a
	sbc hl,hl
	sbc hl,de
	ex hl,de
	pop hl
	res 7,a
.finalize_loop_not_offset:
	cp a,3
	jr nc,.finalize_write_long
	ld (hl),e
	dec a
	jr z,.finalize_loop_check_range_1
	inc hl
	ld (hl),d
	jr .finalize_loop
.finalize_write_long:
	ld (hl),de
	jr .finalize_loop
.finalize_loop_check_range_1:
	push hl
	push de
	pop hl
	or a,a
	adc hl,hl
	jr nc,.finalize_loop_check_range_1_over_0
	ccf
	sbc hl,hl
	sbc hl,de
.finalize_loop_check_range_1_over_0:
	ld de,$100
	or a,a
	sbc hl,de
	jq c,.finalize_loop
	ld hl,.str_error_range
	call bos.gui_PrintLine
	ld hl,3
	jr .exit_hl
.success:
	ld bc,ti.pixelShadow
	ld hl,(ix-9)
	xor a,a
	sbc hl,bc
	push hl,bc
	ld c,a
	push bc
	syscall _argv_2
	push hl
	call bos.fs_WriteNewFile
	pop bc,bc,bc,bc
	jr nc,.final_success
	ld hl,.str_failed_to_write
	call bos.gui_PrintLine
	ld hl,-2
	jr .exit_hl
.final_success:
	ld hl,.str_success
	call bos.gui_PrintLine
	or a,a
.exit_cf:
	sbc hl,hl
.exit_hl:
	ld sp,ix
	pop ix
	ret

.nibble:
	sub a,'0'
	jr c,.error_syntax
	cp a,10
	ret c
	sub a,'A' - '9' - 1
	cp a,16
	ret c
	sub a,$20
	cp a,16
	ret c

.error_syntax:
	ld hl,.str_error_syntax
	jr .exit_error

.invalid_label:
	ld hl,.str_invalid_label
	jr .exit_error

.label_name_too_long:
	ld hl,.str_label_name_too_long
	jr .exit_error

.undefined_label:
	ld hl,.str_undefined_label
	jr .exit_error

.memory_error:
	ld hl,.str_memory_error
	jr .exit_error

.unexpected_eof:
	ld hl,.str_unexpected_eof

.exit_error:
	call bos.gui_PrintLine
	ld hl,.str_error_on_line
	call bos.gui_Print
	ld hl,(ix-19)
	call bos.gui_PrintUInt
	call bos.gui_NewLine
	ld hl,1
	jr .exit_hl

; input hl -> label name
; output e = label name length
.get_label_name_len:
	ld e,0
.skip_alpha_chars:
	call .getc
	inc e
	jr c,.label_name_too_long
	cp a,'_'
	jr z,.skip_alpha_chars
	cp a,' '
	ret z
	cp a,$A
	ret z
	cp a,$9
	ret z
	cp a,'0'
	jr c,.invalid_label
	cp a,'9'+1
	jr nc,.skip_alpha_chars
	and a,$EF
	cp a,'A'
	jr c,.invalid_label
	cp a,'Z'+1
	jr nc,.invalid_label
	jr .skip_alpha_chars

; input hl -> symbol name
; input e = symbol name len
; returns iy -> symbol
; defines new symbol if not found
.findsym:
	ld (ix-15),hl
	ld (ix-16),e
	jr .findsym.next
.findsym.loop:
	lea hl,iy+.sym_name
	ld de,(ix-15)
	ld b,(ix-16)
.findsym.compareloop:
	ld a,(de)
	cp a,(hl)
	jr nz,.findsym.next
	inc hl
	inc de
	djnz .findsym.compareloop
	or a,(hl)
	ret z
.findsym.next:
	ld hl,(iy+.sym_next)
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.define_sym
	ld iy,(iy+.sym_next)
	jr .findsym.loop

.define_sym:
	ld hl,.sym_size
	ld d,1
	mlt de
	add hl,de
	push hl
	call bos.sys_Malloc
	jq c,.memory_error
	pop de
	ld (iy+.sym_next),hl
	ld iy,(iy+.sym_next)
	or a,a
	sbc hl,hl
	ld (iy+.sym_next),hl
	ld hl,$800000
	ld (iy+.sym_addr),hl
	ld hl,(ix-15)
	ld b,(ix-16)
	lea de,iy+.sym_name
.define_sym_copy_name_loop:
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	djnz .define_sym_copy_name_loop
	xor a,a
	ld (de),a
	ret

.getc:
	ld hl,(ix-6)
	add hl,bc
	or a,a
	sbc hl,bc
	jp z,.unexpected_eof
	
	ld hl,(ix-3)
	ld bc,(ix-6)
	ld a,(hl)
	cpi
	ld (ix-3),hl
	ld (ix-6),bc
	cp a,$A
	ret nz
	ld hl,(ix-19)
	inc hl
	ld (ix-19),hl
	ret

.handle_not_byte:
	ld hl,(ix-3)
	cp a,$A
	ret z
	cp a,$9
	ret z
	cp a,' '
	ret z
	cp a,'!'
	jr nz,.not_comment
	ld bc,(ix-6)
	ld a,$A
	cpir
	ld (ix-6),bc
	ld (ix-3),hl
	ret
.not_comment:
	cp a,'"'
	jr nz,.not_string
	ld de,(ix-9)
.handle_string_loop:
	ldi
	ld a,(hl)
	cp a,$5C ; backslash
	jr nz,.handle_string_not_backslash
	inc hl
.handle_string_not_backslash:
	cp a,'"'
	jr nz,.handle_string_loop
	ld (ix-9),de
	inc hl
	jr .calc_new_remaining_len
.not_string:
	cp a,'?'
	jr nz,.not_set_origin
	push hl
	syscall _hexstr_to_int
	pop bc
	ld (ix-25),hl
	ex hl,de
.calc_new_remaining_len:
	ld de,(ix-3)
	ld (ix-3),hl
	or a,a
	sbc hl,de
	ex hl,de
	ld hl,(ix-6)
	or a,a
	sbc hl,de
	ld (ix-6),hl
	or a,a
	ret
.not_set_origin:
	cp a,'.'
	jr nz,.not_put_label
	call .getc
	and a,$EF
	ld d,a
	push de
	call .getc
	ld hl,(ix-3)
	push hl
	call .get_label_name_len
	dec e
	pop hl
	call .findsym
	pop de
	ld a,(iy+.sym_addr+2)
	cp a,$80
	jr z,.add_to_resolve_later
	ld bc,(iy+.sym_addr)
	ld hl,(ix-9)
	ld (hl),bc
	ld bc,(ix-9)
.handle_not_byte.pass_label_emit:
	ld a,d
	inc bc
	cp a,'B'
	jr z,.handle_not_byte.pass_label_emit.done
	cp a,'D'
	jr z,.handle_not_byte.pass_label_emit.done
	inc bc
	cp a,'W'
	jr z,.handle_not_byte.pass_label_emit.done
	inc bc
	cp a,'L'
	jq nz,.error_syntax
.handle_not_byte.pass_label_emit.done:
	ld (ix-9),bc
	or a,a
	ret
.add_to_resolve_later:
	ld bc,(ix-9)
	ld hl,(ix-22)
	push hl
	dec hl
	dec hl
	dec hl
	ld (hl),iy
	dec hl
	dec hl
	dec hl
	ld (hl),bc
	dec hl
	ld (ix-22),hl
	call .handle_not_byte.pass_label_emit
	pop hl
	cp a,'B'
	jr nz,.add_to_resolve_later.not_1
	ld (hl),1
.add_to_resolve_later.not_1:
	cp a,'W'
	jr nz,.add_to_resolve_later.not_2
	ld (hl),2
.add_to_resolve_later.not_2:
	cp a,'L'
	jr nz,.add_to_resolve_later.not_3
	ld (hl),3
.add_to_resolve_later.not_3:
	cp a,'D'
	jq nz,.error_syntax
	ld (hl),$81
	ret
.not_put_label:
	cp a,':'
	; jr z,.define_label
	scf
	ret nz
	ld hl,(ix-3)
	push hl
	call .get_label_name_len
	dec e
	pop hl
	call .findsym
	ld hl,(ix-9)
	ld de,ti.pixelShadow
	or a,a
	sbc hl,de
	ld de,(ix-25)
	add hl,de
	ld (iy+.sym_addr),hl
	or a,a
	ret


virtual at 0
.sym_next rb 3
.sym_addr rb 3
.sym_name rb 1
.sym_size rb 0
end virtual

virtual at 0
.j_addr rb 3
.j_sym rb 3
.j_size rb 1
end virtual

.str_memory_error:
	db "Out of memory", 0

.str_invalid_label:
	db "Invalid label name", 0

.str_label_name_too_long:
	db "Label name too long", 0

.str_undefined_label:
	db "Undefined label", 0

.str_error_syntax:
	db "Syntax error", 0

.str_unexpected_eof:
	db "Unexpected EOF", 0

.str_error_on_line:
	db "Error on line: ", 0

.str_error_range:
	db "Displacement value out of range", 0

.str_failed_to_write:
	db "Failed to write output", 0

.str_success:
	db "Success", 0

.str_info:
	db "asmcomp source.asm output.bin", 0

.test_program_src:
	db "?D1A881",$A
	db '1804 "FEX" 00',$A
	db "CD :main l",$A
	db "AFED62C9",$A
.test_program_src.len:=$-.test_program_src