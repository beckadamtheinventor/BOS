
; shared string code for os executables

_osrt_str_so:
	dd 1
	jp osrt.substring
	jp osrt.duplicate_string
	jp osrt.subsection_mem
	jp osrt.duplicate_mem

virtual
	db "osrt.substring        rb 4",$A
	db "osrt.duplicate_string rb 4",$A
	db "osrt.subsection_mem   rb 4",$A
	db "osrt.duplicate_mem    rb 4",$A
	load _routines_osrt_str_so: $-$$ from $$
end virtual

; char *substring(const char *str, const size_t start, const size_t length);
; output copied substring or 0 if start+length > strlen(str) or if malloc failed.
osrt.substring:
	call ti._frameset0
	ld hl,(ix+6) ; str
	push hl
	call ti._strlen
	ex hl,de
	ld bc,(ix+12) ; length
	ld hl,(ix+9) ; start
	add hl,bc
	or a,a
	sbc hl,de
	add hl,de
	pop de
	jr nc,osrt.substring.fail
	add hl,de
osrt.malloc_bc_and_copy_from_hl:
	push hl,bc
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	jr c,osrt.substring.fail
	push de
	ldir
	pop hl
	db $01 ; dummify or a,a / sbc hl,hl
osrt.substring.fail:
	or a,a
	sbc hl,hl
	pop ix
	ret

; void *duplicate_mem(const void *mem, const size_t len);
; output duplicated memory or 0 if malloc failed.
osrt.duplicate_mem:
	call ti._frameset0
	ld hl,(ix+6)
	ld bc,(ix+9)
	jr osrt.malloc_bc_and_copy_from_hl

; void *subsection_mem(const void *mem, const size_t start, const size_t length);
; output copied subsection or 0 if malloc failed.
osrt.subsection_mem:
	call ti._frameset0
	ld hl,(ix+6)
	ld bc,(ix+9)
	add hl,bc
	ld bc,(ix+12)
	jr osrt.malloc_bc_and_copy_from_hl

; char *duplicate_string(const char *str);
; output copied substring or 0 if malloc failed.
osrt.duplicate_string:
	ld hl,6
	add hl,sp
	ld hl,(hl)
	push hl
	call ti._strlen
	push hl
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	jr c,osrt.duplicate_string.fail
	push de
	ldir
	pop hl
	ret
osrt.duplicate_string.fail:
	or a,a
	sbc hl,hl
	ret

