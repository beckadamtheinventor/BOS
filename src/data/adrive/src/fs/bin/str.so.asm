
; shared string related code

_osrt_str_so:
	dd 1
	jp osrt.substring
	jp osrt.duplicate_string
	jp osrt.subsection_mem
	jp osrt.duplicate_mem
	jp osrt.sreadline
	jp osrt.sreadlineuntil
	jp osrt.sreaduntil
	jp osrt.sreadidentifier

virtual
	db "osrt.substring        rb 4",$A
	db "osrt.duplicate_string rb 4",$A
	db "osrt.subsection_mem   rb 4",$A
	db "osrt.duplicate_mem    rb 4",$A
	db "osrt.sreadline         rb 4",$A
	db "osrt.sreadlineuntil    rb 4",$A
	db "osrt.sreaduntil        rb 4",$A
	db "osrt.sreadidentifier   rb 4",$A
	load _routines_osrt_str_so: $-$$ from $$
end virtual

; char *sreadidentifier(const char *src, const size_t offset, const size_t len);
osrt.sreadidentifier:
	call ti._frameset0
	ld de,(ix+9)
	ld hl,(ix+12)
	or a,a
	sbc hl,de ; len - offset
	jr c,osrt.sreadline.fail
	push hl
	pop bc
	ld hl,(ix+6)
	add hl,de ; src + offset
	push hl
	jr osrt.sreadidentifier.loop.entry
osrt.sreadidentifier.loop:
	ld a,(hl)
	sub a,'0'
	cp a,10
	jr nc,osrt.sreadidentifier.done
osrt.sreadidentifier.loop.entry:
	ld a,(hl)
	cp a,'_'
	jr z,osrt.sreadidentifier.loop.next
	sub a,'A'
	cp a,26
	jr c,osrt.sreadidentifier.loop.next
	sub a,$20
	cp a,26
	jr nc,osrt.sreadidentifier.done
osrt.sreadidentifier.loop.next:
	cpi
	jp pe,osrt.sreadidentifier.loop
osrt.sreadidentifier.done:
	pop de
	or a,a
	sbc hl,de ; end - start
	jr z,osrt.sreadline.line_len_0
	inc hl ; +1 for null terminator
	push de
	jr osrt.malloc_and_return_ldir_string

; char *readlineuntil(const char *src, const size_t offset, const size_t len, char end);
osrt.sreadlineuntil:
	call ti._frameset0
	ld a,(ix+15)
	jr osrt.sreadline.entry_a

; char *readuntil(const char *src, const size_t offset, const size_t len, char end);
osrt.sreaduntil:
	call ti._frameset0
	ld a,(ix+15)
	scf
	jr osrt.sreadline.entry_af

; char *readline(const char *src, const size_t offset, const size_t len);
osrt.sreadline:
	ld a,$A ; newline
osrt.sreadline.entry_a:
	or a,a
osrt.sreadline.entry_af:
	push af
	ld de,(ix+9)
	ld hl,(ix+12)
	or a,a
	sbc hl,de ; len - offset
	jr c,osrt.sreadline.fail
	push hl
	pop bc
	ld hl,(ix+6)
	add hl,de ; src + offset
	pop af
	push hl
	; or a,a
	call osrt.sreadline.entry
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,osrt.sreadline.line_len_0
osrt.malloc_and_return_ldir_string:
	push hl
	call bos.sys_Malloc
	ex hl,de
	pop bc ; length of line
	pop hl ; pointer to start of line
	jr c,osrt.sreadline.fail
osrt.return_ldir_string:
	push de
	ldir
	xor a,a
	ld (de),a
	pop hl
	pop ix
	ret

osrt.sreadline.line_len_0:
	ld hl,$FF0000
	db $01 ; ld bc,... dummify or a / sbc hl
osrt.sreadline.fail:
	or a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret

; if Cf set as input this will check for character in a and newline, otherwise just a
; input hl pointer to data, bc length of data
; returns length of line in hl
osrt.sreadline.entry:
	jr c,osrt.sreadline.entry.check_two
	cpir
	jr osrt.sreadline.entry.exit
osrt.sreadline.entry.check_two:
	ld e,a
	cp a,(hl)
	jr z,osrt.sreadline.entry.exit
	ld a,(hl)
	cp a,e
	jr z,osrt.sreadline.entry.exit
	ld a,e
	cpi
	jp pe,osrt.sreadline.entry.check_two
osrt.sreadline.entry.exit:
	push bc
	pop hl
	ret

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

