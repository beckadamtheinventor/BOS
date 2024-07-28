include "../src/include/ez80.inc"
include "../src/include/ti84pceg.inc"
include "../bos.inc"
syscalllib "str"

; Exports must follow code labels otherwise this doesn't build for some reason

str_readid:
	call ti._frameset0
	ld de,(ix+9)
	ld hl,(ix+12)
	or a,a
	sbc hl,de ; len - offset
	jr c,str_readline.fail
	push hl
	pop bc
	ld hl,(ix+6)
	add hl,de ; src + offset
	push hl
	jr .loop.entry
.loop:
	ld a,(hl)
	sub a,'0'
	cp a,10
	jr nc,.done
.loop.entry:
	ld a,(hl)
	cp a,'_'
	jr z,.loop.next
	sub a,'A'
	cp a,26
	jr c,.loop.next
	sub a,$20
	cp a,26
	jr nc,.done
.loop.next:
	cpi
	jp pe,.loop
.done:
	pop de
	or a,a
	sbc hl,de ; end - start
	jr z,str_readline.line_len_0
	inc hl ; +1 for null terminator
	push de
	jr internal.malloc_and_return_ldir_string

str_readlineuntil:
	call ti._frameset0
	ld a,(ix+15)
	jr str_readline.entry_a

str_readuntil:
	call ti._frameset0
	ld a,(ix+15)
	scf
	jr str_readline.entry_af

str_readline:
	ld a,$A ; newline
.entry_a:
	or a,a
.entry_af:
	push af
	ld de,(ix+9)
	ld hl,(ix+12)
	or a,a
	sbc hl,de ; len - offset
	jr c,.fail
	push hl
	pop bc
	ld hl,(ix+6)
	add hl,de ; src + offset
	pop af
	push hl
	; or a,a
	call .entry
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.line_len_0
internal.malloc_and_return_ldir_string:=$
	push hl
	call bos.sys_Malloc
	ex hl,de
	pop bc ; length of line
	pop hl ; pointer to start of line
	jr c,.fail
util.return_ldir_string:=$
	push de
	ldir
	xor a,a
	ld (de),a
	pop hl
	pop ix
	ret

.line_len_0:
	ld hl,$FF0000
	db $01 ; ld bc,... dummify or a / sbc hl
.fail:
	or a,a
	sbc hl,hl
	ld sp,ix
	pop ix
	ret

; if Cf set as input this will check for character in a and newline, otherwise just a
; input hl pointer to data, bc length of data
; returns length of line in hl
.entry:
	jr c,.entry.check_two
	cpir
	jr .entry.exit
.entry.check_two:
	ld e,a
	cp a,(hl)
	jr z,.entry.exit
	ld a,(hl)
	cp a,e
	jr z,.entry.exit
	ld a,e
	cpi
	jp pe,.entry.check_two
.entry.exit:
	push bc
	pop hl
	ret

str_sub:
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
	jr nc,.fail
	add hl,de
util.malloc_bc_and_copy_from_hl:=$
	push hl,bc
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	jr c,.fail
	push de
	ldir
	pop hl
	db $01 ; dummify or a,a / sbc hl,hl
.fail:
	or a,a
	sbc hl,hl
	pop ix
	ret

mem_dup:
	call ti._frameset0
	ld hl,(ix+6)
	ld bc,(ix+9)
	jr util.malloc_bc_and_copy_from_hl


str_dup:
	ld hl,6
	add hl,sp
	ld hl,(hl)
	push hl
	call ti._strlen
	push hl
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	jr c,.fail
	push de
	ldir
	pop hl
	ret
.fail:
	or a,a
	sbc hl,hl
	ret

export str_sub, "sub", "strsub", "// output copied substring or 0 if start+length > strlen(str) or if malloc failed.",$A,"char *strsub(const char *str, const size_t start, const size_t length);"
export str_dup, "dup", "strdup", "// output copied substring or 0 if malloc failed.",$A,"char *strdup(const char *str);"
export mem_dup, "mdup", "memdup", "// Malloc a copy of len bytes at mem. Returns 0 if failed.",$A,"void *memdup(const void *mem, const size_t len);"
export str_readline, "rdln", "str_readline", "char *str_readline(const char *src, const size_t offset, const size_t len);"
export str_readuntil, "rdun", "str_readuntil", "char *str_readuntil(const char *src, const size_t offset, const size_t len, char end);"
export str_readlineuntil, "rdlnun", "str_readlineuntil", "char *str_readlineuntil(const char *src, const size_t offset, const size_t len, char end);"
export str_readid, "rdid", "str_readid", "char *str_readid(const char *src, const size_t offset, const size_t len);"

end syscalllib