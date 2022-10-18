	; assume	adl=1

	; section	.text
	; public	_zx0_Decompress
; _zx0_Decompress:
util_Zx0DecompressToFlash:
	pop	bc
	pop	de
	ex	(sp), hl
	push	de
	push	bc
	push bc
	ld iy,0
	add iy,sp
	call ._turbo
	pop bc
	ex hl,de
	ret

; -----------------------------------------------------------------------------
; ZX0 decoder by Einar Saukas & introspec
; "Turbo" version
; edited by Adam Beckingham to run from flash memory and write to flash memory
; -----------------------------------------------------------------------------

._turbo:
	ld	bc, -1		; preserve default offset 1
	ld	(iy), bc
	inc	bc
	ld	a, $80
	jr	.t_literals
.t_new_offset:
	dec	bc
	dec	bc		; prepare negative offset
	add	a, a
	jr	nz, .t_new_offset_skip
	ld	a, (hl)		; load another group of 8 bits
	inc	hl
	rla
.t_new_offset_skip:
	call	nc, .t_elias	; obtain offset MSB
	inc	c
	ret	z		; check end marker
	ld	b, c
	ld	c, (hl)		; obtain offset LSB
	inc	hl
	rr	b		; last offset bit becomes first length bit
	rr	c
	ld	(iy), bc ; preserve new offset
	ld	bc, 1		; obtain length
	call	nc, .t_elias
	inc	bc
.t_copy:
	push	hl		; preserve source
	ld	hl, (iy)	; restore offset
	add	hl, de		; calculate destination - offset
	; ldir			; copy from offset
	push	bc,af,de
	call	sys_WriteFlash
	pop	de,af,bc
	pop	hl		; restore source
	add	a, a		; copy from literals or new offset?
	jr	c, .t_new_offset
.t_literals:
	inc	c		; obtain length
	add	a, a
	jr	nz, .t_literals_skip
	ld	a, (hl)		; load another group of 8 bits
	inc	hl
	rla
.t_literals_skip:
	call	nc, .t_elias
	; ldir			; copy literals
	push	hl,bc,af,de
	call	sys_WriteFlash
	pop	de,af,bc,hl

	add	a, a		; copy from last offset or new offset?
	jr	c, .t_new_offset
	inc	c		; obtain length
	add	a, a
	jr	nz, .t_last_offset_skip
	ld	a, (hl)		; load another group of 8 bits
	inc	hl
	rla
.t_last_offset_skip:
	call	nc, .t_elias
	jr	.t_copy
.t_elias:
	add	a, a		; interlaced Elias gamma coding
	rl	c
	add	a, a
	jr	nc, .t_elias
	ret	nz
	ld	a, (hl)		; load another group of 8 bits
	inc	hl
	rla
	ret	c
	add	a, a
	rl	c
	add	a, a
	ret	c
	add	a, a
	rl	c
	add	a, a
	ret	c
	add	a, a
	rl	c
	add	a, a
	ret	c
.t_elias_loop:
	add	a, a
	rl	c
	rl	b
	add	a, a
	jr	nc, .t_elias_loop
	ret	nz
	ld	a, (hl)		 ; load another group of 8 bits
	inc	hl
	rla
	jr	nc, .t_elias_loop
	ret
