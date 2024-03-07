
	jr _bomasm_main
	db "FEX", 0
_bomasm_main:
	ld (.savesp),sp
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
	; zero temp space
	ld hl,.bss
	push hl
	pop de
	inc de
	ld (hl),0
	ld bc,.bss.len
	ldir
	call osrt.argv_1

.exit0:
	or a,a
	sbc hl,hl
.exithl:
	ld sp,(.savesp)
	pop ix
	ret
.exit1:
	ld hl,1
	jr .exithl

; void assemble(char *src, size_t len)
.assemble:
	ld hl,-6
	call ti._frameset
	; init local symtbl
	or a,a
	sbc hl,hl
	ld (ix-3),hl
	ld (ix-6),hl
	ld (.srcoffset),hl
	ld hl,(ix+6)
	ld (.src),hl
	ld hl,(ix+9)
	ld (.srclen),hl
.assemble_loop:
	call .peekchar
	call .isidentifier
	jr c,.not_identifier
	call .readidentifier
	
.not_identifier:
	
	jr .assemble_loop
	
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
.peekchar:
	ld hl,(.src)
	ld bc,(.srcoffset)
	add hl,bc
	ld a,(hl)
	ret

; char *readidentifier(void)
.readidentifier:
	ld hl,(.srclen)
	push hl
	ld hl,(.srcoffset)
	push hl
	ld hl,(.src)
	push hl
	call osrt.sreadidentifier
	pop bc,bc,bc
	add hl,bc
	xor a,a
	sbc hl,bc
	jr z,.error_invalid_identifier ; fail if str == 0
	or a,(hl)
	ret nz
	; also fail if str[0] == 0

.error_invalid_identifier:
	ld hl,.str_error_invalid_identifier
.error_print_and_return:
	call bos.gui_PrintLine
	jq .exit1

.str_error_invalid_identifier:
	db "Invalid identifier", 0

.str_info:
	db "bomasm src.asm bin", 0

virtual at ti.pixelShadow
	.savesp    rb 3
	.bss:
	.globals   rb 6
	.src       rb 3
	.srclen    rb 3
	.srcoffset rb 3
	.bss.len:
end virtual
