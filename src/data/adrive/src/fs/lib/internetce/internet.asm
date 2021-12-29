
include '../include/ez80.inc'
include '../include/ti84pceg.inc'
include '../include/bos.inc'

virtual
	_libraryexports::
end virtual

virtual as "lib"
	_librarytbl::
end virtual

macro public? symbol
	virtual _libraryexports
		jp symbol
	end virtual
	virtual _librarytbl
		db "symbol rb 4",$A
	end virtual
end macro

virtual at $060000

; *******************************************
; * Author: Epharius						*
; *	Miscellaneous assembly stuffs 			*
; * You can reuse this code as you wish		*
; *******************************************

_MoveToArc:
	call ti._frameset0
	ld hl,(ix+6)
	dec hl
	call ti.Mov9ToOP1
	ld a,ti.AppVarObj
	ld (ti.OP1),a
	call ti.OP1ToOP4
	call ti.ChkFindSym
	ld hl,0
	pop ix
	ret c
	call ti.ChkInRam
	ret nz
	call ti.Arc_Unarc
	call ti.OP4ToOP1
	call ti.ChkFindSym
	ex de,hl
	ret


_MoveToRam:
	call ti._frameset0
	ld hl,(ix+6)
	dec hl
	call ti.Mov9ToOP1
	ld a,ti.AppVarObj
	ld (ti.OP1),a
	call ti.OP1ToOP4
	call ti.ChkFindSym
	ld hl,0
	pop ix
	ret c
	call ti.ChkInRam
	ret z
	call ti.Arc_Unarc
	call ti.OP4ToOP1
	call ti.ChkFindSym
	ex de,hl
	ret


_os_EnoughMem:
	pop de
	pop hl
	push hl
	push de
	call ti.EnoughMem
	ld hl,0
	ret c
	inc hl
	ret


_os_DelVarArc:
	call ti._frameset0
	ld a,(ix+6)
	ld hl,(ix+9)
	ld (ti.OP1),a
	ld de,ti.OP1+1
	call ti.Mov8b
	call ti.ChkFindSym
	pop ix
	jr c,.err_not_found
	call ti.DelVarArc
	ld hl,1
	ret
.err_not_found:
	or a
	sbc hl,hl
	ret

_ResizeAppVar:
	; @warning	The AppVar must reside in RAM
	; @return	1 if the resizing happened, 0 if not
	; @note		This code can easily be used for other types of variable by replacing ld a,AppVarObj by ld a,whatyouwant
	call ti._frameset0
	ld a,ti.AppVarObj
	ld (ti.OP1),a
	ld hl,(ix+6)
	ld de,ti.OP1+1
	ld bc,9
	ldir
	call ti.ChkFindSym
	ld hl,0
	jq c,.quit ; return 0
	call ti.ChkInRam
	jq nz,.quit ; return 0
	ex de,hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ld c,(ix+9) ; BCU is already 0
	ld b,(ix+10)
	ld (hl),b
	dec hl
	ld (hl),c
	push de
	ex de,hl
	or a
	sbc hl,bc
	pop ix
	jr z,.quit ; return 0
	push ix
	jq nc,.shrinkSize

	push de
	ex de,hl
	or a
	sbc hl,hl
	sbc hl,de
	ex de,hl
	pop hl
	pop bc
	add hl,bc
	ex de,hl
	call ti.InsertMem
	ld hl,1
	pop ix
	ret ; return 1

.shrinkSize:
	ex de,hl
	add hl,bc
	inc hl
	inc hl
	call ti.DelMem
	pop de ; reset stack
	ld hl,1

.quit:
	pop ix
	ret



; compiled from internet.c using ez80-clang

	public	_web_HTTPGet
_web_HTTPGet:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -8
	add	hl, sp
	ld	sp, hl
	ld	bc, (ix + 6)
	ld	hl, (ix + 9)
	ld	a, (ix + 12)
	ld	iy, L_.str
	lea	de, ix - 8
	ld	(ix - 3), bc
	ld	(ix - 6), hl
	and	a, 1
	ld	(ix - 7), a
	ld	(ix - 8), 0
	ld	hl, (ix - 3)
	ld	bc, (ix - 6)
	ld	a, (ix - 7)
	push	de
	ld	e, a
	push	de
	push	bc
	push	hl
	push	iy
	call	_http_request
	ld	iy, 23
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_http_request
_http_request:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -55
	add	hl, sp
	ld	sp, hl
	ld	bc, (ix + 6)
	ld	de, (ix + 12)
	ld	a, (ix + 15)
	ld	iy, 7
	lea	hl, ix - 37
	ld	(ix - 49), hl
	ld	(ix - 6), bc
	ld	hl, (ix + 9)
	ld	(ix - 9), hl
	ld	(ix - 12), de
	and	a, 1
	ld	(ix - 13), a
	ld	hl, (ix + 18)
	ld	(ix - 16), hl
	ld	hl, L_.str.5
	ld	(ix - 20), hl
	ld	hl, (ix - 9)
	ld	de, (ix - 20)
	push	iy
	push	de
	push	hl
	call	_memcmp
	ld	iy, 9
	add	iy, sp
	ld	sp, iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB1_2
	jq	BB1_1
BB1_1:
	ld	iy, (ix - 9)
	lea	hl, iy + 7
	ld	(ix - 9), hl
	jq	BB1_2
BB1_2:
	or	a, a
	sbc	hl, hl
	ld	(ix - 23), hl
	ld	c, 0
	jq	BB1_3
BB1_3:
	ld	hl, (ix - 9)
	ld	de, (ix - 23)
	add	hl, de
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	de, 47
	or	a, a
	sbc	hl, de
	ld	a, c
	jq	z, BB1_7
	jq	BB1_4
BB1_4:
	ld	hl, (ix - 9)
	ld	de, (ix - 23)
	add	hl, de
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, 1
	ld	l, 0
	jq	nz, BB1_6
	ld	a, l
BB1_6:
	jq	BB1_7
BB1_7:
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB1_9
	jq	BB1_8
BB1_8:
	ld	hl, (ix - 23)
	inc	hl
	ld	(ix - 23), hl
	jq	BB1_3
BB1_9:
	ld	hl, (ix - 9)
	ld	de, (ix - 23)
	add	hl, de
	ld	a, (hl)
	or	a, a
	ld	a, 1
	ld	l, 0
	jq	nz, BB1_11
	ld	a, l
BB1_11:
	and	a, 1
	ld	(ix - 17), a
	ld	hl, (ix - 23)
	inc	hl
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 26), hl
	ld	hl, (ix - 26)
	ld	de, (ix - 9)
	ld	bc, (ix - 23)
	push	bc
	push	de
	push	hl
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 26)
	ld	de, (ix - 23)
	add	hl, de
	ld	(hl), 0
	ld	hl, (ix - 26)
	push	hl
	call	_web_SendDNSRequest
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 30), hl
	ld	(ix - 27), e
	ld	hl, 62
	push	hl
	ld	hl, 1
	push	hl
	call	_calloc
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 33), hl
	ld	hl, (ix - 30)
	ld	a, (ix - 27)
	ld	iy, (ix - 33)
	ld	(iy), hl
	ld	(iy + 3), a
	ld	iy, (ix - 33)
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	bc, -1
	ld	a, -1
	call	__lcmpu
	jq	nz, BB1_13
	jq	BB1_12
BB1_12:
	ld	hl, 10
	ld	(ix - 3), hl
	jq	BB1_25
BB1_13:
	call	_web_RequestPort
	ld	iy, (ix - 33)
	ld	(iy + 4), l
	ld	(iy + 5), h
	ld	iy, (ix - 33)
	ld.sis	hl, 80
	ld	(iy + 6), l
	ld	(iy + 7), h
	call	_random
	ld	iy, (ix - 33)
	ld	(iy + 14), hl
	ld	(iy + 17), e
	ld	iy, (ix - 33)
	ld	hl, (iy + 14)
	ld	a, (iy + 17)
	ld	iy, (ix - 33)
	ld	(iy + 22), hl
	ld	(iy + 25), a
	ld	iy, (ix - 33)
	ld	hl, -1
	ld	(iy + 44), hl
	ld	hl, (ix - 12)
	ld	iy, (ix - 33)
	ld	(iy + 55), hl
	ld	iy, (ix - 33)
	ld	a, (ix - 13)
	and	a, 1
	ld	(iy + 58), a
	ld	hl, -851900
	push	hl
	pop	iy
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	bc, 7
	xor	a, a
	call	__ladd
	ld	iy, (ix - 33)
	ld	(iy + 10), hl
	ld	(iy + 13), e
	ld	iy, (ix - 33)
	ld	hl, (iy + 4)
	ld	de, (ix - 33)
	push	de
	ld	de, _fetch_http_msg
	push	de
	push	hl
	call	_web_ListenPort
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	de, (ix - 49)
	ld	hl, L___const.http_request.options
	ld	iy, 4
	lea	bc, iy
	ldir
	ld	hl, (ix - 33)
	ld	de, (ix - 49)
	push	de
	push	iy
	ld	de, 2
	push	de
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 0
	push	hl
	call	_add_tcp_queue
	ld	hl, 18
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 33)
	ld	hl, (iy + 14)
	ld	e, (iy + 17)
	ld	bc, 1
	xor	a, a
	call	__ladd
	ld	(iy + 14), hl
	ld	(iy + 17), e
	ld	e, 1
	ld	l, e
	jq	BB1_14
BB1_14:
	ld	iy, (ix - 33)
	ld	a, (iy + 8)
	xor	a, l
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB1_16
	jq	BB1_15
BB1_15:
	call	_web_WaitForEvents
	ld	e, 1
	ld	l, e
	jq	BB1_14
BB1_16:
	call	_web_WaitForEvents
	ld	hl, (ix - 6)
	push	hl
	call	_strlen
	push	hl
	pop	de
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	inc	de
	ld	a, (ix - 17)
	ld	l, 1
	xor	a, l
	ld	l, a
	ld	bc, 1
	call	__iand
	push	hl
	pop	bc
	ex	de, hl
	add	hl, bc
	ld	de, 11
	add	hl, de
	ld	de, 6
	add	hl, de
	ld	(ix - 55), hl
	ld	hl, (ix - 9)
	push	hl
	call	_strlen
	push	hl
	pop	de
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 55)
	add	hl, de
	ld	de, 4
	add	hl, de
	ld	(ix - 55), hl
	ld	hl, (ix - 16)
	push	hl
	call	_strlen
	push	hl
	pop	de
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 55)
	add	hl, de
	ld	(ix - 40), hl
	ld	hl, (ix - 40)
	inc	hl
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 43), hl
	ld	de, (ix - 43)
	ld	hl, (ix - 6)
	ld	c, 1
	ld	a, (ix - 17)
	xor	a, c
	bit	0, a
	ld	(ix - 52), hl
	jq	nz, BB1_18
	jq	BB1_17
BB1_17:
	ld	iy, (ix - 9)
	ld	bc, (ix - 23)
	add	iy, bc
	jq	BB1_19
BB1_18:
	ld	iy, L_.str.7
	jq	BB1_19
BB1_19:
	ld	bc, (ix - 26)
	ld	hl, (ix - 16)
	push	hl
	push	bc
	push	iy
	ld	hl, (ix - 52)
	push	hl
	ld	hl, L_.str.6
	push	hl
	push	de
	call	___sprintf
	ld	hl, 18
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 26)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 43)
	ld	de, (ix - 40)
	ld	bc, (ix - 33)
	ld	hl, 0
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, 24
	push	hl
	push	bc
	push	de
	push	iy
	call	_add_tcp_queue
	ld	hl, 18
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 43)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	jq	BB1_20
BB1_20:
	ld	iy, (ix - 33)
	ld	hl, (iy + 59)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB1_24
	jq	BB1_21
BB1_21:
	call	_web_WaitForEvents
	ld	iy, (ix - 33)
	ld	bc, (iy + 10)
	ld	a, (iy + 13)
	ld	hl, -851900
	push	hl
	pop	iy
	ld	hl, (iy)
	ld	e, (iy + 3)
	call	__lcmpu
	jq	c, BB1_23
	jq	BB1_22
BB1_22:
	ld	iy, (ix - 33)
	ld	hl, (iy + 4)
	push	hl
	call	_web_UnlistenPort
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 33)
	push	hl
	call	_wipe_data
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 33)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, 9
	ld	(ix - 3), hl
	jq	BB1_25
BB1_23:
	jq	BB1_20
BB1_24:
	ld	iy, (ix - 33)
	ld	hl, (iy + 59)
	ld	(ix - 46), hl
	ld	hl, (ix - 33)
	ld	de, 0
	push	de
	pop	iy
	push	iy
	ld	de, 0
	push	de
	pop	bc
	push	bc
	ld	de, 17
	push	de
	push	hl
	push	bc
	push	iy
	call	_add_tcp_queue
	ld	hl, 18
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 33)
	ld	(iy + 9), 1
	call	_web_WaitForEvents
	ld	hl, (ix - 46)
	ld	(ix - 3), hl
	jq	BB1_25
BB1_25:
	ld	hl, (ix - 3)
	ld	iy, 55
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_HTTPPost
_web_HTTPPost:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -51
	add	hl, sp
	ld	sp, hl
	ld	bc, (ix + 6)
	ld	hl, (ix + 9)
	ld	a, (ix + 12)
	ld	iy, L_.str.1
	lea	de, ix - 14
	ld	(ix - 6), bc
	ld	(ix - 9), hl
	and	a, 1
	ld	(ix - 10), a
	ld	hl, (ix + 15)
	ld	(ix - 13), hl
	ld	hl, (ix - 13)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB2_2
	jq	BB2_1
BB2_1:
	ld	(ix - 14), 0
	ld	hl, (ix - 6)
	ld	bc, (ix - 9)
	ld	a, (ix - 10)
	push	de
	ld	e, a
	push	de
	push	bc
	push	hl
	push	iy
	call	_http_request
	ld	iy, 15
	add	iy, sp
	ld	sp, iy
	ld	(ix - 3), hl
	jq	BB2_12
BB2_2:
	or	a, a
	sbc	hl, hl
	ld	(ix - 17), hl
	ld	hl, 1
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 20), hl
	lea	hl, ix + 18
	ld	(ix - 23), hl
	ld	(ix - 24), 0
	ld	bc, 16
	jq	BB2_3
BB2_3:
	or	a, a
	sbc	hl, hl
	ld	l, (ix - 24)
	ld	iy, (ix - 13)
	add	iy, iy
	ld	de, -8388608
	add	iy, de
	add	hl, de
	lea	de, iy
	or	a, a
	sbc	hl, de
	jq	nc, BB2_11
	jq	BB2_4
BB2_4:
	ld	iy, (ix - 23)
	lea	hl, iy + 3
	ld	(ix - 23), hl
	ld	hl, (iy)
	ld	(ix - 27), hl
	ld	iy, (ix - 23)
	lea	hl, iy + 3
	ld	(ix - 23), hl
	ld	hl, (iy)
	ld	(ix - 30), hl
	ld	hl, (ix - 20)
	ld	(ix - 42), hl
	ld	hl, (ix - 17)
	ld	(ix - 45), hl
	ld	hl, (ix - 27)
	push	hl
	call	_strlen
	push	hl
	pop	de
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 45)
	add	hl, de
	ld	(ix - 45), hl
	ld	hl, (ix - 30)
	push	hl
	call	_strlen
	push	hl
	pop	de
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 45)
	add	hl, de
	ld	de, 4
	add	hl, de
	inc	hl
	push	hl
	ld	hl, (ix - 42)
	push	hl
	call	_realloc
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 33), hl
	ld	hl, (ix - 33)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB2_6
	jq	BB2_5
BB2_5:
	ld	hl, (ix - 20)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, -1
	ld	(ix - 3), hl
	jq	BB2_12
BB2_6:
	ld	hl, (ix - 33)
	ld	(ix - 20), hl
	ld	a, (ix - 24)
	or	a, a
	jq	z, BB2_8
	jq	BB2_7
BB2_7:
	ld	hl, (ix - 20)
	ld	de, (ix - 17)
	add	hl, de
	ld	de, (ix - 27)
	ld	bc, (ix - 30)
	push	bc
	push	de
	ld	de, L_.str.2
	push	de
	push	hl
	call	___sprintf
	ld	hl, 12
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 27)
	push	hl
	call	_strlen
	ld	(ix - 48), hl
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 30)
	push	hl
	call	_strlen
	push	hl
	pop	de
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 48)
	add	hl, de
	ld	de, 2
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 17)
	add	hl, de
	ld	(ix - 17), hl
	jq	BB2_9
BB2_8:
	ld	hl, (ix - 20)
	ld	de, (ix - 17)
	add	hl, de
	ld	de, (ix - 27)
	ld	bc, (ix - 30)
	push	bc
	push	de
	ld	de, L_.str.3
	push	de
	push	hl
	call	___sprintf
	ld	hl, 12
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 27)
	push	hl
	call	_strlen
	ld	(ix - 51), hl
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 30)
	push	hl
	call	_strlen
	push	hl
	pop	de
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 51)
	add	hl, de
	ex	de, hl
	inc	de
	ld	hl, (ix - 17)
	add	hl, de
	ld	(ix - 17), hl
	jq	BB2_9
BB2_9:
	jq	BB2_10
BB2_10:
	ld	a, (ix - 24)
	add	a, 2
	ld	(ix - 24), a
	ld	bc, 16
	jq	BB2_3
BB2_11:
	ld	hl, (ix - 17)
	add	hl, bc
	ld	de, 12
	add	hl, de
	ld	de, 49
	add	hl, de
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 36), hl
	ld	hl, (ix - 36)
	ld	de, (ix - 17)
	ld	bc, (ix - 20)
	push	bc
	push	de
	ld	de, L_.str.4
	push	de
	push	hl
	call	___sprintf
	ld	hl, 12
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 6)
	ld	de, (ix - 9)
	ld	a, (ix - 10)
	ld	bc, (ix - 36)
	push	bc
	ld	c, a
	push	bc
	push	de
	push	hl
	ld	hl, L_.str.1
	push	hl
	call	_http_request
	ld	iy, 15
	add	iy, sp
	ld	sp, iy
	ld	(ix - 39), hl
	ld	hl, (ix - 20)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 36)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 39)
	ld	(ix - 3), hl
	jq	BB2_12
BB2_12:
	ld	hl, (ix - 3)
	ld	iy, 51
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_UnlockData
_web_UnlockData:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -39
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	lea	de, ix - 12
	ld	(ix - 33), de
	lea	de, ix - 21
	ld	(ix - 30), de
	lea	de, ix - 24
	ld	(ix - 36), de
	ld	(ix - 6), hl
	ld	hl, (ix - 6)
	ld	hl, (hl)
	ld	hl, (hl)
	ld	de, 0
	ld	e, l
	ld	d, h
	push	de
	call	_os_EnoughMem
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	bit	0, a
	jq	nz, BB3_2
	jq	BB3_1
BB3_1:
	or	a, a
	sbc	hl, hl
	ld	(ix - 3), hl
	jq	BB3_14
BB3_2:
	call	_os_GetSymTablePtr
	ld	(ix - 9), hl
	ld	de, 0
	ld	(ix - 24), de
	ld	iy, (ix - 30)
	xor	a, a
	ld	bc, (ix - 33)
	jq	BB3_3
BB3_3:
	ld	hl, (ix - 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB3_7
	jq	BB3_4
BB3_4:
	ld	hl, (ix - 6)
	ld	de, (ix - 24)
	ld	hl, (hl)
	or	a, a
	sbc	hl, de
	ld	a, 1
	ld	l, 0
	jq	nz, BB3_6
	ld	a, l
BB3_6:
	ld	de, 0
	jq	BB3_7
BB3_7:
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB3_9
	jq	BB3_8
BB3_8:
	ld	hl, (ix - 9)
	ld	(ix - 39), hl
	ld	hl, (ix - 36)
	push	hl
	push	iy
	push	de
	push	bc
	ld	hl, (ix - 39)
	push	hl
	call	_os_NextSymEntry
	ld	de, 0
	ld	bc, (ix - 33)
	ld	iy, 15
	add	iy, sp
	ld	sp, iy
	xor	a, a
	ld	iy, (ix - 30)
	ld	(ix - 9), hl
	jq	BB3_3
BB3_9:
	ld	hl, (ix - 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB3_11
	jq	BB3_10
BB3_10:
	or	a, a
	sbc	hl, hl
	ld	(ix - 3), hl
	jq	BB3_14
BB3_11:
	push	iy
	call	_MoveToRam
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 27), hl
	ld	hl, (ix - 27)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB3_13
	jq	BB3_12
BB3_12:
	ld	de, (ix - 27)
	ld	hl, (ix - 6)
	ld	(hl), de
	jq	BB3_13
BB3_13:
	ld	hl, 1
	ld	(ix - 3), hl
	jq	BB3_14
BB3_14:
	ld	hl, (ix - 3)
	ld	iy, 39
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_LockData
_web_LockData:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -30
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	lea	de, ix - 18
	ld	(ix - 27), de
	lea	de, ix - 21
	ld	(ix - 30), de
	ld	(ix - 6), hl
	ld	iy, -3145600
	call	_os_ArcChk
	ld	hl, (ix - 6)
	ld	hl, (hl)
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	iy, -3135915
	ld	de, (iy)
	or	a, a
	sbc	hl, de
	jq	c, BB4_2
	jq	BB4_1
BB4_1:
	or	a, a
	sbc	hl, hl
	ld	(ix - 3), hl
	jq	BB4_14
BB4_2:
	call	_os_GetSymTablePtr
	ld	(ix - 9), hl
	ld	hl, 0
	ld	(ix - 21), hl
	jq	BB4_3
BB4_3:
	ld	hl, (ix - 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, 0
	ld	bc, 0
	jq	z, BB4_7
	jq	BB4_4
BB4_4:
	ld	hl, (ix - 6)
	ld	de, (ix - 21)
	ld	hl, (hl)
	or	a, a
	sbc	hl, de
	ld	a, 1
	ld	l, 0
	jq	nz, BB4_6
	ld	a, l
BB4_6:
	jq	BB4_7
BB4_7:
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB4_9
	jq	BB4_8
BB4_8:
	ld	hl, (ix - 9)
	ld	de, (ix - 30)
	push	de
	ld	de, (ix - 27)
	push	de
	ld	de, 0
	push	de
	push	de
	push	hl
	call	_os_NextSymEntry
	ld	iy, 15
	add	iy, sp
	ld	sp, iy
	ld	(ix - 9), hl
	jq	BB4_3
BB4_9:
	ld	hl, (ix - 6)
	ld	de, (ix - 21)
	ld	hl, (hl)
	or	a, a
	sbc	hl, de
	jq	z, BB4_11
	jq	BB4_10
BB4_10:
	ld	(ix - 3), bc
	jq	BB4_14
BB4_11:
	ld	hl, (ix - 27)
	push	hl
	call	_MoveToArc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 24), hl
	ld	hl, (ix - 24)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB4_13
	jq	BB4_12
BB4_12:
	ld	iy, (ix - 24)
	lea	de, iy + 18
	ld	hl, (ix - 6)
	ld	(hl), de
	jq	BB4_13
BB4_13:
	ld	hl, 1
	ld	(ix - 3), hl
	jq	BB4_14
BB4_14:
	ld	hl, (ix - 3)
	ld	iy, 30
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_Cleanup
_web_Cleanup:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -18
	add	hl, sp
	ld	sp, hl
	ld	de, 0
	ld	hl, (_listened_ports)
	ld	(ix - 3), hl
	ld	(ix - 6), de
	jq	BB5_1
BB5_1:
	ld	hl, (ix - 3)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB5_3
	jq	BB5_2
BB5_2:
	ld	iy, (ix - 3)
	ld	hl, (iy + 8)
	ld	(ix - 6), hl
	ld	hl, (ix - 3)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 6)
	ld	(ix - 3), hl
	jq	BB5_1
BB5_3:
	ld	hl, (_send_queue)
	ld	(ix - 9), hl
	ld	hl, 0
	ld	(ix - 12), hl
	jq	BB5_4
BB5_4:
	ld	hl, (ix - 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB5_6
	jq	BB5_5
BB5_5:
	ld	iy, (ix - 9)
	ld	hl, (iy + 19)
	ld	(ix - 12), hl
	ld	hl, (ix - 9)
	push	hl
	call	_web_popMessage
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 12)
	ld	(ix - 9), hl
	jq	BB5_4
BB5_6:
	ld	hl, (_http_data_list)
	ld	(ix - 15), hl
	ld	hl, 0
	ld	(ix - 18), hl
	jq	BB5_7
BB5_7:
	ld	hl, (ix - 15)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB5_9
	jq	BB5_8
BB5_8:
	ld	iy, (ix - 15)
	ld	hl, (iy + 9)
	ld	(ix - 18), hl
	ld	hl, (ix - 15)
	push	hl
	ld	hl, 21
	push	hl
	call	_os_DelVarArc
	ld	hl, 6
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 15)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 18)
	ld	(ix - 15), hl
	jq	BB5_7
BB5_9:
	call	_usb_Cleanup
	ld	hl, 18
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_popMessage
_web_popMessage:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, 0
	ld	(ix - 3), hl
	ld	iy, (ix - 3)
	ld	hl, (iy + 22)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB6_2
	jq	BB6_1
BB6_1:
	ld	iy, (ix - 3)
	ld	hl, (iy + 19)
	ld	iy, (ix - 3)
	ld	iy, (iy + 22)
	ld	(iy + 19), hl
	jq	BB6_3
BB6_2:
	ld	iy, (ix - 3)
	ld	hl, (iy + 19)
	ld	(_send_queue), hl
	jq	BB6_3
BB6_3:
	ld	iy, (ix - 3)
	ld	hl, (iy + 19)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB6_5
	jq	BB6_4
BB6_4:
	ld	iy, (ix - 3)
	ld	iy, (iy + 19)
	ld	(iy + 22), de
	jq	BB6_5
BB6_5:
	ld	iy, (ix - 3)
	ld	hl, (iy + 3)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 3)
	push	hl
	call	_free
	ld	hl, 6
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_SendARPQuery
_web_SendARPQuery:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -10
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	a, (ix + 9)
	ld	de, 1
	ld	bc, 42
	ld	(ix - 4), hl
	ld	(ix - 1), a
	push	bc
	push	de
	call	_calloc
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 7), hl
	ld	iy, (ix - 7)
	lea	hl, iy + 14
	ld	(ix - 10), hl
	ld	hl, (ix - 7)
	ld	(hl), -1
	push	hl
	pop	iy
	inc	iy
	ld	bc, 5
	lea	de, iy
	ldir
	ld	iy, (ix - 7)
	lea	de, iy + 6
	ld	hl, _MAC_ADDR
	ld	bc, 6
	ldir
	ld	hl, (ix - 4)
	ld	a, (ix - 1)
	ld	iy, (ix - 10)
	ld	(iy + 24), hl
	ld	(iy + 27), a
	ld	iy, (ix - 10)
	lea	de, iy + 8
	ld	hl, _MAC_ADDR
	ld	bc, 6
	ldir
	ld	hl, (_IP_ADDR)
	ld	a, (_IP_ADDR+3)
	ld	iy, (ix - 10)
	ld	(iy + 14), hl
	ld	(iy + 17), a
	ld	iy, (ix - 10)
	ld.sis	hl, 256
	ld	(iy + 6), l
	ld	(iy + 7), h
	ld	hl, (ix - 10)
	ld	de, 42
	push	de
	push	hl
	call	_web_SendRNDISPacket
	ld	hl, 6
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 7)
	push	hl
	call	_free
	ld	hl, 13
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_SendRNDISPacket
_web_SendRNDISPacket:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -9
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, (ix + 9)
	ld	bc, 44
	ld	(ix - 3), hl
	ld	(ix - 6), de
	ld	de, (ix - 6)
	push	bc
	pop	hl
	add	hl, de
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 9), hl
	ld	hl, (ix - 9)
	ld	(hl), 0
	push	hl
	pop	iy
	inc	iy
	ld	bc, 43
	lea	de, iy
	ldir
	ld	hl, (ix - 9)
	ld	(hl), 1
	ld	l, (ix - 6)
	ld	a, 44
	add	a, l
	ld	iy, (ix - 9)
	ld	(iy + 4), a
	ld	de, (ix - 6)
	ld	hl, 44
	add	hl, de
	ld	bc, 256
	call	__idivu
	ld	a, l
	ld	iy, (ix - 9)
	ld	(iy + 5), a
	ld	iy, (ix - 9)
	ld	(iy + 8), 36
	ld	a, (ix - 6)
	ld	iy, (ix - 9)
	ld	(iy + 12), a
	ld	hl, (ix - 6)
	ld	bc, 256
	call	__idivu
	ld	a, l
	ld	iy, (ix - 9)
	ld	(iy + 13), a
	ld	iy, (ix - 9)
	lea	hl, iy + 44
	ld	de, (ix - 3)
	ld	bc, (ix - 6)
	push	bc
	push	de
	push	hl
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	hl, (_netinfo)
	ld	a, (_netinfo+8)
	ld	e, a
	push	de
	push	hl
	call	_usb_GetDeviceEndpoint
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	de, (ix - 9)
	ld	iy, (ix - 6)
	ld	bc, 44
	add	iy, bc
	ld	bc, (ix - 9)
	push	bc
	ld	bc, _send_rndis_callback
	push	bc
	push	iy
	push	de
	push	hl
	call	_usb_ScheduleTransfer
	ld	iy, 24
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_SendDNSRequest
_web_SendDNSRequest:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -7
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, 0
	xor	a, a
	ld	iy, _dns_callback
	lea	bc, ix - 7
	ld	(ix - 3), hl
	ld	(ix - 7), de
	ld	(ix - 4), a
	ld	hl, (ix - 3)
	push	bc
	push	iy
	push	hl
	call	_web_ScheduleDNSRequest
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	jq	BB9_1
BB9_1:
	ld	hl, (ix - 7)
	ld	e, (ix - 4)
	call	__lcmpzero
	jq	nz, BB9_3
	jq	BB9_2
BB9_2:
	call	_web_WaitForEvents
	jq	BB9_1
BB9_3:
	ld	e, (ix - 4)
	ld	hl, (ix - 7)
	ld	iy, 7
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_ScheduleDNSRequest
_web_ScheduleDNSRequest:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -33
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, (ix + 9)
	ld	bc, (ix + 12)
	ld	(ix - 3), hl
	ld	(ix - 6), de
	ld	(ix - 9), bc
	ld	hl, (ix - 3)
	push	hl
	call	_strlen
	push	hl
	pop	de
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, 12
	add	hl, de
	ld	de, 2
	add	hl, de
	ld	de, 4
	add	hl, de
	ld	(ix - 12), hl
	ld	hl, (ix - 12)
	ld	de, 1
	push	de
	push	hl
	call	_calloc
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 15), hl
	ld	iy, (ix - 15)
	ld	(iy + 2), 1
	ld	iy, (ix - 15)
	ld	(iy + 5), 1
	ld	iy, (ix - 15)
	lea	hl, iy + 13
	ld	(ix - 18), hl
	ld	hl, (ix - 3)
	ld	(ix - 21), hl
	ld	(ix - 22), 1
	jq	BB10_1
BB10_1:
	ld	hl, (ix - 21)
	ld	a, (hl)
	or	a, a
	jq	z, BB10_6
	jq	BB10_2
BB10_2:
	ld	hl, (ix - 21)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	de, 46
	or	a, a
	sbc	hl, de
	jq	nz, BB10_4
	jq	BB10_3
BB10_3:
	ld	a, (ix - 22)
	sub	a, 1
	ld	iy, (ix - 18)
	ld	de, 0
	ld	e, (ix - 22)
	or	a, a
	sbc	hl, hl
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	add	iy, de
	ld	(iy), a
	ld	(ix - 22), 0
	jq	BB10_5
BB10_4:
	ld	hl, (ix - 21)
	ld	a, (hl)
	ld	hl, (ix - 18)
	ld	(hl), a
	jq	BB10_5
BB10_5:
	inc	(ix - 22)
	ld	hl, (ix - 21)
	inc	hl
	ld	(ix - 21), hl
	ld	hl, (ix - 18)
	inc	hl
	ld	(ix - 18), hl
	jq	BB10_1
BB10_6:
	ld	a, (ix - 22)
	sub	a, 1
	ld	iy, (ix - 18)
	ld	de, 0
	ld	e, (ix - 22)
	or	a, a
	sbc	hl, hl
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	add	iy, de
	ld	(iy), a
	ld	hl, (ix - 18)
	ld	(hl), 0
	ld	iy, (ix - 18)
	ld	(iy + 2), 1
	ld	iy, (ix - 18)
	ld	(iy + 4), 1
	call	_web_RequestPort
	ld	(ix - 24), l
	ld	(ix - 23), h
	ld	hl, 9
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 27), hl
	ld	de, (ix - 6)
	ld	hl, (ix - 27)
	ld	(hl), de
	ld	hl, (ix - 9)
	ld	iy, (ix - 27)
	ld	(iy + 3), hl
	ld	hl, (ix - 15)
	ld	(ix - 30), hl
	ld	hl, (ix - 12)
	ld	(ix - 33), hl
	ld	bc, (_netinfo+20)
	ld	a, (_netinfo+23)
	ld	e, a
	ld	hl, (ix - 24)
	ld	iy, 53
	push	iy
	push	hl
	push	de
	push	bc
	ld	hl, (ix - 33)
	push	hl
	ld	hl, (ix - 30)
	push	hl
	call	_web_PushUDPDatagram
	ld	iy, 18
	add	iy, sp
	ld	sp, iy
	ld	iy, (ix - 27)
	ld	(iy + 6), hl
	ld	hl, (ix - 15)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 24)
	ld	de, (ix - 27)
	push	de
	ld	de, _fetch_dns_msg
	push	de
	push	hl
	call	_web_ListenPort
	ld	hl, 42
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_dns_callback
_dns_callback:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -9
	add	hl, sp
	ld	sp, hl
	ld	de, (ix + 6)
	ld	iy, (ix + 9)
	ld	a, (ix + 12)
	ld	hl, (ix + 15)
	ld	bc, -1
	ld	(ix - 2), e
	ld	(ix - 1), d
	ld	(ix - 6), iy
	ld	(ix - 3), a
	ld	(ix - 9), hl
	ld	hl, (ix - 6)
	ld	a, (ix - 3)
	ld	iy, (ix - 9)
	ld	(iy), hl
	ld	(iy + 3), a
	ld	hl, (ix - 6)
	ld	e, (ix - 3)
	ld	a, -1
	call	__lcmpu
	ld	a, 1
	ld	l, 0
	jq	nz, BB11_2
	ld	a, l
BB11_2:
	and	a, 1
	or	a, a
	sbc	hl, hl
	ld	l, a
	ld	bc, 10
	call	__imulu
	ld	iy, 9
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_PushUDPDatagram
_web_PushUDPDatagram:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -37
	add	hl, sp
	ld	sp, hl
	ld	bc, (ix + 9)
	ld	a, (ix + 15)
	ld	iy, (ix + 18)
	ld	de, 8
	ld	hl, (ix + 6)
	ld	(ix - 3), hl
	ld	(ix - 6), bc
	ld	hl, (ix + 12)
	ld	(ix - 10), hl
	ld	(ix - 7), a
	push	hl
	lea	hl, iy
	ld	(ix - 12), l
	ld	(ix - 11), h
	pop	hl
	ld	hl, (ix + 21)
	ld	(ix - 14), l
	ld	(ix - 13), h
	ld	hl, (ix - 6)
	add	hl, de
	ld	de, 1
	push	de
	push	hl
	call	_calloc
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 17), hl
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__idivs
	ld	a, l
	ld	hl, (ix - 17)
	ld	(hl), a
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__irems
	ld	a, l
	ld	iy, (ix - 17)
	ld	(iy + 1), a
	ld	de, (ix - 14)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__idivs
	ld	a, l
	ld	iy, (ix - 17)
	ld	(iy + 2), a
	ld	de, (ix - 14)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__irems
	ld	a, l
	ld	iy, (ix - 17)
	ld	(iy + 3), a
	ld	hl, (ix - 6)
	ld	de, 8
	add	hl, de
	ld	bc, 256
	call	__idivu
	ld	a, l
	ld	iy, (ix - 17)
	ld	(iy + 4), a
	ld	a, (ix - 6)
	add	a, 8
	ld	iy, (ix - 17)
	ld	(iy + 5), a
	ld	iy, (ix - 17)
	lea	hl, iy + 8
	ld	de, (ix - 3)
	ld	bc, (ix - 6)
	push	bc
	push	de
	push	hl
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 17)
	ld	(ix - 25), hl
	ld	hl, (ix - 6)
	ld	de, 8
	add	hl, de
	ld	de, (_IP_ADDR)
	ld	(ix - 31), de
	ld	a, (_IP_ADDR+3)
	ld	c, a
	ld	de, (ix - 10)
	ld	a, (ix - 7)
	ld	iy, 17
	push	iy
	ld	iyl, a
	push	iy
	push	de
	push	bc
	ld	de, (ix - 31)
	push	de
	push	hl
	ld	hl, (ix - 25)
	push	hl
	call	_transport_checksum
	ld	iy, 21
	add	iy, sp
	ld	sp, iy
	ld	(ix - 19), l
	ld	(ix - 18), h
	ld	de, (ix - 19)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__idivs
	ld	a, l
	ld	iy, (ix - 17)
	ld	(iy + 6), a
	ld	de, (ix - 19)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__irems
	ld	a, l
	ld	iy, (ix - 17)
	ld	(iy + 7), a
	ld	hl, (ix - 17)
	ld	(ix - 28), hl
	ld	hl, (ix - 6)
	ld	de, 8
	add	hl, de
	ld	de, (_IP_ADDR)
	ld	(ix - 34), de
	ld	a, (_IP_ADDR+3)
	ld	e, a
	ld	(ix - 37), de
	ld	de, (ix - 10)
	ld	a, (ix - 7)
	ld	bc, 17
	push	bc
	ld	iyl, a
	push	iy
	push	de
	ld	de, (ix - 37)
	push	de
	ld	de, (ix - 34)
	push	de
	push	hl
	ld	hl, (ix - 28)
	push	hl
	call	_web_PushIPv4Packet
	ld	iy, 21
	add	iy, sp
	ld	sp, iy
	ld	(ix - 22), hl
	ld	hl, (ix - 17)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 22)
	ld	iy, 37
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_ListenPort
_web_ListenPort:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -11
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, (ix + 9)
	ld	bc, (ix + 12)
	ld	iy, 11
	ld	(ix - 2), l
	ld	(ix - 1), h
	ld	(ix - 5), de
	ld	(ix - 8), bc
	push	iy
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 11), hl
	ld	de, (ix - 2)
	ld	hl, (ix - 11)
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	hl, (ix - 5)
	ld	iy, (ix - 11)
	ld	(iy + 2), hl
	ld	hl, (ix - 8)
	ld	iy, (ix - 11)
	ld	(iy + 5), hl
	ld	hl, (_listened_ports)
	ld	iy, (ix - 11)
	ld	(iy + 8), hl
	ld	hl, (ix - 11)
	ld	(_listened_ports), hl
	ld	hl, 11
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_fetch_dns_msg
_fetch_dns_msg:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -47
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix + 6)
	ld	a, (ix + 9)
	ld	hl, (ix + 12)
	ld	de, (ix + 15)
	ld	bc, (ix + 18)
	push	hl
	lea	hl, iy
	ld	(ix - 5), l
	ld	(ix - 4), h
	pop	hl
	ld	(ix - 6), a
	ld	(ix - 9), hl
	ld	(ix - 12), de
	ld	(ix - 15), bc
	ld	a, (ix - 6)
	cp	a, 17
	jq	z, BB14_2
	jq	BB14_1
BB14_1:
	ld	hl, 1
	ld	(ix - 3), hl
	jq	BB14_28
BB14_2:
	ld	hl, (ix - 15)
	ld	(ix - 18), hl
	ld	iy, (ix - 18)
	ld	hl, (iy + 6)
	push	hl
	call	_web_popMessage
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 9)
	ld	(ix - 21), hl
	ld	hl, (ix - 21)
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__idivs
	ld	de, 53
	or	a, a
	sbc	hl, de
	jq	nz, BB14_27
	jq	BB14_3
BB14_3:
	ld	hl, (ix - 21)
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	call	__irems
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB14_27
	jq	BB14_4
BB14_4:
	ld	iy, (ix - 21)
	lea	hl, iy + 8
	ld	(ix - 24), hl
	ld	iy, (ix - 24)
	ld	hl, (iy + 2)
	ld	a, l
	and	a, 0
	ld	e, a
	ld	a, h
	and	a, -128
	ld	d, a
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	a, h
	ld	bc, 0
	cp	a, b
	jq	z, BB14_7
	jq	BB14_5
BB14_5:
	ld	iy, (ix - 24)
	bit	7, (iy + 2)
	jq	z, BB14_7
	jq	BB14_6
BB14_6:
	ld	iy, (ix - 24)
	ld	hl, (iy + 2)
	ld	a, l
	and	a, 0
	ld	e, a
	ld	a, h
	and	a, 15
	ld	d, a
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	a, h
	cp	a, b
	jq	z, BB14_8
	jq	BB14_7
BB14_7:
	ld	hl, (ix - 18)
	ld	hl, (hl)
	ld	de, (ix - 5)
	ld	iy, (ix - 18)
	ld	bc, (iy + 3)
	push	bc
	ld	bc, -1
	push	bc
	ld	bc, -1
	push	bc
	push	de
	call	__indcallhl
	ld	iy, 12
	add	iy, sp
	ld	sp, iy
	ld	(ix - 27), hl
	ld	hl, (ix - 18)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 27)
	ld	(ix - 3), hl
	jq	BB14_28
BB14_8:
	ld	iy, (ix - 24)
	ld	de, (iy + 6)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	c, 8
	call	__ishrs
	ld	a, l
	ld	(ix - 28), a
	ld	iy, (ix - 24)
	ld	de, (iy + 4)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	call	__ishrs
	ld	a, l
	ld	(ix - 29), a
	ld	iy, (ix - 24)
	lea	hl, iy + 12
	ld	(ix - 32), hl
	or	a, a
	sbc	hl, hl
	ld	(ix - 35), hl
	ld	c, 1
	ld	b, 0
	jq	BB14_9
BB14_9:
	ld	hl, (ix - 35)
	ld	iy, 0
	push	af
	ld	a, (ix - 29)
	ld	iyl, a
	pop	af
	ld	de, -8388608
	add	iy, de
	add	hl, de
	lea	de, iy
	or	a, a
	sbc	hl, de
	jq	nc, BB14_15
	jq	BB14_10
BB14_10:
	jq	BB14_11
BB14_11:
	ld	iy, (ix - 32)
	lea	hl, iy
	inc	hl
	ld	(ix - 32), hl
	ld	a, (iy)
	or	a, a
	jq	z, BB14_13
	jq	BB14_12
BB14_12:
	jq	BB14_11
BB14_13:
	ld	iy, (ix - 32)
	lea	hl, iy + 4
	ld	(ix - 32), hl
	jq	BB14_14
BB14_14:
	ld	hl, (ix - 35)
	inc	hl
	ld	(ix - 35), hl
	jq	BB14_9
BB14_15:
	or	a, a
	sbc	hl, hl
	ld	(ix - 38), hl
	jq	BB14_16
BB14_16:
	ld	hl, (ix - 38)
	ld	iy, 0
	push	af
	ld	a, (ix - 28)
	ld	iyl, a
	pop	af
	ld	de, -8388608
	add	iy, de
	add	hl, de
	lea	de, iy
	or	a, a
	sbc	hl, de
	ld	a, b
	jq	nc, BB14_22
	jq	BB14_17
BB14_17:
	ld	iy, (ix - 32)
	ld	de, (iy + 2)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, 256
	or	a, a
	sbc	hl, de
	ld	a, c
	jq	nz, BB14_21
	jq	BB14_18
BB14_18:
	ld	iy, (ix - 32)
	ld	de, (iy + 4)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, 256
	or	a, a
	sbc	hl, de
	ld	a, 1
	ld	l, 0
	jq	nz, BB14_20
	ld	a, l
BB14_20:
	jq	BB14_21
BB14_21:
	jq	BB14_22
BB14_22:
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB14_24
	jq	BB14_23
BB14_23:
	ld	iy, (ix - 32)
	lea	hl, iy + 11
	ld	(ix - 32), hl
	ld	hl, (ix - 32)
	ld	de, 0
	ld	e, (hl)
	inc	de
	ld	hl, (ix - 32)
	add	hl, de
	ld	(ix - 32), hl
	ld	hl, (ix - 38)
	inc	hl
	ld	(ix - 38), hl
	jq	BB14_16
BB14_24:
	ld	hl, (ix - 38)
	ld	de, 0
	ld	e, (ix - 28)
	or	a, a
	sbc	hl, de
	jq	nz, BB14_26
	jq	BB14_25
BB14_25:
	ld	hl, (ix - 18)
	ld	hl, (hl)
	ld	de, (ix - 5)
	ld	iy, (ix - 18)
	ld	bc, (iy + 3)
	push	bc
	ld	bc, -1
	push	bc
	ld	bc, -1
	push	bc
	push	de
	call	__indcallhl
	ld	iy, 12
	add	iy, sp
	ld	sp, iy
	ld	(ix - 41), hl
	ld	hl, (ix - 18)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 41)
	ld	(ix - 3), hl
	jq	BB14_28
BB14_26:
	ld	iy, (ix - 32)
	lea	hl, iy + 12
	ld	(ix - 32), hl
	ld	hl, (ix - 18)
	ld	hl, (hl)
	ld	(ix - 47), hl
	ld	de, (ix - 5)
	ld	iy, (ix - 32)
	ld	bc, (iy)
	ld	a, (iy + 3)
	ld	iy, (ix - 18)
	ld	iy, (iy + 3)
	push	iy
	ld	l, a
	push	hl
	push	bc
	push	de
	ld	hl, (ix - 47)
	call	__indcallhl
	ld	iy, 12
	add	iy, sp
	ld	sp, iy
	ld	(ix - 44), hl
	ld	hl, (ix - 18)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 44)
	ld	(ix - 3), hl
	jq	BB14_28
BB14_27:
	ld	hl, (ix - 18)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, 1
	ld	(ix - 3), hl
	jq	BB14_28
BB14_28:
	ld	hl, (ix - 3)
	ld	iy, 47
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_SendTCPSegment
_web_SendTCPSegment:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -53
	add	hl, sp
	ld	sp, hl
	ld	l, (ix + 15)
	ld	a, (ix + 27)
	ld	iy, (ix + 30)
	ld	h, (ix + 33)
	ld	bc, (ix + 39)
	ld	de, (ix + 6)
	ld	(ix - 3), de
	ld	de, (ix + 9)
	ld	(ix - 6), de
	ld	de, (ix + 12)
	ld	(ix - 10), de
	ld	(ix - 7), l
	ld	de, (ix + 18)
	ld	(ix - 12), e
	ld	(ix - 11), d
	ld	de, (ix + 21)
	ld	(ix - 14), e
	ld	(ix - 13), d
	ld	de, (ix + 24)
	ld	(ix - 18), de
	ld	(ix - 15), a
	ld	(ix - 22), iy
	ld	(ix - 19), h
	ld	hl, (ix + 36)
	ld	(ix - 24), l
	ld	(ix - 23), h
	ld	(ix - 27), bc
	ld	hl, (ix + 42)
	ld	(ix - 30), hl
	ld	hl, (ix - 3)
	ld	(ix - 36), hl
	ld	hl, (ix - 6)
	ld	(ix - 39), hl
	ld	hl, (ix - 10)
	ld	(ix - 42), hl
	ld	a, (ix - 7)
	ld	(ix - 43), a
	ld	hl, (ix - 12)
	ld	(ix - 46), hl
	ld	hl, (ix - 14)
	ld	(ix - 49), hl
	ld	hl, (ix - 18)
	ld	(ix - 52), hl
	ld	a, (ix - 15)
	ld	(ix - 53), a
	ld	iy, (ix - 22)
	ld	a, (ix - 19)
	ld	de, (ix - 24)
	ld	bc, (ix - 27)
	ld	hl, (ix - 30)
	push	hl
	push	bc
	push	de
	ld	l, a
	push	hl
	push	iy
	ld	l, (ix - 53)
	push	hl
	ld	hl, (ix - 52)
	push	hl
	ld	hl, (ix - 49)
	push	hl
	ld	hl, (ix - 46)
	push	hl
	ld	l, (ix - 43)
	push	hl
	ld	hl, (ix - 42)
	push	hl
	ld	hl, (ix - 39)
	push	hl
	ld	hl, (ix - 36)
	push	hl
	call	_web_PushTCPSegment
	ld	iy, 39
	add	iy, sp
	ld	sp, iy
	ld	(ix - 33), hl
	ld	iy, (ix - 33)
	ld	hl, (iy + 6)
	ld	e, (iy + 9)
	ld	bc, 100
	xor	a, a
	call	__ladd
	ld	(iy + 6), hl
	ld	(iy + 9), e
	ld	iy, (ix - 33)
	ld	bc, (iy + 10)
	ld	iy, (ix - 33)
	ld	iy, (iy + 3)
	ld	hl, (ix - 33)
	ld	hl, (hl)
	ld	de, (ix - 33)
	push	de
	ld	de, _send_callback
	push	de
	push	hl
	push	iy
	push	bc
	call	_usb_ScheduleTransfer
	ld	iy, 68
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_PushTCPSegment
_web_PushTCPSegment:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -53
	add	hl, sp
	ld	sp, hl
	ld	c, (ix + 15)
	ld	a, (ix + 27)
	ld	iy, (ix + 30)
	ld	b, (ix + 33)
	ld	de, 20
	ld	hl, (ix + 6)
	ld	(ix - 3), hl
	ld	hl, (ix + 9)
	ld	(ix - 6), hl
	ld	hl, (ix + 12)
	ld	(ix - 10), hl
	ld	(ix - 7), c
	ld	hl, (ix + 18)
	ld	(ix - 12), l
	ld	(ix - 11), h
	ld	hl, (ix + 21)
	ld	(ix - 14), l
	ld	(ix - 13), h
	ld	hl, (ix + 24)
	ld	(ix - 18), hl
	ld	(ix - 15), a
	ld	(ix - 22), iy
	ld	(ix - 19), b
	ld	hl, (ix + 36)
	ld	(ix - 24), l
	ld	(ix - 23), h
	ld	hl, (ix + 39)
	ld	(ix - 27), hl
	ld	hl, (ix + 42)
	ld	(ix - 30), hl
	ld	hl, (ix - 6)
	add	hl, de
	ld	de, 1
	push	de
	push	hl
	call	_calloc
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 33), hl
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__idivs
	ld	a, l
	ld	hl, (ix - 33)
	ld	(hl), a
	ld	de, (ix - 12)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__irems
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 1), a
	ld	de, (ix - 14)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__idivs
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 2), a
	ld	de, (ix - 14)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__irems
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 3), a
	ld	hl, (ix - 18)
	ld	e, (ix - 15)
	ld	bc, 0
	ld	a, 1
	call	__ldivu
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 4), a
	ld	hl, (ix - 18)
	ld	e, (ix - 15)
	ld	bc, 65536
	xor	a, a
	call	__ldivu
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 5), a
	ld	hl, (ix - 18)
	ld	e, (ix - 15)
	ld	bc, 256
	xor	a, a
	call	__ldivu
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 6), a
	ld	a, (ix - 18)
	ld	iy, (ix - 33)
	ld	(iy + 7), a
	ld	hl, (ix - 22)
	ld	e, (ix - 19)
	ld	bc, 0
	ld	a, 1
	call	__ldivu
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 8), a
	ld	hl, (ix - 22)
	ld	e, (ix - 19)
	ld	bc, 65536
	xor	a, a
	call	__ldivu
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 9), a
	ld	hl, (ix - 22)
	ld	e, (ix - 19)
	ld	bc, 256
	xor	a, a
	call	__ldivu
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 10), a
	ld	a, (ix - 22)
	ld	iy, (ix - 33)
	ld	(iy + 11), a
	ld	de, (ix - 27)
	ld	hl, 20
	add	hl, de
	ld	c, 2
	call	__ishl
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 12), a
	ld	a, (ix - 24)
	ld	iy, (ix - 33)
	ld	(iy + 13), a
	ld	iy, (ix - 33)
	ld	(iy + 14), 14
	ld	iy, (ix - 33)
	ld	(iy + 15), -88
	ld	hl, (ix - 30)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB16_2
	jq	BB16_1
BB16_1:
	ld	iy, (ix - 33)
	lea	hl, iy + 20
	ld	de, (ix - 30)
	ld	bc, (ix - 27)
	push	bc
	push	de
	push	hl
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	jq	BB16_2
BB16_2:
	ld	hl, (ix - 6)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB16_4
	jq	BB16_3
BB16_3:
	ld	iy, (ix - 33)
	lea	hl, iy + 20
	ld	de, (ix - 27)
	add	hl, de
	ld	de, (ix - 3)
	ld	bc, (ix - 6)
	push	bc
	push	de
	push	hl
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	jq	BB16_4
BB16_4:
	ld	hl, (ix - 33)
	ld	(ix - 41), hl
	ld	hl, (ix - 6)
	ld	de, 20
	add	hl, de
	ld	bc, (ix - 27)
	add	hl, bc
	ld	de, (_IP_ADDR)
	ld	(ix - 47), de
	ld	a, (_IP_ADDR+3)
	ld	c, a
	ld	de, (ix - 10)
	ld	a, (ix - 7)
	ld	iy, 6
	push	iy
	ld	iyl, a
	push	iy
	push	de
	push	bc
	ld	de, (ix - 47)
	push	de
	push	hl
	ld	hl, (ix - 41)
	push	hl
	call	_transport_checksum
	ld	iy, 21
	add	iy, sp
	ld	sp, iy
	ld	(ix - 35), l
	ld	(ix - 34), h
	ld	de, (ix - 35)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__idivs
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 16), a
	ld	de, (ix - 35)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	call	__irems
	ld	a, l
	ld	iy, (ix - 33)
	ld	(iy + 17), a
	ld	hl, (ix - 33)
	ld	(ix - 44), hl
	ld	hl, (ix - 6)
	ld	de, 20
	add	hl, de
	ld	bc, (ix - 27)
	add	hl, bc
	ld	de, (_IP_ADDR)
	ld	(ix - 50), de
	ld	a, (_IP_ADDR+3)
	ld	e, a
	ld	(ix - 53), de
	ld	de, (ix - 10)
	ld	a, (ix - 7)
	ld	bc, 6
	push	bc
	ld	iyl, a
	push	iy
	push	de
	ld	de, (ix - 53)
	push	de
	ld	de, (ix - 50)
	push	de
	push	hl
	ld	hl, (ix - 44)
	push	hl
	call	_web_PushIPv4Packet
	ld	iy, 21
	add	iy, sp
	ld	sp, iy
	ld	(ix - 38), hl
	ld	hl, (ix - 33)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 38)
	ld	iy, 53
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_send_callback
_send_callback:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -12
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, (ix + 9)
	ld	bc, (ix + 12)
	ld	(ix - 3), hl
	ld	(ix - 6), de
	ld	(ix - 9), bc
	ld	hl, (ix + 15)
	ld	(ix - 12), hl
	ld	hl, (ix - 12)
	push	hl
	call	_web_popMessage
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	or	a, a
	sbc	hl, hl
	ld	iy, 12
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_transport_checksum
_transport_checksum:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -29
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	a, (ix + 15)
	ld	iyl, a
	ld	a, (ix + 21)
	ld	e, (ix + 24)
	ld	bc, 256
	ld	d, 0
	ld	(ix - 3), hl
	ld	hl, (ix + 9)
	ld	(ix - 6), hl
	ld	hl, (ix + 12)
	ld	(ix - 10), hl
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	ld	(ix - 7), l
	ld	hl, (ix + 18)
	ld	(ix - 14), hl
	ld	(ix - 11), a
	ld	(ix - 15), e
	ld	hl, (ix - 6)
	call	__idivu
	push	hl
	pop	iy
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	ld	bc, 65536
	ld	a, d
	call	__ldivu
	ld	bc, 255
	ld	a, d
	call	__land
	push	hl
	pop	bc
	ld	a, e
	lea	hl, iy
	ld	e, d
	call	__ladd
	push	hl
	pop	iy
	ld	d, e
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	ld	bc, 255
	xor	a, a
	call	__land
	push	hl
	pop	bc
	ld	a, e
	lea	hl, iy
	ld	e, d
	call	__ladd
	ld	(ix - 29), hl
	ld	d, e
	ld	hl, (ix - 10)
	ld	e, (ix - 7)
	ld	bc, 65536
	xor	a, a
	call	__ldivu
	ld	bc, 255
	xor	a, a
	call	__land
	push	hl
	pop	bc
	ld	a, e
	ld	hl, (ix - 29)
	ld	e, d
	call	__ladd
	push	hl
	pop	iy
	ld	d, e
	ld	hl, (ix - 10)
	ld	e, (ix - 7)
	ld	bc, 255
	xor	a, a
	call	__land
	push	hl
	pop	bc
	ld	a, e
	lea	hl, iy
	ld	e, d
	call	__ladd
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	iy, 0
	push	af
	ld	a, (ix - 15)
	ld	iyl, a
	pop	af
	ld	hl, (ix - 6)
	ld	bc, 256
	dec	bc
	call	__iand
	push	hl
	pop	de
	add	iy, de
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	ld	bc, 0
	ld	a, 1
	call	__ldivu
	ld	bc, 255
	ld	d, 0
	ld	a, d
	call	__land
	push	hl
	pop	bc
	ld	a, e
	lea	hl, iy
	ld	e, d
	call	__ladd
	push	hl
	pop	iy
	ld	(ix - 26), e
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	ld	bc, 256
	ld	a, d
	call	__ldivu
	ld	bc, 255
	ld	a, d
	call	__land
	push	hl
	pop	bc
	ld	a, e
	lea	hl, iy
	ld	e, (ix - 26)
	call	__ladd
	push	hl
	pop	iy
	ld	d, e
	ld	hl, (ix - 10)
	ld	e, (ix - 7)
	ld	bc, 0
	ld	a, 1
	call	__ldivu
	ld	bc, 255
	xor	a, a
	call	__land
	push	hl
	pop	bc
	ld	a, e
	lea	hl, iy
	ld	e, d
	call	__ladd
	push	hl
	pop	iy
	ld	d, e
	ld	hl, (ix - 10)
	ld	e, (ix - 7)
	ld	bc, 256
	xor	a, a
	call	__ldivu
	ld	bc, 255
	xor	a, a
	call	__land
	push	hl
	pop	bc
	ld	a, e
	lea	hl, iy
	ld	e, d
	call	__ladd
	ld	bc, 1
	ld	(ix - 19), l
	ld	(ix - 18), h
	or	a, a
	sbc	hl, hl
	ld	(ix - 22), hl
	jq	BB18_1
BB18_1:
	ld	de, (ix - 22)
	ld	hl, (ix - 6)
	push	bc
	pop	iy
	or	a, a
	sbc	hl, bc
	push	hl
	pop	bc
	ex	de, hl
	or	a, a
	sbc	hl, bc
	jq	nc, BB18_4
	jq	BB18_2
BB18_2:
	ld	hl, (ix - 3)
	ld	de, (ix - 22)
	add	hl, de
	ld	de, 0
	ld	e, (hl)
	ld	bc, (ix - 17)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	add	hl, de
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	hl, (ix - 3)
	ld	de, (ix - 22)
	inc	de
	add	hl, de
	ld	de, 0
	ld	e, (hl)
	ld	bc, (ix - 19)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	add	hl, de
	ld	(ix - 19), l
	ld	(ix - 18), h
	jq	BB18_3
BB18_3:
	ld	hl, (ix - 22)
	ld	de, 2
	add	hl, de
	ld	(ix - 22), hl
	lea	bc, iy
	jq	BB18_1
BB18_4:
	ld	hl, (ix - 6)
	ld	bc, 2
	dec	bc
	call	__iand
	ld	e, 1
	ld	a, l
	xor	a, e
	bit	0, a
	jq	nz, BB18_6
	jq	BB18_5
BB18_5:
	ld	bc, (ix - 3)
	ld	hl, (ix - 6)
	lea	de, iy
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	push	bc
	pop	hl
	add	hl, de
	ld	de, 0
	ld	e, (hl)
	ld	bc, (ix - 17)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	add	hl, de
	ld	(ix - 17), l
	ld	(ix - 16), h
	jq	BB18_6
BB18_6:
	ld	de, (ix - 19)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	c, 8
	call	__ishrs
	push	hl
	pop	de
	ld	iy, (ix - 17)
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	add	hl, de
	ld	(ix - 17), l
	ld	(ix - 16), h
	ld	de, (ix - 17)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	call	__ishrs
	push	hl
	pop	de
	ld	iy, (ix - 19)
	or	a, a
	sbc	hl, hl
	ex	de, hl
	ld	e, iyl
	ld	d, iyh
	ex	de, hl
	add	hl, de
	ld	(ix - 19), l
	ld	(ix - 18), h
	ld	de, (ix - 17)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	call	__ishl
	ld	de, (ix - 19)
	ld	a, e
	and	a, -1
	ld	c, a
	ld	a, d
	and	a, 0
	ld	b, a
	ld	de, 0
	ld	e, c
	ld	d, b
	add	hl, de
	ld	(ix - 25), hl
	ld	a, (ix - 23)
	ld	a, l
	cpl
	ld	e, a
	ld	a, h
	cpl
	ld	d, a
	ld	l, e
	ld	h, d
	ld	iy, 29
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_PushIPv4Packet
_web_PushIPv4Packet:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -49
	add	hl, sp
	ld	sp, hl
	ld	a, (ix + 15)
	ld	iyl, a
	ld	a, (ix + 21)
	ld	iyh, a
	ld	a, (ix + 24)
	ld	bc, 20
	lea	de, ix - 38
	ld	(ix - 49), de
	ld	hl, (ix + 6)
	ld	(ix - 3), hl
	ld	hl, (ix + 9)
	ld	(ix - 6), hl
	ld	hl, (ix + 12)
	ld	(ix - 10), hl
	ex	de, hl
	ld	e, iyl
	ex	de, hl
	ld	(ix - 7), l
	ld	hl, (ix + 18)
	ld	(ix - 14), hl
	ex	de, hl
	ld	e, iyh
	ex	de, hl
	ld	(ix - 11), l
	ld	(ix - 15), a
	ld	hl, (ix - 6)
	add	hl, bc
	ld	(ix - 18), hl
	ld	hl, L___const.web_PushIPv4Packet.packet
	ldir
	ld	hl, (ix - 18)
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 41), hl
	ld	de, (ix - 41)
	ld	hl, (ix - 49)
	ld	bc, 20
	ldir
	ld	hl, (ix - 18)
	ld	bc, 256
	call	__idivu
	ld	a, l
	ld	iy, (ix - 41)
	ld	(iy + 2), a
	ld	a, (ix - 18)
	ld	iy, (ix - 41)
	ld	(iy + 3), a
	ld	hl, _web_PushIPv4Packet.nbpacket
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__idivs
	ld	a, l
	ld	iy, (ix - 41)
	ld	(iy + 4), a
	ld	hl, _web_PushIPv4Packet.nbpacket
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__irems
	ld	a, l
	ld	iy, (ix - 41)
	ld	(iy + 5), a
	ld	a, (ix - 15)
	ld	iy, (ix - 41)
	ld	(iy + 9), a
	ld	hl, (ix - 10)
	ld	a, (ix - 7)
	ld	iy, (ix - 41)
	ld	(iy + 12), hl
	ld	(iy + 15), a
	ld	hl, (ix - 14)
	ld	a, (ix - 11)
	ld	iy, (ix - 41)
	ld	(iy + 16), hl
	ld	(iy + 19), a
	ld	hl, (ix - 41)
	ld	de, 20
	push	de
	push	hl
	call	_ipv4_checksum
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 43), l
	ld	(ix - 42), h
	ld	de, (ix - 43)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__irems
	ld	a, l
	ld	iy, (ix - 41)
	ld	(iy + 10), a
	ld	de, (ix - 43)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 256
	call	__idivs
	ld	a, l
	ld	iy, (ix - 41)
	ld	(iy + 11), a
	ld	iy, (ix - 41)
	lea	hl, iy + 20
	ld	de, (ix - 3)
	ld	bc, (ix - 6)
	push	bc
	push	de
	push	hl
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	iy, _web_PushIPv4Packet.nbpacket
	ld	hl, (iy)
	inc.sis	hl
	ld	(iy), l
	ld	(iy + 1), h
	ld	hl, (ix - 41)
	ld	de, (ix - 18)
	ld	bc, 8
	push	bc
	push	de
	push	hl
	call	_web_PushEthernetFrame
	ld	iy, 9
	add	iy, sp
	ld	sp, iy
	ld	(ix - 46), hl
	ld	hl, (ix - 41)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 46)
	ld	iy, 49
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_ipv4_checksum
_ipv4_checksum:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -15
	add	hl, sp
	ld	sp, hl
	or	a, a
	sbc	hl, hl
	ld	bc, 2
	ld	de, (ix + 6)
	ld	(ix - 3), de
	ld	de, (ix + 9)
	ld	(ix - 6), de
	ld	(ix - 9), hl
	ld	(ix - 12), hl
	jq	BB20_1
BB20_1:
	ld	iy, (ix - 12)
	ld	hl, (ix - 6)
	call	__idivu
	push	hl
	pop	de
	lea	hl, iy
	or	a, a
	sbc	hl, de
	jq	nc, BB20_4
	jq	BB20_2
BB20_2:
	ld	hl, (ix - 3)
	ld	iy, (ix - 12)
	add	iy, iy
	lea	de, iy
	add	hl, de
	ld	hl, (hl)
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, (ix - 9)
	add	hl, de
	ld	(ix - 9), hl
	jq	BB20_3
BB20_3:
	ld	hl, (ix - 12)
	inc	hl
	ld	(ix - 12), hl
	jq	BB20_1
BB20_4:
	ld	iy, (ix - 9)
	ld	hl, (ix - 9)
	ld	c, 16
	call	__ishru
	push	hl
	pop	de
	add	iy, de
	ld	(ix - 15), iy
	ld	a, (ix - 13)
	ld	a, iyl
	cpl
	ld	l, a
	ld	a, iyh
	cpl
	ld	h, a
	ld	iy, 15
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_PushEthernetFrame
_web_PushEthernetFrame:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -21
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, (ix + 12)
	ld	bc, 18
	lea	iy, ix - 15
	ld	(ix - 21), iy
	ld	(ix - 3), hl
	ld	hl, (ix + 9)
	ld	(ix - 6), hl
	ld	(ix - 8), e
	ld	(ix - 7), d
	ld	de, 46
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	jq	nc, BB21_2
	jq	BB21_1
BB21_1:
	ld	hl, 1
	push	hl
	ld	hl, 64
	push	hl
	call	_calloc
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 11), hl
	jq	BB21_3
BB21_2:
	ld	de, (ix - 6)
	push	bc
	pop	hl
	add	hl, de
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 11), hl
	jq	BB21_3
BB21_3:
	ld	de, (ix - 11)
	ld	hl, _netinfo+10
	ld	bc, 6
	ldir
	ld	iy, (ix - 11)
	lea	de, iy + 6
	ld	hl, _MAC_ADDR
	ld	bc, 6
	ldir
	ld	hl, (ix - 8)
	ld	iy, (ix - 11)
	ld	(iy + 12), l
	ld	(iy + 13), h
	ld	iy, (ix - 11)
	lea	hl, iy + 14
	ld	de, (ix - 3)
	ld	bc, (ix - 6)
	push	bc
	push	de
	push	hl
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	de, 46
	ld	hl, (ix - 6)
	or	a, a
	sbc	hl, de
	jq	nc, BB21_5
	jq	BB21_4
BB21_4:
	ld	hl, 64
	ld	(ix - 6), hl
	jq	BB21_6
BB21_5:
	ld	hl, (ix - 6)
	ld	de, 18
	add	hl, de
	ld	(ix - 6), hl
	jq	BB21_6
BB21_6:
	ld	de, (ix - 11)
	ld	hl, (ix - 6)
	ld	bc, 4
	or	a, a
	sbc	hl, bc
	push	hl
	push	de
	call	_crc32b
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 15), hl
	ld	(ix - 12), e
	ld	iy, (ix - 11)
	ld	de, (ix - 6)
	add	iy, de
	lea	de, iy - 4
	ld	hl, (ix - 21)
	ld	bc, 4
	ldir
	ld	hl, (ix - 11)
	ld	de, (ix - 6)
	push	de
	push	hl
	call	_web_PushRNDISPacket
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 18), hl
	ld	hl, (ix - 11)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 18)
	ld	iy, 21
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_crc32b
_crc32b:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -17
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, (ix + 9)
	ld	bc, 0
	ld	iy, -1
	ld	a, -1
	ld	(ix - 7), hl
	ld	(ix - 10), de
	ld	hl, (ix - 7)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB22_2
	jq	BB22_1
BB22_1:
	ld	hl, (ix - 10)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB22_3
	jq	BB22_2
BB22_2:
	ld	(ix - 4), bc
	xor	a, a
	ld	(ix - 1), a
	jq	BB22_32
BB22_3:
	ld	(ix - 14), iy
	ld	(ix - 11), a
	ld	(ix - 17), bc
	ld	iy, 1
	jq	BB22_4
BB22_4:
	ld	de, (ix - 10)
	ld	hl, (ix - 17)
	or	a, a
	sbc	hl, de
	jq	nc, BB22_31
	jq	BB22_5
BB22_5:
	ld	hl, (ix - 7)
	ld	de, (ix - 17)
	add	hl, de
	ld	bc, 0
	ld	c, (hl)
	xor	a, a
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	call	__lxor
	ld	(ix - 14), hl
	ld	(ix - 11), e
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	lea	bc, iy
	ld	d, 0
	ld	a, d
	call	__land
	ld	e, 1
	ld	a, l
	xor	a, e
	bit	0, a
	jq	nz, BB22_7
	jq	BB22_6
BB22_6:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	push	bc
	pop	hl
	ld	e, a
	ld	bc, -4685024
	ld	a, -19
	call	__lxor
	push	hl
	pop	bc
	ld	a, e
	jq	BB22_8
BB22_7:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	jq	BB22_8
BB22_8:
	ld	(ix - 14), bc
	ld	(ix - 11), a
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	lea	bc, iy
	ld	a, d
	call	__land
	ld	e, 1
	ld	a, l
	xor	a, e
	bit	0, a
	jq	nz, BB22_10
	jq	BB22_9
BB22_9:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	push	bc
	pop	hl
	ld	e, a
	ld	bc, -4685024
	ld	a, -19
	call	__lxor
	push	hl
	pop	bc
	ld	a, e
	jq	BB22_11
BB22_10:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	jq	BB22_11
BB22_11:
	ld	(ix - 14), bc
	ld	(ix - 11), a
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	lea	bc, iy
	ld	a, d
	call	__land
	ld	e, 1
	ld	a, l
	xor	a, e
	bit	0, a
	jq	nz, BB22_13
	jq	BB22_12
BB22_12:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	push	bc
	pop	hl
	ld	e, a
	ld	bc, -4685024
	ld	a, -19
	call	__lxor
	push	hl
	pop	bc
	ld	a, e
	jq	BB22_14
BB22_13:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	jq	BB22_14
BB22_14:
	ld	(ix - 14), bc
	ld	(ix - 11), a
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	lea	bc, iy
	ld	a, d
	call	__land
	ld	e, 1
	ld	a, l
	xor	a, e
	bit	0, a
	jq	nz, BB22_16
	jq	BB22_15
BB22_15:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	push	bc
	pop	hl
	ld	e, a
	ld	bc, -4685024
	ld	a, -19
	call	__lxor
	push	hl
	pop	bc
	ld	a, e
	jq	BB22_17
BB22_16:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	jq	BB22_17
BB22_17:
	ld	(ix - 14), bc
	ld	(ix - 11), a
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	lea	bc, iy
	ld	a, d
	call	__land
	ld	e, 1
	ld	a, l
	xor	a, e
	bit	0, a
	jq	nz, BB22_19
	jq	BB22_18
BB22_18:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	push	bc
	pop	hl
	ld	e, a
	ld	bc, -4685024
	ld	a, -19
	call	__lxor
	push	hl
	pop	bc
	ld	a, e
	jq	BB22_20
BB22_19:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	jq	BB22_20
BB22_20:
	ld	(ix - 14), bc
	ld	(ix - 11), a
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	lea	bc, iy
	ld	a, d
	call	__land
	ld	e, 1
	ld	a, l
	xor	a, e
	bit	0, a
	jq	nz, BB22_22
	jq	BB22_21
BB22_21:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	push	bc
	pop	hl
	ld	e, a
	ld	bc, -4685024
	ld	a, -19
	call	__lxor
	push	hl
	pop	bc
	ld	a, e
	jq	BB22_23
BB22_22:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	jq	BB22_23
BB22_23:
	ld	(ix - 14), bc
	ld	(ix - 11), a
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	lea	bc, iy
	ld	a, d
	call	__land
	ld	e, 1
	ld	a, l
	xor	a, e
	bit	0, a
	jq	nz, BB22_25
	jq	BB22_24
BB22_24:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	push	bc
	pop	hl
	ld	e, a
	ld	bc, -4685024
	ld	a, -19
	call	__lxor
	push	hl
	pop	bc
	ld	a, e
	jq	BB22_26
BB22_25:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	jq	BB22_26
BB22_26:
	ld	(ix - 14), bc
	ld	(ix - 11), a
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	lea	bc, iy
	ld	a, d
	call	__land
	ld	e, 1
	ld	a, l
	xor	a, e
	bit	0, a
	jq	nz, BB22_28
	jq	BB22_27
BB22_27:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	push	bc
	pop	hl
	ld	e, a
	ld	bc, -4685024
	ld	a, -19
	call	__lxor
	push	hl
	pop	bc
	ld	a, e
	jq	BB22_29
BB22_28:
	ld	bc, (ix - 14)
	ld	a, (ix - 11)
	ld	l, 1
	call	__lshru
	jq	BB22_29
BB22_29:
	ld	(ix - 14), bc
	ld	(ix - 11), a
	jq	BB22_30
BB22_30:
	ld	hl, (ix - 17)
	inc	hl
	ld	(ix - 17), hl
	jq	BB22_4
BB22_31:
	ld	hl, (ix - 14)
	ld	e, (ix - 11)
	call	__lnot
	ld	(ix - 4), hl
	ld	(ix - 1), e
	jq	BB22_32
BB22_32:
	ld	e, (ix - 1)
	ld	hl, (ix - 4)
	ld	iy, 17
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_PushRNDISPacket
_web_PushRNDISPacket:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -15
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, (ix + 9)
	ld	bc, 44
	ld	(ix - 3), hl
	ld	(ix - 6), de
	ld	de, (ix - 6)
	push	bc
	pop	hl
	add	hl, de
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 9), hl
	ld	hl, (ix - 9)
	ld	(hl), 0
	push	hl
	pop	iy
	inc	iy
	ld	bc, 43
	lea	de, iy
	ldir
	ld	hl, (ix - 9)
	ld	(hl), 1
	ld	l, (ix - 6)
	ld	a, 44
	add	a, l
	ld	iy, (ix - 9)
	ld	(iy + 4), a
	ld	de, (ix - 6)
	ld	hl, 44
	add	hl, de
	ld	bc, 256
	call	__idivu
	ld	a, l
	ld	iy, (ix - 9)
	ld	(iy + 5), a
	ld	iy, (ix - 9)
	ld	(iy + 8), 36
	ld	a, (ix - 6)
	ld	iy, (ix - 9)
	ld	(iy + 12), a
	ld	hl, (ix - 6)
	ld	bc, 256
	call	__idivu
	ld	a, l
	ld	iy, (ix - 9)
	ld	(iy + 13), a
	ld	iy, (ix - 9)
	lea	hl, iy + 44
	ld	de, (ix - 3)
	ld	bc, (ix - 6)
	push	bc
	push	de
	push	hl
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 9)
	ld	(ix - 12), hl
	ld	hl, (ix - 6)
	ld	de, 44
	add	hl, de
	ld	(ix - 15), hl
	ld	hl, (_netinfo)
	ld	a, (_netinfo+8)
	ld	e, a
	push	de
	push	hl
	call	_usb_GetDeviceEndpoint
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	de, 0
	push	de
	ld	de, _packets_callback
	push	de
	push	hl
	ld	hl, (ix - 15)
	push	hl
	ld	hl, (ix - 12)
	push	hl
	call	_web_pushMessage
	ld	iy, 30
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_pushMessage
_web_pushMessage:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -18
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, (ix + 9)
	ld	bc, (ix + 12)
	ld	iy, 25
	ld	(ix - 3), hl
	ld	(ix - 6), de
	ld	(ix - 9), bc
	ld	hl, (ix + 15)
	ld	(ix - 12), hl
	ld	hl, (ix + 18)
	ld	(ix - 15), hl
	push	iy
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 18), hl
	ld	de, (ix - 6)
	ld	hl, (ix - 18)
	ld	(hl), de
	ld	hl, (ix - 3)
	ld	iy, (ix - 18)
	ld	(iy + 3), hl
	ld	iy, -851900
	ld	hl, (iy)
	ld	a, (iy + 3)
	ld	iy, (ix - 18)
	ld	(iy + 6), hl
	ld	(iy + 9), a
	ld	hl, (ix - 9)
	ld	iy, (ix - 18)
	ld	(iy + 10), hl
	ld	hl, (ix - 12)
	ld	iy, (ix - 18)
	ld	(iy + 13), hl
	ld	hl, (ix - 15)
	ld	iy, (ix - 18)
	ld	(iy + 16), hl
	ld	iy, (ix - 18)
	ld	hl, 0
	ld	(iy + 22), hl
	ld	hl, (_send_queue)
	ld	iy, (ix - 18)
	ld	(iy + 19), hl
	ld	hl, (_send_queue)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB24_2
	jq	BB24_1
BB24_1:
	ld	hl, (ix - 18)
	ld	iy, (_send_queue)
	ld	(iy + 22), hl
	jq	BB24_2
BB24_2:
	ld	hl, (ix - 18)
	ld	(_send_queue), hl
	ld	hl, (ix - 18)
	ld	iy, 18
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_packets_callback
_packets_callback:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -15
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	bc, (ix + 9)
	ld	de, (ix + 12)
	ld	(ix - 3), hl
	ld	(ix - 6), bc
	ld	(ix - 9), de
	ld	hl, (ix + 15)
	ld	(ix - 12), hl
	ld	hl, (ix - 12)
	ld	iy, (hl)
	lea	de, iy + 44
	ld	hl, (ix - 9)
	ld	bc, 44
	or	a, a
	sbc	hl, bc
	push	hl
	push	de
	call	_fetch_ethernet_frame
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 15), hl
	ld	hl, (ix - 12)
	ld	de, 0
	ld	(hl), de
	ld	hl, (ix - 15)
	ld	iy, 15
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_send_rndis_callback
_send_rndis_callback:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -12
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, (ix + 9)
	ld	bc, (ix + 12)
	ld	(ix - 3), hl
	ld	(ix - 6), de
	ld	(ix - 9), bc
	ld	hl, (ix + 15)
	ld	(ix - 12), hl
	ld	hl, (ix - 12)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	or	a, a
	sbc	hl, hl
	ld	iy, 12
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_Init
_web_Init:
	push	ix
	ld	ix, 0
	add	ix, sp
	xor	a, a
	ld	l, 1
	ld	de, 0
	ld	iy, _usbHandler
	ld	bc, 36106
	ld	(_netinfo+7), a
	ld	(_netinfo+6), a
	ld	(_netinfo+9), a
	ld	(_netinfo+8), a
	ld	(_netinfo+4), a
	ld	(_netinfo+3), a
	ld	a, l
	ld	(_netinfo+5), a
	ld	(_netinfo), de
	push	bc
	push	de
	push	de
	push	iy
	call	_usb_Init
	ld	hl, 12
	add	hl, sp
	ld	sp, hl
	jq	BB27_1
BB27_1:
	ld	hl, (_netinfo)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB27_3
	jq	BB27_2
BB27_2:
	call	_usb_WaitForEvents
	jq	BB27_1
BB27_3:
	ld	a, -1
	ld	(_netinfo+10), a
	ld	hl, _netinfo+10
	push	hl
	pop	de
	inc	de
	ld	bc, 5
	ldir
	ld	hl, -851900
	push	hl
	pop	iy
	ld	hl, (iy)
	ld	a, (iy + 3)
	push	hl
	call	_srand
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	call	_random
	ld	a, l
	ld	(_MAC_ADDR+5), a
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_usbHandler
_usbHandler:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -628
	add	hl, sp
	ld	sp, hl
	ld	bc, -607
	lea	iy, ix
	add	iy, bc
	ld	de, (ix + 9)
	ld	bc, (ix + 12)
	lea	hl, ix - 42
	ld	(ix - 3), bc
	push	ix
	ld	bc, -628
	add	ix, bc
	ld	(ix), hl
	pop	ix
	lea	hl, ix - 74
	push	ix
	ld	bc, -622
	add	ix, bc
	ld	(ix), hl
	pop	ix
	lea	hl, ix - 82
	push	ix
	ld	bc, -625
	add	ix, bc
	ld	(ix), hl
	pop	ix
	lea	hl, ix - 90
	push	ix
	ld	bc, -619
	add	ix, bc
	ld	(ix), hl
	pop	ix
	lea	hl, iy + 5
	push	ix
	ld	bc, -613
	add	ix, bc
	ld	(ix), hl
	pop	ix
	ld	bc, -610
	lea	hl, ix
	add	hl, bc
	ld	(hl), iy
	lea	hl, iy + 2
	ld	bc, -616
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	hl, (ix + 6)
	ld	(ix - 12), hl
	ld	(ix - 15), de
	ld	bc, (ix - 3)
	ld	(ix - 18), bc
	ld	a, (_netinfo+5)
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB28_58
	jq	BB28_1
BB28_1:
	ld	de, 2
	ld	hl, (ix - 12)
	or	a, a
	sbc	hl, de
	jq	nz, BB28_58
	jq	BB28_2
BB28_2:
	ld	bc, -628
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	ld	hl, L___const.usbHandler.rndis_initmsg
	ld	bc, 24
	ldir
	ld	bc, -622
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	ld	hl, L___const.usbHandler.rndis_setpcktflt
	ld	bc, 32
	ldir
	ld	bc, -625
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	ld	hl, L___const.usbHandler.out_ctrl
	ld	iy, 8
	lea	bc, iy
	ldir
	ld	bc, -619
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	ld	hl, L___const.usbHandler.in_ctrl
	lea	bc, iy
	ldir
	or	a, a
	sbc	hl, hl
	ld	bc, -610
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy + 2), hl
	ld	(iy + 1), 0
	ld	a, (_netinfo+3)
	bit	0, a
	jq	nz, BB28_4
	jq	BB28_3
BB28_3:
	ld	hl, 36106
	push	hl
	ld	hl, 0
	push	hl
	push	hl
	ld	hl, _usbHandler
	push	hl
	call	_usb_Init
	ld	hl, 12
	add	hl, sp
	ld	sp, hl
	jq	BB28_4
BB28_4:
	ld	hl, (ix - 15)
	ld	(_netinfo), hl
	ld	a, 1
	ld	(_netinfo+3), a
	ld	hl, (_netinfo)
	push	hl
	call	_usb_ResetDevice
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	bc, -613
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	jq	BB28_5
BB28_5:
	ld	a, (_netinfo+4)
	ld	l, 1
	xor	a, l
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB28_7
	jq	BB28_6
BB28_6:
	call	_usb_WaitForEvents
	ld	bc, -613
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	jq	BB28_5
BB28_7:
	ld	hl, (_netinfo)
	ld	(ix - 3), de
	ld	de, -616
	lea	iy, ix
	add	iy, de
	ld	bc, (iy)
	push	bc
	ld	bc, 512
	push	bc
	ld	de, (ix - 3)
	push	de
	ld	de, 0
	push	de
	ld	de, 2
	push	de
	push	hl
	call	_usb_GetDescriptor
	ld	hl, 18
	add	hl, sp
	ld	sp, hl
	ld	bc, -610
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	hl, (iy + 2)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB28_9
	jq	BB28_8
BB28_8:
	ld	hl, 10
	ld	(ix - 9), hl
	jq	BB28_68
BB28_9:
	ld	(iy), 0
	jq	BB28_10
BB28_10:
	or	a, a
	sbc	hl, hl
	ld	l, (iy)
	ld	de, (iy + 2)
	or	a, a
	sbc	hl, de
	jq	nc, BB28_32
	jq	BB28_11
BB28_11:
	ld	de, 0
	ld	e, (iy)
	ld	bc, -613
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	pop	iy
	add	iy, de
	ld	a, (iy + 1)
	cp	a, 4
	jq	nz, BB28_23
	jq	BB28_12
BB28_12:
	ld	de, 0
	ld	bc, -610
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	e, (iy)
	push	hl
	pop	iy
	add	iy, de
	ld	a, (iy + 5)
	cp	a, -32
	jq	nz, BB28_16
	jq	BB28_13
BB28_13:
	ld	de, 0
	ld	bc, -610
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	e, (iy)
	push	hl
	pop	iy
	add	iy, de
	ld	a, (iy + 6)
	cp	a, 1
	jq	nz, BB28_16
	jq	BB28_14
BB28_14:
	ld	de, 0
	ld	bc, -610
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	e, (iy)
	push	hl
	pop	iy
	add	iy, de
	ld	a, (iy + 7)
	cp	a, 3
	jq	nz, BB28_16
	jq	BB28_15
BB28_15:
	ld	bc, -610
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy + 1), 1
	ld	de, 0
	ld	e, (iy)
	push	hl
	pop	iy
	add	iy, de
	ld	a, (iy + 2)
	ld	(_netinfo+7), a
	jq	BB28_22
BB28_16:
	ld	de, 0
	ld	bc, -610
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	e, (iy)
	push	hl
	pop	iy
	add	iy, de
	ld	a, (iy + 5)
	cp	a, 10
	jq	nz, BB28_20
	jq	BB28_17
BB28_17:
	ld	de, 0
	ld	bc, -610
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	e, (iy)
	push	hl
	pop	iy
	add	iy, de
	ld	a, (iy + 6)
	or	a, a
	jq	nz, BB28_20
	jq	BB28_18
BB28_18:
	ld	de, 0
	ld	bc, -610
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	e, (iy)
	push	hl
	pop	iy
	add	iy, de
	ld	a, (iy + 7)
	or	a, a
	jq	nz, BB28_20
	jq	BB28_19
BB28_19:
	ld	bc, -610
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy + 1), 2
	ld	de, 0
	ld	e, (iy)
	push	hl
	pop	iy
	add	iy, de
	ld	a, (iy + 2)
	ld	(_netinfo+6), a
	jq	BB28_21
BB28_20:
	ld	bc, -610
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	(iy + 1), 0
	jq	BB28_21
BB28_21:
	jq	BB28_22
BB28_22:
	jq	BB28_31
BB28_23:
	ld	de, 0
	ld	bc, -610
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	e, (iy)
	push	hl
	pop	iy
	add	iy, de
	ld	a, (iy + 1)
	cp	a, 5
	jq	nz, BB28_30
	jq	BB28_24
BB28_24:
	ld	bc, -610
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	a, (iy + 1)
	cp	a, 1
	jq	nz, BB28_26
	jq	BB28_25
BB28_25:
	ld	de, 0
	ld	e, (iy)
	ld	bc, -613
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	add	iy, de
	ld	a, (iy + 2)
	and	a, 127
	ld	(_netinfo+9), a
	jq	BB28_29
BB28_26:
	ld	a, (iy + 1)
	cp	a, 2
	jq	nz, BB28_28
	jq	BB28_27
BB28_27:
	ld	de, 0
	ld	bc, -610
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	e, (iy)
	ld	bc, -613
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	add	iy, de
	ld	a, (iy + 2)
	and	a, 127
	ld	(_netinfo+8), a
	jq	BB28_28
BB28_28:
	jq	BB28_29
BB28_29:
	jq	BB28_30
BB28_30:
	jq	BB28_31
BB28_31:
	ld	de, 0
	ld	bc, -610
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	e, (iy)
	lea	bc, iy
	ld	(ix - 3), bc
	ld	bc, -613
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	add	iy, de
	ld	l, (iy)
	ld	bc, (ix - 3)
	push	bc
	pop	iy
	ld	a, (iy)
	add	a, l
	ld	(iy), a
	jq	BB28_10
BB28_32:
	ld	a, (_netinfo+9)
	or	a, a
	jq	z, BB28_34
	jq	BB28_33
BB28_33:
	ld	a, (_netinfo+8)
	or	a, a
	jq	nz, BB28_35
	jq	BB28_34
BB28_34:
	xor	a, a
	ld	(_netinfo+3), a
	ld	hl, 1
	ld	(ix - 9), hl
	jq	BB28_68
BB28_35:
	ld	hl, (_netinfo)
	ld	de, (iy + 2)
	push	de
	ld	bc, -613
	lea	iy, ix
	add	iy, bc
	ld	de, (iy)
	push	de
	push	hl
	call	_usb_SetConfiguration
	ld	iy, 9
	add	iy, sp
	ld	sp, iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB28_37
	jq	BB28_36
BB28_36:
	ld	hl, 10
	ld	(ix - 9), hl
	jq	BB28_68
BB28_37:
	xor	a, a
	ld	(_netinfo+5), a
	ld	bc, -613
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	ld	bc, -625
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	ld	bc, 8
	ldir
	ld	bc, -610
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	(iy + 11), 24
	ld	bc, -613
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	lea	de, iy + 8
	ld	bc, -628
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	ld	bc, 24
	ldir
	jq	BB28_38
BB28_38:
	ld	hl, (_netinfo)
	ld	de, 0
	push	de
	push	hl
	call	_usb_GetDeviceEndpoint
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	bc, -616
	lea	iy, ix
	add	iy, bc
	ld	de, (iy)
	push	de
	ld	de, 3
	push	de
	ld	de, 0
	push	de
	push	ix
	ld	bc, -613
	add	ix, bc
	ld	de, (ix)
	pop	ix
	push	de
	push	hl
	call	_usb_Transfer
	ld	hl, 15
	add	hl, sp
	ld	sp, hl
	jq	BB28_39
BB28_39:
	ld	bc, -610
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	hl, (iy + 2)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB28_38
	jq	BB28_40
BB28_40:
	ld	bc, -613
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	ld	bc, -619
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	ld	bc, 8
	ldir
	jq	BB28_41
BB28_41:
	ld	hl, (_netinfo)
	ld	de, 0
	push	de
	push	hl
	call	_usb_GetDeviceEndpoint
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	bc, -616
	lea	iy, ix
	add	iy, bc
	ld	de, (iy)
	push	de
	ld	de, 3
	push	de
	ld	de, 0
	push	de
	push	ix
	ld	bc, -613
	add	ix, bc
	ld	de, (ix)
	pop	ix
	push	de
	push	hl
	call	_usb_Transfer
	ld	hl, 15
	add	hl, sp
	ld	sp, hl
	jq	BB28_42
BB28_42:
	ld	bc, -610
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	hl, (iy + 2)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, 1
	jq	z, BB28_46
	jq	BB28_43
BB28_43:
	ld	hl, (iy + 13)
	ld	e, (iy + 16)
	ld	bc, 2
	ld	a, -128
	call	__lcmpu
	ld	a, 1
	ld	l, 0
	jq	nz, BB28_45
	ld	a, l
BB28_45:
	jq	BB28_46
BB28_46:
	bit	0, a
	jq	nz, BB28_41
	jq	BB28_47
BB28_47:
	ld	bc, -613
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	push	ix
	ld	bc, -625
	add	ix, bc
	ld	hl, (ix)
	pop	ix
	ld	bc, 8
	ldir
	ld	(iy + 11), 32
	ld	bc, -613
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	lea	de, iy + 8
	ld	bc, -622
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	ld	bc, 32
	ldir
	jq	BB28_48
BB28_48:
	ld	hl, (_netinfo)
	ld	de, 0
	push	de
	push	hl
	call	_usb_GetDeviceEndpoint
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	bc, -616
	lea	iy, ix
	add	iy, bc
	ld	de, (iy)
	push	de
	ld	de, 3
	push	de
	ld	de, 0
	push	de
	push	ix
	ld	bc, -613
	add	ix, bc
	ld	de, (ix)
	pop	ix
	push	de
	push	hl
	call	_usb_Transfer
	ld	hl, 15
	add	hl, sp
	ld	sp, hl
	jq	BB28_49
BB28_49:
	ld	bc, -610
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	hl, (iy + 2)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB28_48
	jq	BB28_50
BB28_50:
	ld	bc, -613
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	ld	bc, -619
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	ld	bc, 8
	ldir
	jq	BB28_51
BB28_51:
	ld	hl, (_netinfo)
	ld	de, 0
	push	de
	push	hl
	call	_usb_GetDeviceEndpoint
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	bc, -616
	lea	iy, ix
	add	iy, bc
	ld	de, (iy)
	push	de
	ld	de, 3
	push	de
	ld	de, 0
	push	de
	push	ix
	ld	bc, -613
	add	ix, bc
	ld	de, (ix)
	pop	ix
	push	de
	push	hl
	call	_usb_Transfer
	ld	hl, 15
	add	hl, sp
	ld	sp, hl
	jq	BB28_52
BB28_52:
	ld	bc, -610
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	hl, (iy + 2)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, 1
	jq	z, BB28_56
	jq	BB28_53
BB28_53:
	ld	hl, (iy + 13)
	ld	e, (iy + 16)
	ld	bc, 5
	ld	a, -128
	call	__lcmpu
	ld	a, 1
	ld	l, 0
	jq	nz, BB28_55
	ld	a, l
BB28_55:
	jq	BB28_56
BB28_56:
	bit	0, a
	jq	nz, BB28_51
	jq	BB28_57
BB28_57:
	call	_dhcp_init
	jq	BB28_67
BB28_58:
	ld	de, 4
	ld	hl, (ix - 12)
	or	a, a
	sbc	hl, de
	jq	nz, BB28_60
	jq	BB28_59
BB28_59:
	ld	a, 1
	ld	(_netinfo+4), a
	jq	BB28_66
BB28_60:
	ld	de, 3
	ld	hl, (ix - 12)
	or	a, a
	sbc	hl, de
	jq	nz, BB28_62
	jq	BB28_61
BB28_61:
	xor	a, a
	ld	(_netinfo+4), a
	jq	BB28_65
BB28_62:
	ld	de, 1
	ld	hl, (ix - 12)
	or	a, a
	sbc	hl, de
	jq	nz, BB28_64
	jq	BB28_63
BB28_63:
	xor	a, a
	ld	(_netinfo+3), a
	ld	hl, 36106
	push	hl
	ld	hl, 0
	push	hl
	push	hl
	ld	hl, _usbHandler
	push	hl
	call	_usb_Init
	ld	hl, 12
	add	hl, sp
	ld	sp, hl
	jq	BB28_64
BB28_64:
	jq	BB28_65
BB28_65:
	jq	BB28_66
BB28_66:
	jq	BB28_67
BB28_67:
	or	a, a
	sbc	hl, hl
	ld	(ix - 9), hl
	jq	BB28_68
BB28_68:
	ld	hl, (ix - 9)
	ld	iy, 628
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_getMyIPAddr
_web_getMyIPAddr:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, (_IP_ADDR)
	ld	a, (_IP_ADDR+3)
	ld	e, a
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_Connected
_web_Connected:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	l, 0
	ld	a, (_netinfo+3)
	ld	e, 1
	xor	a, e
	bit	0, a
	jq	z, BB30_1
	jq	BB30_7
BB30_1:
	ld	a, (_netinfo+4)
	ld	e, 1
	xor	a, e
	bit	0, a
	jq	z, BB30_2
	jq	BB30_7
BB30_2:
	ld	a, (_netinfo+9)
	or	a, a
	jq	nz, BB30_3
	jq	BB30_7
BB30_3:
	ld	a, (_netinfo+8)
	or	a, a
	jq	z, BB30_7
	jq	BB30_4
BB30_4:
	ld	hl, (_IP_ADDR)
	ld	a, (_IP_ADDR+3)
	ld	e, a
	call	__lcmpzero
	ld	l, 1
	ld	a, 0
	jq	nz, BB30_6
	ld	l, a
BB30_6:
	jq	BB30_7
BB30_7:
	ld	a, l
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_WaitForEvents
_web_WaitForEvents:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -670
	add	hl, sp
	ld	sp, hl
	ld	bc, -658
	lea	iy, ix
	add	iy, bc
	ld	de, -851900
	lea	bc, iy + 10
	lea	hl, iy + 7
	ld	(ix - 3), de
	push	ix
	ld	de, -667
	add	ix, de
	ld	(ix), hl
	pop	ix
	ld	hl, (_send_queue)
	ld	(ix - 12), hl
	ld	de, -664
	lea	hl, ix
	add	hl, de
	ld	(hl), bc
	ld	(iy + 7), bc
	lea	bc, iy
	ld	de, (ix - 3)
	push	de
	pop	hl
	ld	hl, (hl)
	push	de
	pop	iy
	ld	a, (iy + 3)
	push	bc
	pop	iy
	ld	(iy + 3), hl
	ld	(iy + 6), a
	ld	a, (_netinfo+3)
	bit	0, a
	jq	nz, BB31_2
	jq	BB31_1
BB31_1:
	call	_usb_HandleEvents
	ld	(ix - 9), hl
	jq	BB31_15
BB31_2:
	ld	hl, (_netinfo)
	ld	a, (_netinfo+8)
	or	a, -128
	ld	e, a
	push	de
	push	hl
	ld	bc, -661
	lea	hl, ix
	add	hl, bc
	ld	(hl), iy
	call	_usb_GetDeviceEndpoint
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	bc, -667
	lea	iy, ix
	add	iy, bc
	ld	de, (iy)
	push	de
	ld	de, _packets_callback
	push	de
	ld	de, 636
	push	de
	push	ix
	ld	bc, -664
	add	ix, bc
	ld	de, (ix)
	pop	ix
	push	de
	push	hl
	call	_usb_ScheduleTransfer
	ld	iy, 15
	add	iy, sp
	ld	sp, iy
	ld	bc, -661
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy), hl
	ld	hl, (iy)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB31_4
	jq	BB31_3
BB31_3:
	ld	hl, (iy)
	ld	(ix - 9), hl
	jq	BB31_15
BB31_4:
	jq	BB31_5
BB31_5:
	ld	hl, (iy + 7)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB31_14
	jq	BB31_6
BB31_6:
	ld	hl, (iy + 3)
	ld	e, (iy + 6)
	ld	bc, 7
	xor	a, a
	call	__ladd
	push	hl
	pop	bc
	ld	a, e
	ld	hl, -851900
	push	hl
	pop	iy
	ld	hl, (iy)
	ld	e, (iy + 3)
	call	__lcmpu
	jq	c, BB31_8
	jq	BB31_7
BB31_7:
	ld	hl, 9
	ld	(ix - 9), hl
	jq	BB31_15
BB31_8:
	jq	BB31_9
BB31_9:
	ld	hl, (ix - 12)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB31_13
	jq	BB31_10
BB31_10:
	ld	iy, (ix - 12)
	ld	bc, (iy + 6)
	ld	a, (iy + 9)
	ld	iy, -851900
	ld	hl, (iy)
	ld	e, (iy + 3)
	call	__lcmpu
	jq	c, BB31_12
	jq	BB31_11
BB31_11:
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	bc, 1
	xor	a, a
	call	__ladd
	ld	iy, (ix - 12)
	ld	(iy + 6), hl
	ld	(iy + 9), e
	ld	iy, (ix - 12)
	ld	hl, (iy + 10)
	ld	de, -670
	lea	iy, ix
	add	iy, de
	ld	(iy), hl
	ld	iy, (ix - 12)
	ld	de, (iy + 3)
	ld	hl, (ix - 12)
	ld	hl, (hl)
	ld	bc, 0
	push	bc
	ld	bc, 3
	push	bc
	push	hl
	push	de
	ld	bc, -670
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	call	_usb_Transfer
	ld	hl, 15
	add	hl, sp
	ld	sp, hl
	jq	BB31_12
BB31_12:
	ld	iy, (ix - 12)
	ld	hl, (iy + 19)
	ld	(ix - 12), hl
	jq	BB31_9
BB31_13:
	call	_usb_HandleEvents
	ld	bc, -661
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy), hl
	jq	BB31_5
BB31_14:
	ld	hl, (iy)
	ld	(ix - 9), hl
	jq	BB31_15
BB31_15:
	ld	hl, (ix - 9)
	ld	iy, 670
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_RequestPort
_web_RequestPort:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -2
	add	hl, sp
	ld	sp, hl
	ld	iy, _web_RequestPort.next_port
	ld.sis	de, 0
	ld	hl, (iy)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jq	z, BB32_2
	jq	BB32_1
BB32_1:
	ld	hl, (iy)
	ld	e, l
	ld	d, h
	inc.sis	de
	ld	(iy), e
	ld	(iy + 1), d
	ld	(ix - 2), l
	ld	(ix - 1), h
	jq	BB32_3
BB32_2:
	ld	(ix - 2), e
	ld	(ix - 1), d
	jq	BB32_3
BB32_3:
	ld	hl, (ix - 2)
	ld	iy, 2
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	public	_web_UnlistenPort
_web_UnlistenPort:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -11
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, 0
	ld	(ix - 2), l
	ld	(ix - 1), h
	ld	hl, (_listened_ports)
	ld	(ix - 5), hl
	ld	(ix - 8), de
	ld	(ix - 11), de
	jq	BB33_1
BB33_1:
	ld	hl, (ix - 5)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB33_8
	jq	BB33_2
BB33_2:
	ld	iy, (ix - 5)
	ld	hl, (iy + 8)
	ld	(ix - 11), hl
	ld	hl, (ix - 5)
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, (ix - 2)
	ld	bc, 0
	ld	c, e
	ld	b, d
	or	a, a
	sbc	hl, bc
	jq	nz, BB33_7
	jq	BB33_3
BB33_3:
	ld	hl, (ix - 8)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB33_5
	jq	BB33_4
BB33_4:
	ld	iy, (ix - 5)
	ld	hl, (iy + 8)
	ld	iy, (ix - 8)
	ld	(iy + 8), hl
	jq	BB33_6
BB33_5:
	ld	iy, (ix - 5)
	ld	hl, (iy + 8)
	ld	(_listened_ports), hl
	jq	BB33_6
BB33_6:
	ld	hl, (ix - 5)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	jq	BB33_7
BB33_7:
	ld	hl, (ix - 5)
	ld	(ix - 8), hl
	ld	hl, (ix - 11)
	ld	(ix - 5), hl
	jq	BB33_1
BB33_8:
	ld	hl, 11
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_fetch_http_msg
_fetch_http_msg:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -249
	add	hl, sp
	ld	sp, hl
	ld	de, -151
	lea	iy, ix
	add	iy, de
	ld	bc, (ix + 6)
	ld	a, (ix + 9)
	ld	de, 1
	lea	hl, ix - 77
	ld	(ix - 3), de
	push	ix
	ld	de, -166
	add	ix, de
	ld	(ix), hl
	pop	ix
	lea	hl, ix - 106
	push	ix
	ld	de, -169
	add	ix, de
	ld	(ix), hl
	pop	ix
	lea	hl, ix - 118
	push	ix
	ld	de, -163
	add	ix, de
	ld	(ix), hl
	pop	ix
	ld	de, -130
	lea	hl, ix
	add	hl, de
	push	ix
	ld	de, -157
	add	ix, de
	ld	(ix), hl
	pop	ix
	ld	de, -154
	lea	hl, ix
	add	hl, de
	ld	(hl), iy
	lea	hl, iy + 5
	ld	(ix - 11), c
	ld	(ix - 10), b
	ld	(ix - 12), a
	ld	bc, (ix + 12)
	ld	(ix - 15), bc
	ld	bc, (ix + 15)
	ld	(ix - 18), bc
	ld	bc, (ix + 18)
	ld	(ix - 21), bc
	ld	a, (ix - 12)
	cp	a, 6
	ld	de, (ix - 3)
	jq	z, BB34_2
	jq	BB34_1
BB34_1:
	ld	(ix - 9), de
	jq	BB34_143
BB34_2:
	ld	bc, -160
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	hl, (ix - 15)
	ld	(ix - 24), hl
	ld	hl, (ix - 21)
	ld	(ix - 27), hl
	ld	hl, -851900
	push	hl
	pop	iy
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	bc, 7
	xor	a, a
	call	__ladd
	ld	iy, (ix - 27)
	ld	(iy + 10), hl
	ld	(iy + 13), e
	ld	iy, (ix - 24)
	ld	hl, (iy + 12)
	ld	a, l
	and	a, 0
	ld	e, a
	ld	a, h
	and	a, 2
	ld	d, a
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	a, h
	or	a, a
	sbc	hl, hl
	cp	a, h
	jq	z, BB34_4
	jq	BB34_3
BB34_3:
	ld	iy, (ix - 24)
	lea	hl, iy + 4
	push	hl
	call	_getBigEndianValue
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	bc, 1
	xor	a, a
	call	__ladd
	ld	iy, (ix - 27)
	ld	(iy + 26), hl
	ld	(iy + 29), e
	ld	iy, (ix - 27)
	ld	hl, (iy + 26)
	ld	a, (iy + 29)
	ld	iy, (ix - 27)
	ld	(iy + 18), hl
	ld	(iy + 21), a
	ld	iy, (ix - 27)
	ld	(iy + 8), 1
	ld	iy, (ix - 27)
	ld	hl, (iy)
	push	ix
	ld	de, -187
	add	ix, de
	ld	(ix), hl
	pop	ix
	ld	d, (iy + 3)
	ld	iy, (ix - 27)
	ld	hl, (iy + 4)
	ld	(ix - 3), bc
	ld	bc, -203
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 6)
	ld	bc, -221
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 14)
	push	ix
	ld	bc, -245
	add	ix, bc
	ld	(ix), hl
	pop	ix
	ld	e, (iy + 17)
	ld	iy, (ix - 27)
	ld	hl, (iy + 18)
	ld	a, (iy + 21)
	ld	bc, (ix - 3)
	ld	bc, 0
	push	bc
	ld	iy, 0
	push	iy
	ld	bc, 16
	push	bc
	ld	c, a
	push	bc
	push	hl
	ld	l, e
	push	hl
	ld	bc, -245
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	bc, -221
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	bc, -203
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	l, d
	push	hl
	ld	bc, -187
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	push	iy
	ld	hl, 0
	push	hl
	call	_web_SendTCPSegment
	ld	hl, 39
	add	hl, sp
	ld	sp, hl
	jq	BB34_4
BB34_4:
	ld	iy, (ix - 24)
	lea	hl, iy + 8
	push	hl
	call	_getBigEndianValue
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 31), hl
	ld	(ix - 28), e
	ld	hl, (ix - 31)
	ld	e, (ix - 28)
	ld	iy, (ix - 27)
	ld	bc, (iy + 22)
	ld	a, (iy + 25)
	call	__lsub
	push	hl
	pop	bc
	ld	a, e
	ld	iy, (ix - 27)
	ld	hl, (iy + 30)
	ld	e, (iy + 33)
	call	__lcmpu
	ld	bc, 0
	jq	nc, BB34_10
	jq	BB34_5
BB34_5:
	ld	iy, (ix - 24)
	ld	hl, (iy + 12)
	ld	a, l
	and	a, 0
	ld	e, a
	ld	a, h
	and	a, 16
	ld	d, a
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	a, h
	cp	a, b
	jq	z, BB34_10
	jq	BB34_6
BB34_6:
	ld	hl, (ix - 27)
	ld	de, (ix - 31)
	ld	a, (ix - 28)
	ld	c, a
	push	bc
	push	de
	push	hl
	call	_fetch_ack
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 27)
	bit	0, (iy + 8)
	jq	nz, BB34_9
	jq	BB34_7
BB34_7:
	ld	iy, (ix - 27)
	ld	l, 1
	ld	a, (iy + 9)
	xor	a, l
	bit	0, a
	jq	nz, BB34_9
	jq	BB34_8
BB34_8:
	ld	iy, (ix - 27)
	ld	hl, (iy + 4)
	push	hl
	call	_web_UnlistenPort
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 27)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	jq	BB34_9
BB34_9:
	ld	bc, 0
	jq	BB34_10
BB34_10:
	ld	iy, (ix - 24)
	ld	hl, (iy + 12)
	ld	a, l
	and	a, 0
	ld	e, a
	ld	a, h
	and	a, 1
	ld	d, a
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	a, h
	cp	a, b
	jq	z, BB34_15
	jq	BB34_11
BB34_11:
	ld	iy, (ix - 27)
	ld	(iy + 8), 0
	ld	iy, (ix - 27)
	ld	l, 1
	ld	a, (iy + 9)
	xor	a, l
	bit	0, a
	jq	nz, BB34_13
	jq	BB34_12
BB34_12:
	ld	iy, (ix - 27)
	ld	hl, (iy)
	push	ix
	ld	de, -178
	add	ix, de
	ld	(ix), hl
	pop	ix
	ld	a, (iy + 3)
	ld	de, -188
	lea	hl, ix
	add	hl, de
	ld	(hl), a
	ld	iy, (ix - 27)
	ld	hl, (iy + 4)
	ld	de, -212
	lea	iy, ix
	add	iy, de
	ld	(iy), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 6)
	ld	de, -230
	lea	iy, ix
	add	iy, de
	ld	(iy), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 14)
	push	ix
	ld	de, -236
	add	ix, de
	ld	(ix), hl
	pop	ix
	ld	a, (iy + 17)
	ld	de, -246
	lea	hl, ix
	add	hl, de
	ld	(hl), a
	ld	iy, (ix - 27)
	ld	hl, (iy + 18)
	ld	a, (iy + 21)
	ld	iy, 0
	push	iy
	push	bc
	push	bc
	pop	de
	ld	bc, 16
	push	bc
	ld	c, a
	push	bc
	push	hl
	ld	bc, -246
	lea	hl, ix
	add	hl, bc
	ld	l, (hl)
	push	hl
	ld	bc, -236
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	bc, -230
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	bc, -212
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	bc, -188
	lea	hl, ix
	add	hl, bc
	ld	l, (hl)
	push	hl
	ld	bc, -178
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	push	de
	push	iy
	call	_web_SendTCPSegment
	ld	hl, 39
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 4)
	push	hl
	call	_web_UnlistenPort
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 27)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	jq	BB34_14
BB34_13:
	ld	hl, (ix - 27)
	ld	de, 0
	push	de
	pop	iy
	push	iy
	push	bc
	ld	de, 17
	push	de
	push	hl
	push	bc
	push	iy
	call	_add_tcp_queue
	ld	hl, 18
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 27)
	ld	(iy + 9), 1
	jq	BB34_14
BB34_14:
	or	a, a
	sbc	hl, hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_15:
	ld	hl, (ix - 15)
	ld	bc, -194
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	iy, (ix - 15)
	ld	de, (iy + 12)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	c, 4
	call	__ishrs
	ld	bc, 15
	call	__iand
	push	hl
	pop	bc
	ld	hl, 4
	call	__imulu
	push	hl
	pop	de
	ld	(ix - 3), bc
	ld	bc, -194
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	add	hl, de
	ld	(ix - 34), hl
	ld	hl, (ix - 15)
	ld	de, (ix - 18)
	add	hl, de
	ld	de, (ix - 34)
	or	a, a
	sbc	hl, de
	ld	bc, (ix - 3)
	jq	nz, BB34_17
	jq	BB34_16
BB34_16:
	or	a, a
	sbc	hl, hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_17:
	ld	hl, (ix - 18)
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 37), hl
	ld	hl, (ix - 37)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB34_19
	jq	BB34_18
BB34_18:
	ld	hl, (ix - 27)
	push	hl
	call	_wipe_data
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 27)
	ld	hl, 6
	ld	(iy + 59), hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_19:
	ld	hl, (ix - 37)
	ld	de, (ix - 15)
	ld	bc, (ix - 18)
	push	bc
	push	de
	push	hl
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	hl, 13
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 40), hl
	ld	hl, (ix - 40)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB34_21
	jq	BB34_20
BB34_20:
	ld	hl, (ix - 27)
	push	hl
	call	_wipe_data
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 27)
	ld	hl, 6
	ld	(iy + 59), hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_21:
	ld	iy, (ix - 37)
	lea	hl, iy + 4
	push	hl
	call	_getBigEndianValue
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	iy, (ix - 27)
	ld	bc, (iy + 26)
	ld	a, (iy + 29)
	call	__lsub
	ld	iy, (ix - 40)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	de, (ix - 18)
	ld	iy, (ix - 37)
	ld	bc, (iy + 12)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	c, 4
	call	__ishrs
	ld	bc, 15
	call	__iand
	push	hl
	pop	bc
	ld	hl, 4
	call	__imulu
	push	hl
	pop	bc
	ex	de, hl
	or	a, a
	sbc	hl, bc
	ld	iy, (ix - 40)
	ld	(iy + 4), hl
	ld	hl, (ix - 37)
	ld	iy, (ix - 40)
	ld	(iy + 7), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 49)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB34_23
	jq	BB34_22
BB34_22:
	ld	iy, (ix - 40)
	ld	hl, 0
	ld	(iy + 10), hl
	ld	hl, (ix - 40)
	ld	iy, (ix - 27)
	ld	(iy + 49), hl
	ld	iy, (ix - 40)
	ld	de, (iy + 4)
	ld	iy, (ix - 27)
	ld	hl, (iy + 38)
	add	hl, de
	ld	(iy + 38), hl
	ld	bc, 0
	jq	BB34_38
BB34_23:
	ld	iy, (ix - 27)
	ld	hl, (iy + 49)
	ld	(ix - 43), hl
	ld	hl, 0
	ld	(ix - 46), hl
	ld	bc, 0
	jq	BB34_24
BB34_24:
	ld	hl, (ix - 43)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, 0
	jq	z, BB34_28
	jq	BB34_25
BB34_25:
	ld	iy, (ix - 43)
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	iy, (ix - 40)
	ld	bc, (iy)
	ld	a, (iy + 3)
	call	__lcmpu
	ld	a, 1
	ld	l, 0
	jq	c, BB34_27
	ld	a, l
BB34_27:
	ld	bc, 0
	jq	BB34_28
BB34_28:
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB34_30
	jq	BB34_29
BB34_29:
	ld	hl, (ix - 43)
	ld	(ix - 46), hl
	ld	iy, (ix - 43)
	ld	hl, (iy + 10)
	ld	(ix - 43), hl
	jq	BB34_24
BB34_30:
	ld	hl, (ix - 43)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB34_33
	jq	BB34_31
BB34_31:
	ld	iy, (ix - 43)
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	iy, (ix - 40)
	ld	bc, (iy)
	ld	a, (iy + 3)
	call	__lcmpu
	ld	bc, 0
	jq	nz, BB34_33
	jq	BB34_32
BB34_32:
	ld	iy, (ix - 27)
	ld	hl, (iy)
	push	ix
	ld	de, -181
	add	ix, de
	ld	(ix), hl
	pop	ix
	ld	d, (iy + 3)
	ld	iy, (ix - 27)
	ld	hl, (iy + 4)
	ld	(ix - 3), bc
	ld	bc, -209
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 6)
	ld	bc, -227
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 14)
	push	ix
	ld	bc, -239
	add	ix, bc
	ld	(ix), hl
	pop	ix
	ld	e, (iy + 17)
	ld	iy, (ix - 27)
	ld	hl, (iy + 18)
	ld	a, (iy + 21)
	ld	iy, 0
	push	iy
	ld	bc, (ix - 3)
	push	bc
	push	bc
	pop	iy
	ld	bc, 16
	push	bc
	ld	c, a
	push	bc
	push	hl
	ld	l, e
	push	hl
	ld	bc, -239
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	bc, -227
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	bc, -209
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	l, d
	push	hl
	ld	bc, -181
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	push	iy
	ld	hl, 0
	push	hl
	call	_web_SendTCPSegment
	ld	hl, 39
	add	hl, sp
	ld	sp, hl
	or	a, a
	sbc	hl, hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_33:
	ld	hl, (ix - 43)
	ld	iy, (ix - 40)
	ld	(iy + 10), hl
	ld	hl, (ix - 46)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB34_35
	jq	BB34_34
BB34_34:
	ld	hl, (ix - 40)
	ld	iy, (ix - 46)
	ld	(iy + 10), hl
	jq	BB34_36
BB34_35:
	ld	hl, (ix - 40)
	ld	iy, (ix - 27)
	ld	(iy + 49), hl
	jq	BB34_36
BB34_36:
	ld	iy, (ix - 40)
	ld	de, (iy + 4)
	ld	iy, (ix - 27)
	ld	hl, (iy + 38)
	add	hl, de
	ld	(iy + 38), hl
	jq	BB34_37
BB34_37:
	jq	BB34_38
BB34_38:
	ld	iy, (ix - 27)
	ld	iy, (iy + 49)
	ld	hl, (iy)
	ld	e, (iy + 3)
	call	__lcmpzero
	jq	z, BB34_40
	jq	BB34_39
BB34_39:
	ld	(ix - 9), bc
	jq	BB34_143
BB34_40:
	ld	iy, (ix - 27)
	ld	hl, (iy + 49)
	ld	(ix - 49), hl
	jq	BB34_41
BB34_41:
	ld	iy, (ix - 49)
	ld	hl, (iy + 10)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, 0
	jq	z, BB34_45
	jq	BB34_42
BB34_42:
	ld	iy, (ix - 49)
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	iy, (ix - 49)
	ld	bc, (iy + 4)
	xor	a, a
	call	__ladd
	ld	iy, (ix - 49)
	ld	iy, (iy + 10)
	ld	bc, (iy)
	ld	a, (iy + 3)
	call	__lcmpu
	ld	a, 1
	ld	l, 0
	jq	z, BB34_44
	ld	a, l
BB34_44:
	jq	BB34_45
BB34_45:
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB34_47
	jq	BB34_46
BB34_46:
	ld	iy, (ix - 49)
	ld	hl, (iy + 10)
	ld	(ix - 49), hl
	jq	BB34_41
BB34_47:
	ld	iy, (ix - 27)
	ld	hl, (iy + 18)
	ld	e, (iy + 21)
	ld	iy, (ix - 27)
	ld	bc, (iy + 26)
	ld	a, (iy + 29)
	call	__lsub
	ld	(ix - 3), bc
	ld	bc, -218
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	d, e
	ld	iy, (ix - 49)
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	iy, (ix - 49)
	ld	bc, (ix - 3)
	ld	bc, (iy + 4)
	xor	a, a
	call	__ladd
	push	hl
	pop	bc
	ld	a, e
	ld	(ix - 3), bc
	ld	bc, -218
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	ld	e, d
	ld	bc, (ix - 3)
	call	__lcmpu
	jq	z, BB34_49
	jq	BB34_48
BB34_48:
	ld	iy, (ix - 27)
	ld	hl, (iy + 26)
	ld	e, (iy + 29)
	ld	iy, (ix - 49)
	ld	bc, (iy)
	ld	a, (iy + 3)
	call	__ladd
	ld	iy, (ix - 49)
	ld	bc, (iy + 4)
	xor	a, a
	call	__ladd
	ld	iy, (ix - 27)
	ld	(iy + 18), hl
	ld	(iy + 21), e
	ld	iy, (ix - 27)
	ld	hl, (iy)
	push	ix
	ld	de, -184
	add	ix, de
	ld	(ix), hl
	pop	ix
	ld	d, (iy + 3)
	ld	iy, (ix - 27)
	ld	hl, (iy + 4)
	ld	(ix - 3), bc
	ld	bc, -206
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 6)
	ld	bc, -224
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 14)
	push	ix
	ld	bc, -242
	add	ix, bc
	ld	(ix), hl
	pop	ix
	ld	e, (iy + 17)
	ld	iy, (ix - 27)
	ld	hl, (iy + 18)
	ld	a, (iy + 21)
	ld	bc, (ix - 3)
	ld	bc, 0
	push	bc
	ld	iy, 0
	push	iy
	ld	bc, 16
	push	bc
	ld	c, a
	push	bc
	push	hl
	ld	l, e
	push	hl
	ld	bc, -242
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	bc, -224
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	bc, -206
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	l, d
	push	hl
	ld	bc, -184
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	push	iy
	ld	hl, 0
	push	hl
	call	_web_SendTCPSegment
	ld	hl, 39
	add	hl, sp
	ld	sp, hl
	jq	BB34_49
BB34_49:
	ld	iy, (ix - 27)
	ld	hl, (iy + 41)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB34_96
	jq	BB34_50
BB34_50:
	ld	iy, (ix - 27)
	ld	de, (iy + 47)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	e, 0
	ld	iy, (ix - 40)
	ld	bc, (iy)
	ld	a, (iy + 3)
	call	__lcmpu
	jq	nz, BB34_96
	jq	BB34_51
BB34_51:
	ld	hl, (ix - 40)
	ld	(ix - 52), hl
	jq	BB34_52
BB34_52:
	ld	iy, (ix - 40)
	ld	hl, (iy + 7)
	ld	(ix - 55), hl
	ld	hl, (ix - 55)
	ld	bc, -197
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	iy, (ix - 55)
	ld	de, (iy + 12)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	c, 4
	call	__ishrs
	ld	bc, 15
	call	__iand
	push	hl
	pop	bc
	ld	hl, 4
	call	__imulu
	push	hl
	pop	de
	ld	(ix - 3), bc
	ld	bc, -197
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	add	hl, de
	ld	(ix - 58), hl
	ld	hl, (ix - 58)
	ld	(ix - 61), hl
	ld	bc, -166
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	ld	hl, L___const.fetch_http_msg.cont_len
	ld	bc, (ix - 3)
	ld	bc, 16
	ldir
	ld	bc, -169
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	ld	hl, L___const.fetch_http_msg.cont_enc
	ld	bc, 29
	ldir
	jq	BB34_53
BB34_53:
	ld	iy, (ix - 61)
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	bc, 854541
	ld	a, 10
	call	__lcmpu
	ld	a, 1
	ld	l, 0
	jq	z, BB34_55
	ld	a, l
BB34_55:
	bit	0, a
	ld	a, 0
	jq	nz, BB34_59
	jq	BB34_56
BB34_56:
	ld	de, (ix - 55)
	ld	hl, (ix - 61)
	or	a, a
	sbc	hl, de
	ld	iy, (ix - 18)
	ld	de, -8388608
	add	iy, de
	add	hl, de
	lea	de, iy
	or	a, a
	sbc	hl, de
	ld	a, 1
	ld	l, 0
	jq	c, BB34_58
	ld	a, l
BB34_58:
	jq	BB34_59
BB34_59:
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB34_85
	jq	BB34_60
BB34_60:
	ld	iy, (ix - 61)
	lea	hl, iy + 2
	ld	(ix - 61), hl
	ld	hl, (ix - 61)
	ld	de, 15
	push	de
	ld	bc, -166
	lea	iy, ix
	add	iy, bc
	ld	de, (iy)
	push	de
	push	hl
	call	_memcmp
	ld	iy, 9
	add	iy, sp
	ld	sp, iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB34_72
	jq	BB34_61
BB34_61:
	ld	iy, (ix - 61)
	lea	hl, iy + 15
	ld	(ix - 61), hl
	jq	BB34_62
BB34_62:
	ld	hl, (ix - 61)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	de, 32
	or	a, a
	sbc	hl, de
	jq	nz, BB34_64
	jq	BB34_63
BB34_63:
	ld	hl, (ix - 61)
	inc	hl
	ld	(ix - 61), hl
	jq	BB34_62
BB34_64:
	jq	BB34_65
BB34_65:
	ld	hl, (ix - 61)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	de, -8388608
	add	hl, de
	ld	de, -8388560
	or	a, a
	sbc	hl, de
	ld	a, 0
	jq	c, BB34_69
	jq	BB34_66
BB34_66:
	ld	hl, (ix - 61)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	de, -8388608
	add	hl, de
	ld	de, -8388550
	or	a, a
	sbc	hl, de
	ld	a, 1
	ld	l, 0
	jq	c, BB34_68
	ld	a, l
BB34_68:
	jq	BB34_69
BB34_69:
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB34_71
	jq	BB34_70
BB34_70:
	ld	iy, (ix - 27)
	ld	hl, (iy + 35)
	ld	bc, 10
	call	__imulu
	push	hl
	pop	bc
	ld	hl, (ix - 61)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	de, 48
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	push	bc
	pop	hl
	add	hl, de
	ld	iy, (ix - 27)
	ld	(iy + 35), hl
	ld	hl, (ix - 61)
	inc	hl
	ld	(ix - 61), hl
	jq	BB34_65
BB34_71:
	jq	BB34_75
BB34_72:
	ld	hl, (ix - 61)
	ld	de, 28
	push	de
	ld	bc, -169
	lea	iy, ix
	add	iy, bc
	ld	de, (iy)
	push	de
	push	hl
	call	_memcmp
	ld	iy, 9
	add	iy, sp
	ld	sp, iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB34_74
	jq	BB34_73
BB34_73:
	ld	iy, (ix - 27)
	ld	(iy + 34), 1
	jq	BB34_74
BB34_74:
	jq	BB34_75
BB34_75:
	jq	BB34_76
BB34_76:
	ld	de, (ix - 55)
	ld	hl, (ix - 61)
	or	a, a
	sbc	hl, de
	ld	iy, (ix - 18)
	ld	de, -8388608
	add	iy, de
	add	hl, de
	lea	de, iy
	or	a, a
	sbc	hl, de
	ld	a, 0
	jq	nc, BB34_82
	jq	BB34_77
BB34_77:
	ld	hl, (ix - 61)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	de, 13
	or	a, a
	sbc	hl, de
	ld	a, 1
	jq	nz, BB34_81
	jq	BB34_78
BB34_78:
	ld	iy, (ix - 61)
	ld	a, (iy + 1)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	de, 10
	or	a, a
	sbc	hl, de
	ld	a, 1
	ld	l, 0
	jq	nz, BB34_80
	ld	a, l
BB34_80:
	jq	BB34_81
BB34_81:
	jq	BB34_82
BB34_82:
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB34_84
	jq	BB34_83
BB34_83:
	ld	hl, (ix - 61)
	inc	hl
	ld	(ix - 61), hl
	jq	BB34_76
BB34_84:
	jq	BB34_53
BB34_85:
	ld	iy, (ix - 27)
	ld	de, 65506
	ld	hl, (iy + 35)
	or	a, a
	sbc	hl, de
	jq	c, BB34_87
	jq	BB34_86
BB34_86:
	ld	hl, (ix - 27)
	push	hl
	call	_wipe_data
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 27)
	ld	hl, 6
	ld	(iy + 59), hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_87:
	ld	de, (ix - 55)
	ld	hl, (ix - 61)
	or	a, a
	sbc	hl, de
	ld	iy, (ix - 18)
	ld	de, -8388608
	add	iy, de
	add	hl, de
	lea	de, iy
	or	a, a
	sbc	hl, de
	jq	c, BB34_92
	jq	BB34_88
BB34_88:
	ld	iy, (ix - 52)
	ld	de, (iy + 4)
	ld	iy, (ix - 27)
	ld	bc, (iy + 47)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	add	hl, de
	ld	(iy + 47), l
	ld	(iy + 48), h
	ld	iy, (ix - 52)
	ld	hl, (iy + 10)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB34_91
	jq	BB34_89
BB34_89:
	ld	iy, (ix - 52)
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	iy, (ix - 52)
	ld	bc, (iy + 4)
	xor	a, a
	call	__ladd
	ld	iy, (ix - 52)
	ld	iy, (iy + 10)
	ld	bc, (iy)
	ld	a, (iy + 3)
	call	__lcmpu
	jq	nz, BB34_91
	jq	BB34_90
BB34_90:
	ld	iy, (ix - 52)
	ld	hl, (iy + 10)
	ld	(ix - 52), hl
	jq	BB34_52
BB34_91:
	or	a, a
	sbc	hl, hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_92:
	ld	iy, (ix - 61)
	lea	hl, iy + 4
	ld	(ix - 61), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 47)
	ld	iy, 0
	ex	de, hl
	ld	iyl, e
	ld	iyh, d
	ex	de, hl
	ld	de, (ix - 58)
	ld	hl, (ix - 61)
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	add	iy, de
	lea	hl, iy
	ld	iy, (ix - 27)
	ld	(iy + 41), hl
	ld	iy, (ix - 27)
	bit	0, (iy + 34)
	jq	nz, BB34_94
	jq	BB34_93
BB34_93:
	ld	iy, (ix - 27)
	ld	de, (iy + 41)
	ld	iy, (ix - 27)
	ld	hl, (iy + 35)
	add	hl, de
	ld	(iy + 35), hl
	jq	BB34_95
BB34_94:
	ld	iy, (ix - 52)
	ld	hl, (ix - 40)
	ld	de, (hl)
	ld	hl, (iy)
	or	a, a
	sbc	hl, de
	push	hl
	pop	bc
	ld	de, (ix - 58)
	ld	hl, (ix - 61)
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	push	bc
	pop	hl
	add	hl, de
	ld	iy, (ix - 27)
	ld	(iy + 44), hl
	jq	BB34_95
BB34_95:
	jq	BB34_96
BB34_96:
	ld	iy, (ix - 27)
	ld	de, -1
	ld	hl, (iy + 44)
	or	a, a
	sbc	hl, de
	jq	z, BB34_112
	jq	BB34_97
BB34_97:
	ld	iy, (ix - 27)
	ld	hl, (iy + 18)
	ld	e, (iy + 21)
	ld	iy, (ix - 27)
	ld	bc, (iy + 26)
	ld	a, (iy + 29)
	call	__lsub
	ld	(ix - 3), bc
	ld	bc, -215
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	d, e
	ld	iy, (ix - 40)
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	iy, (ix - 40)
	ld	bc, (ix - 3)
	ld	bc, (iy + 4)
	xor	a, a
	call	__ladd
	push	hl
	pop	bc
	ld	a, e
	ld	(ix - 3), bc
	ld	bc, -215
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	ld	e, d
	ld	bc, (ix - 3)
	call	__lcmpu
	jq	nz, BB34_112
	jq	BB34_98
BB34_98:
	ld	hl, (ix - 40)
	ld	(ix - 109), hl
	jq	BB34_99
BB34_99:
	ld	iy, (ix - 40)
	ld	hl, (iy + 7)
	ld	(ix - 112), hl
	ld	hl, (ix - 112)
	ld	bc, -200
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	iy, (ix - 112)
	ld	de, (iy + 12)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	c, 4
	call	__ishrs
	ld	bc, 15
	call	__iand
	push	hl
	pop	bc
	ld	hl, 4
	call	__imulu
	push	hl
	pop	de
	ld	(ix - 3), bc
	ld	bc, -200
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	add	hl, de
	ld	(ix - 115), hl
	ld	iy, (ix - 109)
	ld	de, (iy + 4)
	ld	iy, (ix - 27)
	ld	hl, (iy + 44)
	or	a, a
	sbc	hl, de
	ld	bc, (ix - 3)
	jq	c, BB34_101
	jq	BB34_100
BB34_100:
	ld	iy, (ix - 109)
	ld	de, (iy + 4)
	ld	iy, (ix - 27)
	ld	hl, (iy + 44)
	or	a, a
	sbc	hl, de
	ld	(iy + 44), hl
	jq	BB34_108
BB34_101:
	ld	hl, (ix - 115)
	ld	(ix - 118), hl
	jq	BB34_102
BB34_102:
	ld	iy, (ix - 27)
	ld	de, (iy + 44)
	ld	hl, (ix - 118)
	add	hl, de
	ld	(ix - 118), hl
	ld	bc, -163
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	call	_getChunkSize
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	de, 4
	add	hl, de
	ld	iy, (ix - 27)
	ld	(iy + 44), hl
	ld	iy, (ix - 27)
	ld	de, 4
	ld	hl, (iy + 44)
	or	a, a
	sbc	hl, de
	jq	nz, BB34_104
	jq	BB34_103
BB34_103:
	jq	BB34_117
BB34_104:
	ld	iy, (ix - 109)
	ld	de, (iy + 4)
	ld	bc, (ix - 115)
	ld	hl, (ix - 118)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	bc
	ex	de, hl
	or	a, a
	sbc	hl, bc
	push	hl
	pop	de
	ld	iy, (ix - 27)
	ld	hl, (iy + 44)
	or	a, a
	sbc	hl, de
	jq	c, BB34_106
	jq	BB34_105
BB34_105:
	ld	iy, (ix - 109)
	ld	de, (iy + 4)
	ld	bc, (ix - 115)
	ld	hl, (ix - 118)
	or	a, a
	sbc	hl, bc
	push	hl
	pop	bc
	ex	de, hl
	or	a, a
	sbc	hl, bc
	push	hl
	pop	de
	ld	iy, (ix - 27)
	ld	hl, (iy + 44)
	or	a, a
	sbc	hl, de
	ld	(iy + 44), hl
	jq	BB34_107
BB34_106:
	jq	BB34_102
BB34_107:
	jq	BB34_108
BB34_108:
	ld	iy, (ix - 109)
	ld	hl, (iy + 10)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB34_111
	jq	BB34_109
BB34_109:
	ld	iy, (ix - 109)
	ld	hl, (iy)
	ld	e, (iy + 3)
	ld	iy, (ix - 109)
	ld	bc, (iy + 4)
	xor	a, a
	call	__ladd
	ld	iy, (ix - 109)
	ld	iy, (iy + 10)
	ld	bc, (iy)
	ld	a, (iy + 3)
	call	__lcmpu
	jq	nz, BB34_111
	jq	BB34_110
BB34_110:
	ld	iy, (ix - 109)
	ld	hl, (iy + 10)
	ld	(ix - 109), hl
	jq	BB34_99
BB34_111:
	jq	BB34_112
BB34_112:
	ld	iy, (ix - 27)
	ld	hl, (iy + 35)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB34_115
	jq	BB34_113
BB34_113:
	ld	iy, (ix - 27)
	ld	hl, (iy + 35)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB34_116
	jq	BB34_114
BB34_114:
	ld	iy, (ix - 27)
	ld	de, (iy + 35)
	ld	iy, (ix - 27)
	ld	hl, (iy + 38)
	or	a, a
	sbc	hl, de
	jq	nc, BB34_116
	jq	BB34_115
BB34_115:
	or	a, a
	sbc	hl, hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_116:
	jq	BB34_117
BB34_117:
	ld	iy, (ix - 27)
	ld	de, 65506
	ld	hl, (iy + 38)
	or	a, a
	sbc	hl, de
	ld	hl, 1
	jq	c, BB34_119
	jq	BB34_118
BB34_118:
	ld	hl, (ix - 27)
	push	hl
	call	_wipe_data
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 27)
	ld	hl, 6
	ld	(iy + 59), hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_119:
	ld	de, 12
	push	de
	push	hl
	call	_calloc
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 121), hl
	ld	bc, -157
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	ld	hl, L___const.fetch_http_msg.varstorage_name
	ld	bc, 9
	ldir
	ld.sis	hl, 0
	ld	bc, -132
	lea	iy, ix
	add	iy, bc
	ld	(iy), l
	ld	(iy + 1), h
	jq	BB34_120
BB34_120:
	ld	bc, -132
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, -8388608
	add	hl, de
	ld	de, -8378609
	or	a, a
	sbc	hl, de
	ld	a, 0
	jq	nc, BB34_124
	jq	BB34_121
BB34_121:
	ld	hl, 0
	push	hl
	push	hl
	ld	bc, -157
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	ld	hl, 21
	push	hl
	call	_os_ChkFindSym
	ld	iy, 12
	add	iy, sp
	ld	sp, iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, 1
	ld	l, 0
	jq	nz, BB34_123
	ld	a, l
BB34_123:
	jq	BB34_124
BB34_124:
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB34_126
	jq	BB34_125
BB34_125:
	ld	bc, -132
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	inc.sis	hl
	ld	bc, -132
	lea	iy, ix
	add	iy, bc
	ld	(iy), l
	ld	(iy + 1), h
	ld	bc, -132
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, 10
	call	__irems
	ld	a, l
	add	a, 48
	ld	(ix - 123), a
	ld	(ix - 3), bc
	ld	bc, -132
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, (ix - 3)
	call	__idivs
	ld	a, l
	add	a, 48
	ld	(ix - 124), a
	ld	(ix - 3), bc
	ld	bc, -132
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, (ix - 3)
	ld	bc, 100
	call	__idivs
	ld	a, l
	add	a, 48
	ld	(ix - 125), a
	ld	(ix - 3), bc
	ld	bc, -132
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	bc, (ix - 3)
	ld	bc, 1000
	call	__idivs
	ld	a, l
	add	a, 48
	ld	(ix - 126), a
	jq	BB34_120
BB34_126:
	ld	bc, -132
	lea	hl, ix
	add	hl, bc
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, -8388608
	add	hl, de
	ld	de, -8378609
	or	a, a
	sbc	hl, de
	jq	c, BB34_128
	jq	BB34_127
BB34_127:
	ld	hl, (ix - 27)
	push	hl
	call	_wipe_data
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 121)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 27)
	ld	hl, 6
	ld	(iy + 59), hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_128:
	ld	iy, (ix - 27)
	ld	hl, (iy + 38)
	push	hl
	ld	bc, -157
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	call	_os_CreateAppVar
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	iy, (ix - 27)
	ld	iy, (iy + 55)
	ld	(iy), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 55)
	ld	hl, (hl)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB34_130
	jq	BB34_129
BB34_129:
	ld	hl, (ix - 27)
	push	hl
	call	_wipe_data
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 121)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix - 27)
	ld	hl, 6
	ld	(iy + 59), hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_130:
	ld	iy, (ix - 27)
	ld	hl, (iy + 49)
	ld	bc, -154
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy + 16), hl
	ld	hl, 0
	ld	(iy + 13), hl
	or	a, a
	sbc	hl, hl
	ld	(iy + 10), hl
	jq	BB34_131
BB34_131:
	ld	hl, (iy + 16)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB34_133
	jq	BB34_132
BB34_132:
	ld	bc, -154
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	iy, (iy + 16)
	ld	hl, (iy + 10)
	ld	bc, -154
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy + 13), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 55)
	ld	iy, (hl)
	lea	hl, iy + 2
	ld	bc, -154
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	de, (iy + 10)
	add	hl, de
	ld	bc, -172
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	bc, -154
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	iy, (iy + 16)
	ld	hl, (iy + 7)
	ld	bc, -191
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	bc, -154
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	iy, (iy + 16)
	ld	iy, (iy + 7)
	ld	de, (iy + 12)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	c, 4
	call	__ishrs
	ld	bc, 15
	call	__iand
	push	hl
	pop	bc
	ld	hl, 4
	call	__imulu
	push	hl
	pop	de
	ld	(ix - 3), bc
	ld	bc, -191
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	add	hl, de
	push	ix
	ld	bc, -154
	add	ix, bc
	ld	iy, (ix)
	pop	ix
	ld	iy, (iy + 16)
	ld	de, (iy + 4)
	push	de
	push	hl
	ld	de, -172
	lea	hl, ix
	add	hl, de
	ld	hl, (hl)
	push	hl
	ld	bc, (ix - 3)
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	bc, -154
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	iy, (iy + 16)
	ld	de, (iy + 4)
	ld	bc, -154
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	hl, (iy + 10)
	add	hl, de
	ld	bc, -154
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy + 10), hl
	ld	bc, -154
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	iy, (iy + 16)
	ld	hl, (iy + 7)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	bc, -154
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	hl, (iy + 16)
	push	hl
	call	_free
	ld	bc, -154
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (iy + 13)
	ld	(iy + 16), hl
	jq	BB34_131
BB34_133:
	ld	iy, (ix - 27)
	ld	hl, (iy + 55)
	ld	iy, (hl)
	ld	a, (iy + 11)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	de, 48
	or	a, a
	sbc	hl, de
	ld	bc, 100
	call	__imulu
	ld	(ix - 3), bc
	ld	bc, -175
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 55)
	ld	iy, (hl)
	ld	a, (iy + 12)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	or	a, a
	sbc	hl, de
	ld	bc, (ix - 3)
	ld	bc, 10
	call	__imulu
	push	hl
	pop	de
	ld	(ix - 3), bc
	ld	bc, -175
	lea	iy, ix
	add	iy, bc
	ld	hl, (iy)
	add	hl, de
	ld	bc, (ix - 3)
	push	hl
	pop	bc
	ld	iy, (ix - 27)
	ld	hl, (iy + 55)
	ld	iy, (hl)
	ld	a, (iy + 13)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	de, 48
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	push	bc
	pop	hl
	add	hl, de
	ld	iy, (ix - 27)
	ld	(iy + 59), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 55)
	ld	hl, (hl)
	ld	hl, (hl)
	ld	bc, -154
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy + 8), l
	ld	(iy + 9), h
	ld	iy, (ix - 27)
	ld	l, 1
	ld	a, (iy + 34)
	xor	a, l
	bit	0, a
	jq	nz, BB34_138
	jq	BB34_134
BB34_134:
	ld	iy, (ix - 27)
	ld	hl, (iy + 55)
	ld	iy, (hl)
	lea	hl, iy + 2
	ld	bc, -154
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy + 5), hl
	ld	hl, (iy + 5)
	ld	(iy + 2), hl
	lea	de, iy
	ld	iy, (ix - 27)
	ld	hl, (iy + 41)
	push	de
	pop	iy
	ld	(iy), l
	ld	(iy + 1), h
	jq	BB34_135
BB34_135:
	ld	hl, (iy)
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, (iy + 5)
	add	hl, de
	ld	(iy + 5), hl
	ld	hl, (iy)
	ld	de, 0
	ld	e, l
	ld	d, h
	ld	hl, (iy + 2)
	add	hl, de
	ld	(iy + 2), hl
	ld	bc, -160
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	call	_getChunkSize
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	de, -154
	lea	iy, ix
	add	iy, de
	ld	iy, (iy)
	ld	(iy), l
	ld	(iy + 1), h
	ld	de, -154
	lea	hl, ix
	add	hl, de
	ld	iy, (hl)
	ld	iy, (iy + 5)
	lea	hl, iy + 2
	ld	de, -154
	lea	iy, ix
	add	iy, de
	ld	iy, (iy)
	ld	(iy + 5), hl
	ld	de, -154
	lea	hl, ix
	add	hl, de
	ld	iy, (hl)
	ld	hl, (iy + 2)
	ld	de, -233
	lea	iy, ix
	add	iy, de
	ld	(iy), hl
	ld	de, -154
	lea	hl, ix
	add	hl, de
	ld	iy, (hl)
	ld	bc, (iy + 5)
	ld	iy, (ix - 27)
	ld	hl, (iy + 55)
	ld	iy, (hl)
	lea	hl, iy + 2
	ld	de, -154
	lea	iy, ix
	add	iy, de
	ld	iy, (iy)
	ld	iy, (iy + 8)
	ld	de, 0
	ld	e, iyl
	ld	d, iyh
	add	hl, de
	ld	de, -154
	lea	iy, ix
	add	iy, de
	ld	iy, (iy)
	ld	de, (iy + 5)
	or	a, a
	sbc	hl, de
	push	hl
	push	bc
	ld	bc, -233
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	bc, -154
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	de, (iy + 2)
	ld	bc, -154
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	hl, (iy + 5)
	or	a, a
	sbc	hl, de
	push	hl
	pop	de
	ld	bc, -154
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	bc, (iy + 8)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	or	a, a
	sbc	hl, de
	ld	bc, -154
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy + 8), l
	ld	(iy + 9), h
	ld	bc, -154
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	iy, (iy + 2)
	lea	hl, iy + 2
	ld	bc, -154
	lea	iy, ix
	add	iy, bc
	ld	iy, (iy)
	ld	(iy + 5), hl
	jq	BB34_136
BB34_136:
	ld	hl, (iy)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jq	nz, BB34_135
	jq	BB34_137
BB34_137:
	jq	BB34_138
BB34_138:
	ld	iy, (ix - 27)
	bit	0, (iy + 58)
	jq	nz, BB34_140
	jq	BB34_139
BB34_139:
	ld	iy, (ix - 27)
	ld	de, (iy + 41)
	ld	bc, -154
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	bc, (iy + 8)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	or	a, a
	sbc	hl, de
	ld	(iy + 8), l
	ld	(iy + 9), h
	lea	de, iy
	ld	iy, (ix - 27)
	ld	hl, (iy + 55)
	ld	iy, (hl)
	lea	hl, iy + 2
	ld	bc, -249
	lea	iy, ix
	add	iy, bc
	ld	(iy), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 55)
	ld	iy, (hl)
	lea	hl, iy + 2
	ld	iy, (ix - 27)
	ld	bc, (iy + 41)
	add	hl, bc
	push	de
	pop	iy
	ld	iy, (iy + 8)
	ld	bc, 0
	ld	c, iyl
	ld	b, iyh
	push	bc
	push	hl
	ld	bc, -249
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	call	_memcpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	jq	BB34_140
BB34_140:
	ld	bc, -154
	lea	hl, ix
	add	hl, bc
	ld	iy, (hl)
	ld	hl, (iy + 8)
	ld	de, 0
	ld	e, l
	ld	d, h
	push	de
	ld	bc, -157
	lea	hl, ix
	add	hl, bc
	ld	hl, (hl)
	push	hl
	call	_ResizeAppVar
	ld	hl, 6
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 121)
	ld	de, 9
	push	de
	ld	bc, -157
	lea	iy, ix
	add	iy, bc
	ld	de, (iy)
	push	de
	push	hl
	call	_strncpy
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	hl, (_http_data_list)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB34_142
	jq	BB34_141
BB34_141:
	ld	hl, (_http_data_list)
	ld	iy, (ix - 121)
	ld	(iy + 9), hl
	jq	BB34_142
BB34_142:
	ld	hl, (ix - 121)
	ld	(_http_data_list), hl
	ld	iy, (ix - 27)
	ld	hl, (iy + 55)
	push	hl
	call	_web_LockData
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	or	a, a
	sbc	hl, hl
	ld	(ix - 9), hl
	jq	BB34_143
BB34_143:
	ld	hl, (ix - 9)
	ld	iy, 249
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_add_tcp_queue
_add_tcp_queue:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -43
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, (ix + 9)
	ld	bc, (ix + 12)
	ld	iy, (ix + 15)
	ld	(ix - 3), hl
	ld	(ix - 6), de
	ld	(ix - 9), bc
	push	hl
	lea	hl, iy
	ld	(ix - 11), l
	ld	(ix - 10), h
	pop	hl
	ld	hl, (ix + 18)
	ld	(ix - 14), hl
	ld	hl, (ix + 21)
	ld	(ix - 17), hl
	ld	hl, (ix - 3)
	ld	(ix - 26), hl
	ld	hl, (ix - 6)
	ld	(ix - 29), hl
	ld	iy, (ix - 9)
	ld	hl, (iy)
	ld	(ix - 32), hl
	ld	a, (iy + 3)
	ld	(ix - 33), a
	ld	iy, (ix - 9)
	ld	hl, (iy + 4)
	ld	(ix - 36), hl
	ld	iy, (ix - 9)
	ld	hl, (iy + 6)
	ld	(ix - 39), hl
	ld	iy, (ix - 9)
	ld	hl, (iy + 14)
	ld	(ix - 42), hl
	ld	a, (iy + 17)
	ld	(ix - 43), a
	ld	iy, (ix - 9)
	ld	hl, (iy + 18)
	ld	a, (iy + 21)
	ld	iy, (ix - 11)
	ld	bc, (ix - 14)
	ld	de, (ix - 17)
	push	de
	push	bc
	push	iy
	ld	e, a
	push	de
	push	hl
	ld	l, (ix - 43)
	push	hl
	ld	hl, (ix - 42)
	push	hl
	ld	hl, (ix - 39)
	push	hl
	ld	hl, (ix - 36)
	push	hl
	ld	l, (ix - 33)
	push	hl
	ld	hl, (ix - 32)
	push	hl
	ld	hl, (ix - 29)
	push	hl
	ld	hl, (ix - 26)
	push	hl
	call	_web_PushTCPSegment
	ld	iy, 39
	add	iy, sp
	ld	sp, iy
	ld	(ix - 20), hl
	ld	bc, (ix - 6)
	xor	a, a
	ld	iy, (ix - 9)
	ld	hl, (iy + 14)
	ld	e, (iy + 17)
	call	__ladd
	ld	(iy + 14), hl
	ld	(iy + 17), e
	ld	hl, 10
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 23), hl
	ld	iy, (ix - 9)
	ld	hl, (iy + 14)
	ld	e, (iy + 17)
	ld	iy, (ix - 9)
	ld	bc, (iy + 22)
	ld	a, (iy + 25)
	call	__lsub
	ld	iy, (ix - 23)
	ld	(iy), hl
	ld	(iy + 3), e
	ld	hl, (ix - 20)
	ld	iy, (ix - 23)
	ld	(iy + 4), hl
	ld	iy, (ix - 9)
	ld	hl, (iy + 52)
	ld	iy, (ix - 23)
	ld	(iy + 7), hl
	ld	hl, (ix - 23)
	ld	iy, (ix - 9)
	ld	(iy + 52), hl
	ld	hl, 43
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_wipe_data
_wipe_data:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -9
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, 0
	ld	(ix - 3), hl
	ld	iy, (ix - 3)
	ld	hl, (iy + 49)
	ld	(ix - 6), hl
	ld	(ix - 9), de
	jq	BB36_1
BB36_1:
	ld	hl, (ix - 6)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB36_3
	jq	BB36_2
BB36_2:
	ld	iy, (ix - 6)
	ld	hl, (iy + 10)
	ld	(ix - 9), hl
	ld	iy, (ix - 6)
	ld	hl, (iy + 7)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 6)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 9)
	ld	(ix - 6), hl
	jq	BB36_1
BB36_3:
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_getBigEndianValue
_getBigEndianValue:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -6
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	(ix - 3), hl
	ld	hl, (ix - 3)
	ld	bc, 0
	ld	c, (hl)
	xor	a, a
	ld	l, 24
	call	__lshl
	push	bc
	pop	de
	ld	iy, (ix - 3)
	or	a, a
	sbc	hl, hl
	ld	l, (iy + 1)
	ld	c, 16
	call	__ishl
	push	hl
	pop	bc
	push	bc
	pop	hl
	push	bc
	pop	iy
	add	iy, iy
	sbc	hl, hl
	push	hl
	pop	iy
	ex	de, hl
	ld	e, a
	ld	a, iyl
	call	__ladd
	ld	(ix - 6), hl
	ld	iy, (ix - 3)
	or	a, a
	sbc	hl, hl
	ld	l, (iy + 2)
	ld	c, 8
	call	__ishl
	push	hl
	pop	bc
	ld	hl, (ix - 6)
	xor	a, a
	call	__ladd
	ld	iy, (ix - 3)
	ld	bc, 0
	ld	c, (iy + 3)
	call	__ladd
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_fetch_ack
_fetch_ack:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -19
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	iy, (ix + 9)
	ld	a, (ix + 12)
	ld	bc, 0
	ld	e, 0
	ld	(ix - 3), hl
	ld	(ix - 7), iy
	ld	(ix - 4), a
	ld	iy, (ix - 3)
	ld	hl, (iy + 52)
	ld	(ix - 10), hl
	ld	(ix - 13), bc
	jq	BB38_1
BB38_1:
	ld	hl, (ix - 10)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	a, e
	jq	z, BB38_5
	jq	BB38_2
BB38_2:
	ld	iy, (ix - 10)
	ld	hl, (iy)
	ld	(ix - 19), hl
	ld	d, (iy + 3)
	ld	hl, (ix - 7)
	ld	e, (ix - 4)
	ld	iy, (ix - 3)
	ld	bc, (iy + 22)
	ld	a, (iy + 25)
	call	__lsub
	ld	bc, (ix - 19)
	ld	a, d
	call	__lcmpu
	ld	a, 1
	ld	l, 0
	jq	c, BB38_4
	ld	a, l
BB38_4:
	ld	bc, 0
	ld	e, 0
	jq	BB38_5
BB38_5:
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB38_7
	jq	BB38_6
BB38_6:
	ld	hl, (ix - 10)
	ld	(ix - 13), hl
	ld	iy, (ix - 10)
	ld	hl, (iy + 7)
	ld	(ix - 10), hl
	jq	BB38_1
BB38_7:
	ld	hl, (ix - 10)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB38_9
	jq	BB38_8
BB38_8:
	jq	BB38_16
BB38_9:
	ld	(ix - 16), bc
	ld	hl, (ix - 13)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB38_11
	jq	BB38_10
BB38_10:
	ld	iy, (ix - 13)
	ld	(iy + 7), bc
	jq	BB38_12
BB38_11:
	ld	iy, (ix - 3)
	ld	(iy + 52), bc
	jq	BB38_12
BB38_12:
	jq	BB38_13
BB38_13:
	ld	hl, (ix - 10)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB38_15
	jq	BB38_14
BB38_14:
	ld	iy, (ix - 10)
	ld	hl, (iy + 7)
	ld	(ix - 16), hl
	ld	iy, (ix - 10)
	ld	hl, (iy + 4)
	push	hl
	call	_web_popMessage
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 10)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 16)
	ld	(ix - 10), hl
	jq	BB38_13
BB38_15:
	ld	hl, (ix - 7)
	ld	e, (ix - 4)
	ld	iy, (ix - 3)
	ld	bc, (iy + 22)
	ld	a, (iy + 25)
	call	__lsub
	ld	iy, (ix - 3)
	ld	(iy + 30), hl
	ld	(iy + 33), e
	jq	BB38_16
BB38_16:
	ld	hl, 19
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_getChunkSize
_getChunkSize:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -6
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	bc, 0
	ld	de, 48
	ld	(ix - 3), hl
	ld	(ix - 6), bc
	jq	BB39_1
BB39_1:
	ld	hl, (ix - 3)
	ld	hl, (hl)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	bc, 13
	or	a, a
	sbc	hl, bc
	jq	z, BB39_9
	jq	BB39_2
BB39_2:
	ld	hl, (ix - 3)
	ld	hl, (hl)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	bc, -8388608
	add	hl, bc
	ld	bc, -8388550
	or	a, a
	sbc	hl, bc
	jq	nc, BB39_4
	jq	BB39_3
BB39_3:
	ld	hl, (ix - 6)
	ld	c, 4
	call	__ishl
	push	hl
	pop	iy
	ld	hl, (ix - 3)
	ld	hl, (hl)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	push	de
	pop	bc
	or	a, a
	sbc	hl, bc
	push	hl
	pop	bc
	add	iy, bc
	ld	(ix - 6), iy
	jq	BB39_8
BB39_4:
	ld	hl, (ix - 3)
	ld	hl, (hl)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	bc, -8388608
	add	hl, bc
	ld	bc, -8388537
	or	a, a
	sbc	hl, bc
	jq	nc, BB39_6
	jq	BB39_5
BB39_5:
	ld	hl, (ix - 6)
	ld	c, 4
	call	__ishl
	push	hl
	pop	iy
	ld	bc, 10
	add	iy, bc
	ld	hl, (ix - 3)
	ld	hl, (hl)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	bc, 65
	or	a, a
	sbc	hl, bc
	push	hl
	pop	bc
	add	iy, bc
	ld	(ix - 6), iy
	jq	BB39_7
BB39_6:
	ld	hl, (ix - 6)
	ld	c, 4
	call	__ishl
	push	hl
	pop	iy
	ld	bc, 10
	add	iy, bc
	ld	hl, (ix - 3)
	ld	hl, (hl)
	ld	a, (hl)
	ld	l, a
	rlc	l
	sbc	hl, hl
	ld	l, a
	ld	bc, 97
	or	a, a
	sbc	hl, bc
	push	hl
	pop	bc
	add	iy, bc
	ld	(ix - 6), iy
	jq	BB39_7
BB39_7:
	jq	BB39_8
BB39_8:
	ld	hl, (ix - 3)
	ld	bc, (hl)
	inc	bc
	ld	(hl), bc
	jq	BB39_1
BB39_9:
	ld	hl, (ix - 6)
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_fetch_ethernet_frame
_fetch_ethernet_frame:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -12
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	de, (ix + 9)
	ld	bc, _MAC_ADDR
	ld	(ix - 6), hl
	ld	(ix - 9), de
	ld	iy, (ix - 6)
	ld	de, (iy + 12)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, 8
	or	a, a
	sbc	hl, de
	jq	nz, BB40_3
	jq	BB40_1
BB40_1:
	ld	hl, (ix - 6)
	ld	de, 6
	push	de
	push	bc
	push	hl
	call	_memcmp
	ld	bc, 4
	push	bc
	pop	de
	ld	bc, _MAC_ADDR
	ld	iy, 9
	add	iy, sp
	ld	sp, iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB40_3
	jq	BB40_2
BB40_2:
	ld	iy, (ix - 6)
	lea	hl, iy + 6
	ld	(_src_mac_addr), hl
	ld	iy, (ix - 6)
	lea	hl, iy + 14
	ld	(ix - 12), hl
	push	de
	pop	iy
	ld	de, (ix - 12)
	ld	hl, (ix - 9)
	ld	bc, 18
	or	a, a
	sbc	hl, bc
	lea	bc, iy
	add	hl, bc
	push	hl
	push	de
	call	_fetch_IPv4_packet
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 3), hl
	jq	BB40_9
BB40_3:
	ld	hl, (ix - 6)
	ld	de, 6
	push	de
	push	bc
	push	hl
	call	_memcmp
	ld	iy, 9
	add	iy, sp
	ld	sp, iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB40_5
	jq	BB40_4
BB40_4:
	ld	hl, (ix - 6)
	push	hl
	call	_cmpbroadcast
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	l, 1
	xor	a, l
	bit	0, a
	jq	nz, BB40_7
	jq	BB40_5
BB40_5:
	ld	iy, (ix - 6)
	ld	de, (iy + 12)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, 1544
	or	a, a
	sbc	hl, de
	jq	nz, BB40_7
	jq	BB40_6
BB40_6:
	ld	hl, (ix - 6)
	push	hl
	call	_fetch_arp_msg
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	jq	BB40_7
BB40_7:
	jq	BB40_8
BB40_8:
	ld	hl, 1
	ld	(ix - 3), hl
	jq	BB40_9
BB40_9:
	ld	hl, (ix - 3)
	ld	iy, 12
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_fetch_IPv4_packet
_fetch_IPv4_packet:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -39
	add	hl, sp
	ld	sp, hl
	ld	de, (ix + 6)
	ld	bc, (ix + 9)
	ld	hl, 1
	ld	(ix - 6), de
	ld	(ix - 9), bc
	ld	iy, (ix - 6)
	ld	a, (iy + 9)
	cp	a, 6
	jq	nz, BB41_2
	jq	BB41_1
BB41_1:
	ld	iy, (ix - 6)
	ld	hl, (ix - 6)
	ld	a, (hl)
	and	a, 15
	ld	b, 2
	call	__bshl
	ld	de, 0
	ld	e, a
	add	iy, de
	ld	(ix - 12), iy
	ld	hl, (ix - 12)
	ld	(ix - 24), hl
	ld	hl, (ix - 9)
	ld	iy, (ix - 6)
	ld	a, (iy)
	and	a, 15
	ld	b, 2
	call	__bshl
	ld	bc, 0
	ld	c, a
	or	a, a
	sbc	hl, bc
	ld	(ix - 33), hl
	ld	iy, (ix - 6)
	ld	hl, (iy + 12)
	ld	(ix - 36), hl
	ld	e, (iy + 15)
	ld	iy, (ix - 6)
	ld	hl, (iy + 16)
	ld	a, (iy + 19)
	ld	c, a
	push	bc
	push	hl
	ld	l, e
	push	hl
	ld	hl, (ix - 36)
	push	hl
	ld	hl, (ix - 33)
	push	hl
	ld	hl, (ix - 24)
	push	hl
	call	_fetch_tcp_segment
	ld	iy, 18
	add	iy, sp
	ld	sp, iy
	ld	(ix - 3), hl
	jq	BB41_7
BB41_2:
	ld	iy, (ix - 6)
	ld	a, (iy + 9)
	cp	a, 17
	jq	nz, BB41_4
	jq	BB41_3
BB41_3:
	ld	iy, (ix - 6)
	ld	hl, (ix - 6)
	ld	a, (hl)
	and	a, 15
	ld	b, 2
	call	__bshl
	ld	de, 0
	ld	e, a
	add	iy, de
	ld	(ix - 15), iy
	ld	hl, (ix - 15)
	ld	(ix - 21), hl
	ld	hl, (ix - 9)
	ld	iy, (ix - 6)
	ld	a, (iy)
	and	a, 15
	ld	b, 2
	call	__bshl
	ld	bc, 0
	ld	c, a
	or	a, a
	sbc	hl, bc
	ld	(ix - 30), hl
	ld	iy, (ix - 6)
	ld	hl, (iy + 12)
	ld	(ix - 39), hl
	ld	e, (iy + 15)
	ld	iy, (ix - 6)
	ld	hl, (iy + 16)
	ld	a, (iy + 19)
	ld	c, a
	push	bc
	push	hl
	ld	l, e
	push	hl
	ld	hl, (ix - 39)
	push	hl
	ld	hl, (ix - 30)
	push	hl
	ld	hl, (ix - 21)
	push	hl
	call	_fetch_udp_datagram
	ld	iy, 18
	add	iy, sp
	ld	sp, iy
	ld	(ix - 3), hl
	jq	BB41_7
BB41_4:
	ld	iy, (ix - 6)
	ld	a, (iy + 9)
	cp	a, 1
	jq	nz, BB41_6
	jq	BB41_5
BB41_5:
	ld	iy, (ix - 6)
	ld	hl, (ix - 6)
	ld	a, (hl)
	and	a, 15
	ld	b, 2
	call	__bshl
	ld	de, 0
	ld	e, a
	add	iy, de
	ld	(ix - 18), iy
	ld	hl, (ix - 18)
	ld	(ix - 27), hl
	ld	hl, (ix - 9)
	ld	iy, (ix - 6)
	ld	a, (iy)
	and	a, 15
	ld	b, 2
	call	__bshl
	ld	bc, 0
	ld	c, a
	or	a, a
	sbc	hl, bc
	ld	iy, (ix - 6)
	ld	bc, (iy + 12)
	ld	a, (iy + 15)
	ld	e, a
	push	de
	push	bc
	push	hl
	ld	hl, (ix - 27)
	push	hl
	call	_fetch_icmpv4_msg
	ld	iy, 12
	add	iy, sp
	ld	sp, iy
	ld	(ix - 3), hl
	jq	BB41_7
BB41_6:
	ld	(ix - 3), hl
	jq	BB41_7
BB41_7:
	ld	hl, (ix - 3)
	ld	iy, 39
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_cmpbroadcast
_cmpbroadcast:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -7
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	bc, 0
	ld	e, 0
	ld	(ix - 3), hl
	ld	(ix - 4), 1
	ld	(ix - 7), bc
	jq	BB42_1
BB42_1:
	ld	hl, (ix - 7)
	ld	bc, -8388608
	add	hl, bc
	ld	bc, -8388602
	or	a, a
	sbc	hl, bc
	jq	nc, BB42_8
	jq	BB42_2
BB42_2:
	ld	l, 1
	ld	a, (ix - 4)
	xor	a, l
	bit	0, a
	ld	a, e
	jq	nz, BB42_6
	jq	BB42_3
BB42_3:
	ld	hl, (ix - 3)
	ld	bc, (ix - 7)
	add	hl, bc
	ld	a, (hl)
	cp	a, -1
	ld	a, 1
	ld	l, 0
	jq	z, BB42_5
	ld	a, l
BB42_5:
	jq	BB42_6
BB42_6:
	and	a, 1
	ld	(ix - 4), a
	jq	BB42_7
BB42_7:
	ld	hl, (ix - 7)
	inc	hl
	ld	(ix - 7), hl
	jq	BB42_1
BB42_8:
	ld	a, (ix - 4)
	ld	hl, 7
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_fetch_arp_msg
_fetch_arp_msg:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -12
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix + 6)
	ld	(ix - 3), hl
	ld	iy, (ix - 3)
	lea	hl, iy + 14
	ld	(ix - 6), hl
	ld	iy, (ix - 3)
	ld	de, (iy + 12)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, 1544
	or	a, a
	sbc	hl, de
	jq	nz, BB43_5
	jq	BB43_1
BB43_1:
	ld	hl, (ix - 6)
	ld	de, (hl)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, 256
	or	a, a
	sbc	hl, de
	jq	nz, BB43_5
	jq	BB43_2
BB43_2:
	ld	iy, (ix - 6)
	ld	de, (iy + 6)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, 256
	or	a, a
	sbc	hl, de
	jq	nz, BB43_5
	jq	BB43_3
BB43_3:
	ld	iy, (ix - 6)
	ld	de, (iy + 2)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, 8
	or	a, a
	sbc	hl, de
	jq	nz, BB43_5
	jq	BB43_4
BB43_4:
	ld	iy, (ix - 6)
	ld	hl, (iy + 24)
	ld	e, (iy + 27)
	ld	bc, (_IP_ADDR)
	ld	a, (_IP_ADDR+3)
	call	__lcmpu
	jq	z, BB43_6
	jq	BB43_5
BB43_5:
	jq	BB43_7
BB43_6:
	ld	hl, 28
	push	hl
	call	_malloc
	ld	iy, 3
	add	iy, sp
	ld	sp, iy
	ld	(ix - 9), hl
	ld	iy, (ix - 9)
	lea	de, iy + 18
	ld	iy, (ix - 6)
	lea	hl, iy + 8
	ld	bc, 10
	ldir
	ld	iy, (ix - 9)
	lea	de, iy + 8
	ld	hl, _MAC_ADDR
	ld	bc, 6
	ldir
	ld	hl, (_IP_ADDR)
	ld	a, (_IP_ADDR+3)
	ld	iy, (ix - 9)
	ld	(iy + 14), hl
	ld	(iy + 17), a
	ld	iy, (ix - 9)
	ld.sis	hl, 512
	ld	(iy + 6), l
	ld	(iy + 7), h
	ld	hl, (ix - 9)
	ld.sis	de, 256
	ld	(hl), e
	inc	hl
	ld	(hl), d
	ld	iy, (ix - 9)
	ld.sis	hl, 8
	ld	(iy + 2), l
	ld	(iy + 3), h
	ld	iy, (ix - 9)
	ld	(iy + 4), 6
	ld	iy, (ix - 9)
	ld	(iy + 5), 4
	ld	hl, (ix - 9)
	ld	de, 1544
	push	de
	ld	de, 28
	push	de
	push	hl
	call	_web_PushEthernetFrame
	ld	iy, 9
	add	iy, sp
	ld	sp, iy
	ld	(ix - 12), hl
	ld	iy, (ix - 12)
	ld	hl, (iy + 6)
	ld	e, (iy + 9)
	ld	bc, 100
	xor	a, a
	call	__ladd
	ld	(iy + 6), hl
	ld	(iy + 9), e
	ld	iy, (ix - 12)
	ld	bc, (iy + 10)
	ld	iy, (ix - 12)
	ld	iy, (iy + 3)
	ld	hl, (ix - 12)
	ld	hl, (hl)
	ld	de, (ix - 12)
	push	de
	ld	de, _send_callback
	push	de
	push	hl
	push	iy
	push	bc
	call	_usb_ScheduleTransfer
	ld	hl, 15
	add	hl, sp
	ld	sp, hl
	ld	hl, (ix - 9)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	jq	BB43_7
BB43_7:
	ld	hl, 12
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_fetch_tcp_segment
_fetch_tcp_segment:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -32
	add	hl, sp
	ld	sp, hl
	ld	bc, (ix + 12)
	ld	l, (ix + 15)
	ld	iy, (ix + 18)
	ld	a, (ix + 21)
	ld	de, (ix + 6)
	ld	(ix - 6), de
	ld	de, (ix + 9)
	ld	(ix - 9), de
	ld	(ix - 13), bc
	ld	(ix - 10), l
	ld	(ix - 17), iy
	ld	(ix - 14), a
	ld	hl, (ix - 6)
	ld	(ix - 23), hl
	ld	hl, (ix - 9)
	ld	(ix - 29), hl
	ld	hl, (ix - 13)
	ld	(ix - 32), hl
	ld	e, (ix - 10)
	ld	hl, (ix - 17)
	ld	a, (ix - 14)
	ld	iy, 6
	push	iy
	ld	c, a
	push	bc
	push	hl
	ld	l, e
	push	hl
	ld	hl, (ix - 32)
	push	hl
	ld	hl, (ix - 29)
	push	hl
	ld	hl, (ix - 23)
	push	hl
	call	_transport_checksum
	ld	iy, 21
	add	iy, sp
	ld	sp, iy
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jq	nz, BB44_2
	jq	BB44_1
BB44_1:
	ld	hl, (ix - 6)
	ld	(ix - 20), hl
	ld	hl, (ix - 9)
	ld	(ix - 26), hl
	ld	iy, (ix - 6)
	ld	bc, (iy + 2)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	bc, 256
	call	__idivs
	push	hl
	pop	de
	ld	iy, (ix - 6)
	ld	bc, (iy + 2)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	c, 8
	call	__ishl
	push	hl
	pop	bc
	ex	de, hl
	add	hl, bc
	push	hl
	ld	hl, (ix - 26)
	push	hl
	ld	hl, (ix - 20)
	push	hl
	ld	hl, 6
	push	hl
	call	_call_callbacks
	ld	iy, 12
	add	iy, sp
	ld	sp, iy
	ld	(ix - 3), hl
	jq	BB44_3
BB44_2:
	ld	hl, 10
	ld	(ix - 3), hl
	jq	BB44_3
BB44_3:
	ld	hl, (ix - 3)
	ld	iy, 32
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_fetch_udp_datagram
_fetch_udp_datagram:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -32
	add	hl, sp
	ld	sp, hl
	ld	bc, (ix + 12)
	ld	l, (ix + 15)
	ld	iy, (ix + 18)
	ld	a, (ix + 21)
	ld	de, (ix + 6)
	ld	(ix - 6), de
	ld	de, (ix + 9)
	ld	(ix - 9), de
	ld	(ix - 13), bc
	ld	(ix - 10), l
	ld	(ix - 17), iy
	ld	(ix - 14), a
	ld	hl, (ix - 6)
	ld	(ix - 23), hl
	ld	hl, (ix - 9)
	ld	(ix - 29), hl
	ld	hl, (ix - 13)
	ld	(ix - 32), hl
	ld	e, (ix - 10)
	ld	hl, (ix - 17)
	ld	a, (ix - 14)
	ld	iy, 17
	push	iy
	ld	c, a
	push	bc
	push	hl
	ld	l, e
	push	hl
	ld	hl, (ix - 32)
	push	hl
	ld	hl, (ix - 29)
	push	hl
	ld	hl, (ix - 23)
	push	hl
	call	_transport_checksum
	ld	iy, 21
	add	iy, sp
	ld	sp, iy
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jq	z, BB45_2
	jq	BB45_1
BB45_1:
	ld	iy, (ix - 6)
	ld	hl, (iy + 6)
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jq	nz, BB45_3
	jq	BB45_2
BB45_2:
	ld	hl, (ix - 6)
	ld	(ix - 20), hl
	ld	hl, (ix - 9)
	ld	(ix - 26), hl
	ld	iy, (ix - 6)
	ld	bc, (iy + 2)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	bc, 256
	call	__idivs
	push	hl
	pop	de
	ld	iy, (ix - 6)
	ld	bc, (iy + 2)
	or	a, a
	sbc	hl, hl
	ld	l, c
	ld	h, b
	ld	c, 8
	call	__ishl
	push	hl
	pop	bc
	ex	de, hl
	add	hl, bc
	push	hl
	ld	hl, (ix - 26)
	push	hl
	ld	hl, (ix - 20)
	push	hl
	ld	hl, 17
	push	hl
	call	_call_callbacks
	ld	iy, 12
	add	iy, sp
	ld	sp, iy
	ld	(ix - 3), hl
	jq	BB45_4
BB45_3:
	ld	hl, 10
	ld	(ix - 3), hl
	jq	BB45_4
BB45_4:
	ld	hl, (ix - 3)
	ld	iy, 32
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_fetch_icmpv4_msg
_fetch_icmpv4_msg:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -25
	add	hl, sp
	ld	sp, hl
	ld	bc, (ix + 6)
	ld	de, (ix + 9)
	ld	hl, (ix + 12)
	ld	a, (ix + 15)
	ld	(ix - 6), bc
	ld	(ix - 9), de
	ld	(ix - 13), hl
	ld	(ix - 10), a
	ld	hl, (ix - 6)
	ld	a, (hl)
	cp	a, 8
	jq	nz, BB46_2
	jq	BB46_1
BB46_1:
	ld	iy, (ix - 6)
	ld	a, (iy + 1)
	or	a, a
	jq	z, BB46_3
	jq	BB46_2
BB46_2:
	ld	hl, 1
	ld	(ix - 3), hl
	jq	BB46_4
BB46_3:
	ld	hl, (ix - 6)
	ld	(hl), 0
	ld	iy, (ix - 6)
	ld	de, (iy + 2)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	de, 8
	add	hl, de
	ld	(iy + 2), l
	ld	(iy + 3), h
	ld	hl, (ix - 6)
	ld	(ix - 19), hl
	ld	hl, (ix - 9)
	ld	(ix - 22), hl
	ld	hl, (_IP_ADDR)
	ld	(ix - 25), hl
	ld	a, (_IP_ADDR+3)
	ld	e, a
	ld	hl, (ix - 13)
	ld	a, (ix - 10)
	ld	iy, 1
	push	iy
	ld	c, a
	push	bc
	push	hl
	push	de
	ld	hl, (ix - 25)
	push	hl
	ld	hl, (ix - 22)
	push	hl
	ld	hl, (ix - 19)
	push	hl
	call	_web_PushIPv4Packet
	ld	iy, 21
	add	iy, sp
	ld	sp, iy
	ld	(ix - 16), hl
	ld	iy, (ix - 16)
	ld	hl, (iy + 6)
	ld	e, (iy + 9)
	ld	bc, 100
	xor	a, a
	call	__ladd
	ld	(iy + 6), hl
	ld	(iy + 9), e
	ld	iy, (ix - 16)
	ld	bc, (iy + 10)
	ld	iy, (ix - 16)
	ld	iy, (iy + 3)
	ld	hl, (ix - 16)
	ld	hl, (hl)
	ld	de, (ix - 16)
	push	de
	ld	de, _send_callback
	push	de
	push	hl
	push	iy
	push	bc
	call	_usb_ScheduleTransfer
	ld	iy, 15
	add	iy, sp
	ld	sp, iy
	ld	(ix - 3), hl
	jq	BB46_4
BB46_4:
	ld	hl, (ix - 3)
	ld	iy, 25
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_call_callbacks
_call_callbacks:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -15
	add	hl, sp
	ld	sp, hl
	ld	a, (ix + 6)
	ld	hl, (ix + 9)
	ld	bc, (ix + 15)
	ld	de, 0
	ld	(ix - 1), a
	ld	(ix - 4), hl
	ld	hl, (ix + 12)
	ld	(ix - 7), hl
	ld	(ix - 9), c
	ld	(ix - 8), b
	ld	hl, (_listened_ports)
	ld	(ix - 12), hl
	jq	BB47_1
BB47_1:
	ld	hl, (ix - 12)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB47_7
	jq	BB47_2
BB47_2:
	ld	de, (ix - 9)
	or	a, a
	sbc	hl, hl
	ld	l, e
	ld	h, d
	ld	iy, (ix - 12)
	ld	de, (iy)
	ld	bc, 0
	ld	c, e
	ld	b, d
	or	a, a
	sbc	hl, bc
	jq	nz, BB47_6
	jq	BB47_3
BB47_3:
	ld	iy, (ix - 12)
	ld	hl, (iy + 2)
	ld	(ix - 15), hl
	ld	de, (ix - 9)
	ld	a, (ix - 1)
	ld	bc, (ix - 4)
	ld	hl, (ix - 7)
	ld	iy, (ix - 12)
	ld	iy, (iy + 5)
	push	iy
	push	hl
	push	bc
	ld	l, a
	push	hl
	push	de
	ld	hl, (ix - 15)
	call	__indcallhl
	ld	iy, 15
	add	iy, sp
	ld	sp, iy
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	nz, BB47_5
	jq	BB47_4
BB47_4:
	ld	de, 0
	jq	BB47_7
BB47_5:
	jq	BB47_6
BB47_6:
	ld	iy, (ix - 12)
	ld	hl, (iy + 8)
	ld	(ix - 12), hl
	ld	de, 0
	jq	BB47_1
BB47_7:
	ex	de, hl
	ld	iy, 15
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_dhcp_init
_dhcp_init:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -26
	add	hl, sp
	ld	sp, hl
	ld	iy, _fetch_dhcp_msg
	ld	de, 0
	lea	hl, ix - 4
	ld	(ix - 26), hl
	lea	hl, ix - 14
	ld	a, (_phase)
	or	a, a
	jq	z, BB48_2
	jq	BB48_1
BB48_1:
	jq	BB48_3
BB48_2:
	push	de
	push	iy
	ld	de, 68
	push	de
	ld	(ix - 23), hl
	call	_web_ListenPort
	ld	hl, 9
	add	hl, sp
	ld	sp, hl
	ld	de, (ix - 26)
	ld	hl, L___const.dhcp_init.beg_header
	ld	bc, 4
	ldir
	ld	de, (ix - 23)
	ld	hl, L___const.dhcp_init.options_disc
	ld	bc, 10
	ldir
	ld	hl, 250
	ex	de, hl
	ld	(ix - 17), de
	ld	hl, 1
	push	hl
	push	de
	call	_calloc
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 20), hl
	ld	de, (ix - 20)
	ld	hl, (ix - 26)
	ld	bc, 4
	ldir
	ld	hl, (_dhcp_init.xid)
	ld	a, (_dhcp_init.xid+3)
	ld	iy, (ix - 20)
	ld	(iy + 4), hl
	ld	(iy + 7), a
	ld	iy, (ix - 20)
	lea	de, iy + 28
	ld	hl, _MAC_ADDR
	ld	bc, 6
	ldir
	ld	iy, (ix - 20)
	ld	de, 236
	add	iy, de
	ld	hl, 5472867
	ld	(iy), hl
	lea	hl, iy + 3
	ld	a, 99
	ld	(hl), a
	ld	hl, (ix - 20)
	ld	de, 240
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 23)
	ld	bc, 10
	ldir
	ld	hl, (ix - 20)
	ld	de, 67
	push	de
	ld	de, 68
	push	de
	ld	de, -1
	push	de
	ld	de, -1
	push	de
	ld	de, 250
	push	de
	push	hl
	call	_web_PushUDPDatagram
	ld	iy, 18
	add	iy, sp
	ld	sp, iy
	ld	(_dhcp_last_queued_msg), hl
	ld	hl, (ix - 20)
	push	hl
	call	_free
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	a, 1
	ld	(_phase), a
	ld	hl, (_dhcp_init.xid)
	ld	a, (_dhcp_init.xid+3)
	ld	e, a
	ld	bc, 1
	xor	a, a
	call	__ladd
	ld	a, e
	ld	(_dhcp_init.xid), hl
	ld	(_dhcp_init.xid+3), a
	jq	BB48_3
BB48_3:
	ld	hl, 26
	add	hl, sp
	ld	sp, hl
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.text,"ax",@progbits
	; private	_fetch_dhcp_msg
_fetch_dhcp_msg:
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, -58
	add	hl, sp
	ld	sp, hl
	ld	iy, (ix + 6)
	ld	a, (ix + 9)
	ld	bc, (ix + 18)
	lea	hl, ix - 25
	ld	(ix - 55), hl
	lea	hl, ix - 46
	push	hl
	lea	hl, iy
	ld	(ix - 5), l
	ld	(ix - 4), h
	pop	hl
	ld	(ix - 6), a
	ld	de, (ix + 12)
	ld	(ix - 9), de
	ld	de, (ix + 15)
	ld	(ix - 12), de
	ld	(ix - 15), bc
	ld	a, (ix - 6)
	cp	a, 17
	jq	z, BB49_2
	jq	BB49_1
BB49_1:
	ld	hl, 1
	ld	(ix - 3), hl
	jq	BB49_27
BB49_2:
	ld	(ix - 58), hl
	ld	iy, (ix - 9)
	lea	hl, iy + 8
	ld	(ix - 18), hl
	ld	hl, (ix - 18)
	ld	a, (hl)
	cp	a, 2
	jq	nz, BB49_26
	jq	BB49_3
BB49_3:
	ld	iy, (ix - 18)
	ld	hl, (iy + 20)
	ld	a, (iy + 23)
	ld	(_netinfo+16), hl
	ld	(_netinfo+19), a
	ld	hl, (ix - 18)
	ld	de, 240
	add	hl, de
	ld	(ix - 21), hl
	jq	BB49_4
BB49_4:
	ld	hl, (ix - 21)
	ld	a, (hl)
	cp	a, -1
	jq	z, BB49_25
	jq	BB49_5
BB49_5:
	ld	hl, (ix - 21)
	ld	a, (hl)
	cp	a, 6
	jq	z, BB49_21
	jq	BB49_6
BB49_6:
	cp	a, 53
	jq	z, BB49_8
	jq	BB49_7
BB49_7:
	cp	a, 58
	jq	z, BB49_22
	jq	BB49_23
BB49_8:
	ld	iy, (ix - 21)
	ld	a, (iy + 2)
	cp	a, 2
	jq	nz, BB49_11
	jq	BB49_9
BB49_9:
	ld	a, (_phase)
	cp	a, 1
	jq	nz, BB49_11
	jq	BB49_10
BB49_10:
	ld	hl, (_dhcp_last_queued_msg)
	push	hl
	call	_web_popMessage
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	de, (ix - 55)
	ld	hl, L___const.fetch_dhcp_msg.beg_header
	ld	bc, 4
	ldir
	ld	de, (ix - 58)
	ld	hl, L___const.fetch_dhcp_msg.options_req
	ld	bc, 21
	ldir
	ld	hl, 261
	ex	de, hl
	ld	(ix - 49), de
	ld	hl, 1
	push	hl
	push	de
	call	_calloc
	ld	iy, 6
	add	iy, sp
	ld	sp, iy
	ld	(ix - 52), hl
	ld	de, (ix - 52)
	ld	hl, (ix - 55)
	ld	bc, 4
	ldir
	ld	iy, (ix - 18)
	ld	hl, (iy + 4)
	ld	a, (iy + 7)
	ld	iy, (ix - 52)
	ld	(iy + 4), hl
	ld	(iy + 7), a
	ld	iy, (ix - 52)
	lea	de, iy + 28
	ld	hl, _MAC_ADDR
	ld	bc, 6
	ldir
	ld	iy, (ix - 52)
	ld	de, 236
	add	iy, de
	ld	hl, 5472867
	ld	(iy), hl
	lea	hl, iy + 3
	ld	a, 99
	ld	(hl), a
	ld	hl, (ix - 52)
	ld	de, 240
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 58)
	ld	bc, 21
	ldir
	ld	hl, (_netinfo+16)
	ld	a, (_netinfo+19)
	ld	iy, (ix - 52)
	ld	de, 250
	add	iy, de
	ld	(iy), hl
	lea	hl, iy + 3
	ld	(hl), a
	ld	iy, (ix - 18)
	ld	hl, (iy + 16)
	ld	a, (iy + 19)
	ld	iy, (ix - 52)
	ld	de, 256
	add	iy, de
	ld	(iy), hl
	lea	hl, iy + 3
	ld	(hl), a
	ld	hl, (ix - 52)
	ld	de, 67
	push	de
	ld	de, 68
	push	de
	ld	de, -1
	push	de
	ld	de, -1
	push	de
	ld	de, 261
	push	de
	push	hl
	call	_web_PushUDPDatagram
	ld	iy, 18
	add	iy, sp
	ld	sp, iy
	ld	(_dhcp_last_queued_msg), hl
	ld	a, 2
	ld	(_phase), a
	jq	BB49_20
BB49_11:
	ld	iy, (ix - 21)
	ld	a, (iy + 2)
	cp	a, 5
	jq	nz, BB49_14
	jq	BB49_12
BB49_12:
	ld	a, (_phase)
	cp	a, 2
	jq	nz, BB49_14
	jq	BB49_13
BB49_13:
	ld	hl, (_dhcp_last_queued_msg)
	push	hl
	call	_web_popMessage
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, 0
	ld	(_dhcp_last_queued_msg), hl
	ld	iy, (ix - 18)
	ld	hl, (iy + 16)
	ld	a, (iy + 19)
	ld	(_IP_ADDR), hl
	ld	(_IP_ADDR+3), a
	ld	hl, (_src_mac_addr)
	ld	de, _netinfo+10
	ld	bc, 6
	ldir
	ld	a, 3
	ld	(_phase), a
	jq	BB49_19
BB49_14:
	ld	iy, (ix - 21)
	ld	a, (iy + 2)
	cp	a, 6
	jq	nz, BB49_18
	jq	BB49_15
BB49_15:
	ld	hl, (_dhcp_last_queued_msg)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jq	z, BB49_17
	jq	BB49_16
BB49_16:
	ld	hl, (_dhcp_last_queued_msg)
	push	hl
	call	_web_popMessage
	ld	hl, 3
	add	hl, sp
	ld	sp, hl
	ld	hl, 0
	ld	(_dhcp_last_queued_msg), hl
	jq	BB49_17
BB49_17:
	xor	a, a
	ld	(_phase), a
	call	_dhcp_init
	ld	hl, 10
	ld	(ix - 3), hl
	jq	BB49_27
BB49_18:
	jq	BB49_19
BB49_19:
	jq	BB49_20
BB49_20:
	jq	BB49_24
BB49_21:
	ld	iy, (ix - 21)
	ld	hl, (iy + 2)
	ld	a, (iy + 5)
	ld	(_netinfo+20), hl
	ld	(_netinfo+23), a
	jq	BB49_24
BB49_22:
	jq	BB49_24
BB49_23:
	jq	BB49_24
BB49_24:
	ld	iy, (ix - 21)
	or	a, a
	sbc	hl, hl
	ld	l, (iy + 1)
	ld	de, 2
	add	hl, de
	ex	de, hl
	ld	hl, (ix - 21)
	add	hl, de
	ld	(ix - 21), hl
	jq	BB49_4
BB49_25:
	jq	BB49_26
BB49_26:
	or	a, a
	sbc	hl, hl
	ld	(ix - 3), hl
	jq	BB49_27
BB49_27:
	ld	hl, (ix - 3)
	ld	iy, 58
	add	iy, sp
	ld	sp, iy
	pop	ix
	ret
	; section	.text,"ax",@progbits

	; section	.rodata,"a",@progbits
	; private	L_.str
L_.str:
	db	"GET", 0

	; section	.rodata,"a",@progbits
	; private	L_.str.1
L_.str.1:
	db	"POST", 0

	; section	.rodata,"a",@progbits
	; private	L_.str.2
L_.str.2:
	db	"&%s=%s", 0

	; section	.rodata,"a",@progbits
	; private	L_.str.3
L_.str.3:
	db	"%s=%s", 0

	; section	.rodata,"a",@progbits
	; private	L_.str.4
L_.str.4:
	db	"Content-Type: application/x-www-form-urlencoded", 13, 10, "Content-Length: %d", 13, 10, 13, 10, "%s", 0

	; section	.bss,"aw",@nobits
	; private	_listened_ports
_listened_ports:
	rb	3

	; section	.bss,"aw",@nobits
	; private	_send_queue
_send_queue:
	rb	3

	; section	.bss,"aw",@nobits
	; private	_http_data_list
_http_data_list:
	rb	3

	; section	.data,"aw",@progbits
	; private	_MAC_ADDR
_MAC_ADDR:
	db	$EA,$A5,$59,$9C,$C1,$1E

	; section	.bss,"aw",@nobits
	; private	_IP_ADDR
_IP_ADDR:
	rb	4

	; section	.bss,"aw",@nobits
	public	_netinfo
_netinfo:
	rb	24

	; section	.bss,"aw",@nobits
	; private	_web_PushIPv4Packet.nbpacket
_web_PushIPv4Packet.nbpacket:
	rb	2

	; section	.rodata,"a",@progbits
	; private	L___const.web_PushIPv4Packet.packet
L___const.web_PushIPv4Packet.packet:
	db	69
	db	16
	dw	0
	dw	0
	dw	64
	db	128
	db	0
	dw	0
	dd	0
	dd	0

	; section	.data,"aw",@progbits
	; private	_web_RequestPort.next_port
_web_RequestPort.next_port:
	dw	49152

	; section	.rodata,"a",@progbits
	; private	L_.str.5
L_.str.5:
	db	"http://", 0

	; section	.rodata,"a",@progbits
	; private	L___const.http_request.options
L___const.http_request.options:
	db	$02,$04,$02,$18

	; section	.rodata,"a",@progbits
	; private	L_.str.6
L_.str.6:
	db	"%s %s HTTP/1.1", 13, 10, "Host: %s", 13, 10, "%s", 13, 10, 0

	; section	.rodata,"a",@progbits
	; private	L_.str.7
L_.str.7:
	db	"/", 0

	; section	.rodata,"a",@progbits
	; private	L___const.fetch_http_msg.cont_len
L___const.fetch_http_msg.cont_len:
	db	"Content-Length:", 0

	; section	.rodata,"a",@progbits
	; private	L___const.fetch_http_msg.cont_enc
L___const.fetch_http_msg.cont_enc:
	db	"Transfer-Encoding: chunked", 13, 10, 0

	; section	.rodata,"a",@progbits
	; private	L___const.fetch_http_msg.varstorage_name
L___const.fetch_http_msg.varstorage_name:
	db	"WLCE0000", 0

	; section	.bss,"aw",@nobits
	; private	_src_mac_addr
_src_mac_addr:
	rb	3

	; section	.rodata,"a",@progbits
	; private	L___const.usbHandler.rndis_initmsg
L___const.usbHandler.rndis_initmsg:
	dd	2
	dd	24
	dd	0
	dd	1
	dd	0
	dd	1024

	; section	.rodata,"a",@progbits
	; private	L___const.usbHandler.rndis_setpcktflt
L___const.usbHandler.rndis_setpcktflt:
	dd	5
	dd	32
	dd	4
	dd	65806
	dd	4
	dd	20
	dd	0
	dd	45

	; section	.rodata,"a",@progbits
	; private	L___const.usbHandler.out_ctrl
L___const.usbHandler.out_ctrl:
	db	33
	db	0
	dw	0
	dw	0
	dw	0

	; section	.rodata,"a",@progbits
	; private	L___const.usbHandler.in_ctrl
L___const.usbHandler.in_ctrl:
	db	161
	db	1
	dw	0
	dw	0
	dw	1024

	; section	.data,"aw",@progbits
	; private	_dhcp_init.xid
_dhcp_init.xid:
	dd	66594361

	; section	.bss,"aw",@nobits
	; private	_phase
_phase:
	rb	1

	; section	.rodata,"a",@progbits
	; private	L___const.dhcp_init.beg_header
L___const.dhcp_init.beg_header:
	db	$01,$01,$06, 0

	; section	.rodata,"a",@progbits
	; private	L___const.dhcp_init.options_disc
L___const.dhcp_init.options_disc:
	db	$35,$01,$01,$37,$03,$01,$03,$06,$FF, 0

	; section	.bss,"aw",@nobits
	; private	_dhcp_last_queued_msg
_dhcp_last_queued_msg:
	rb	3

	; section	.rodata,"a",@progbits
	; private	L___const.fetch_dhcp_msg.beg_header
L___const.fetch_dhcp_msg.beg_header:
	db	$01,$01,$06, 0

	; section	.rodata,"a",@progbits
	; private	L___const.fetch_dhcp_msg.options_req
L___const.fetch_dhcp_msg.options_req:
	db	$35,$01,$03,$37,$03,$01,$03,$06,$36,$04, 0, 0, 0, 0, $32,$04, 0, 0, 0, 0, $FF

_usb_GetDescriptor:
	ld hl,_usbdrvce
	ld bc,54
	; sys_RunLibraryRoutine
_usb_ResetDevice:
	ld hl,_usbdrvce
	ld bc,57
	; sys_RunLibraryRoutine
_usb_ScheduleTransfer:
	ld hl,_usbdrvce
	ld bc,129
	; sys_RunLibraryRoutine
_usb_WaitForEvents:
	ld hl,_usbdrvce
	ld bc,12
	; sys_RunLibraryRoutine
_usb_SetConfiguration:
	ld hl,_usbdrvce
	ld bc,69
	; sys_RunLibraryRoutine
_usb_Transfer:
	ld hl,_usbdrvce
	ld bc,123
	; sys_RunLibraryRoutine
_usb_Cleanup:
	ld hl,_usbdrvce
	ld bc,3
	; sys_RunLibraryRoutine
_usb_GetDeviceEndpoint:
	ld hl,_usbdrvce
	ld bc,84
	; sys_RunLibraryRoutine
_usb_HandleEvents:
	ld hl,_usbdrvce
	ld bc,9
	; sys_RunLibraryRoutine
_usb_Init:
	ld hl,_usbdrvce
	ld bc,0
	; sys_RunLibraryRoutine

_realloc:
	call ti._frameset0
	ld hl,(ix+9)
	add hl,bc
	or a,a
	sbc hl,bc
	jr z,.fail
	push hl
	call bos.sys_Malloc
	ex hl,de
	pop bc
	jr c,.fail
	ld hl,(ix+6)
	push de
	ldir
	pop hl
	db $01
.fail:
	or a,a
	sbc hl,hl
	pop ix
	ret

_calloc:
	call ti._frameset0
	ld hl,(ix+6)
	ld bc,(ix+9)
	call ti._imulu
	push hl
	call bos.sys_Malloc
	pop bc
	jr c,.fail
	call ti.MemClear
	db $01
.fail:
	or a,a
	sbc hl,hl
	pop ix
_os_NextSymEntry:
_os_GetSymTablePtr:
	ret

__indcallhl:
	jp (hl)

_os_ChkFindSym:
	pop de,bc
	ex (sp),hl
	push bc,de
	ld de,ti.OP1
	ld a,c
	ld (de),a
	inc de
	call ti.Mov8b
	jp ti.ChkFindSym

_os_CreateAppVar:
	pop bc
	ex (sp),hl
	push bc
	call ti.Mov9ToOP1
	ld a,21
	jp ti.CreateVar

_srand:
	ld (__state),hl
	ld hl,__state
	ld (hl),e
	ld b,12
.setloop:
	inc hl
	ld (hl),b
	djnz .setloop
	ret

_random:
	ld	iy, __state
	ld	hl, (iy+0*4+0)
	push	hl
	ld	hl, (iy+0*4+2)
	push	hl
	lea	hl, iy+1*4
	lea	de, iy+0*4
	ld	bc, 3*4
	ldir
	pop	bc
	pop	de
	ld	h, d
	ld	l, e
	add	hl, hl
	add	hl, hl
	add	hl, hl
	ld	a, b
	xor	a, h
	ld	h, a
	xor	a, (iy+3*4+2)
	ld	(iy+3*4+3), a
	ld	b, a
	ld	a, c
	xor	a, l
	ld	l, a
	xor	a, (iy+3*4+1)
	ld	(iy+3*4+2), a
	xor	a, a
	add.s	hl, hl
	adc	a, a
	add.s	hl, hl
	adc	a, a
	add.s	hl, hl
	adc	a, a
	xor	a, d
	xor	a, (iy+3*4+0)
	ld	(iy+3*4+1), a
	ld	a, e
	xor	a, h
	ld	(iy+3*4+0), a
	ld	hl, (iy+3*4)
	ld	a, b
	ld	de, (iy+2*4)
	ld	c, (iy+2*4+3)
	add	hl, de
	ld e,c
	ret

__state := $D40000-16

_malloc := bos.sys_Malloc
_free := bos.sys_Free
__lcmpzero := ti._lcmpzero
_memcpy := ti._memcpy
__idivs := ti._idivs
__idivu := ti._idivu
__lsub := ti._lsub
__ishrs := ti._ishrs
__ishru := ti._ishru
__imulu := ti._imulu
__lxor := ti._lxor
__lcmpu := ti._lcmpu
__ldivu := ti._ldivu
_strncpy := ti._strncpy
__ladd := ti._ladd
_strlen := ti._strlen
__ishl := ti._ishl
__iand := ti._iand
__lshru := ti._lshru
__lnot := ti._lnot
__lshl := ti._lshl
__land := ti._land
__irems := ti._irems
__bshl := ti._bshl
_memcmp := ti._memcmp
___sprintf := ti.sprintf
_os_ArcChk := bos.fs_GetFreeSpace
	; ident	"clang version 14.0.0 (https://github.com/jacobly0/llvm-project a139def90d26173f771eb1eca797633d1fbb2797)"

load _lib_data: $-$$ from $$
end virtual

virtual _libraryexports
	load _libraryexports.data: $-$$ from $$
end virtual

db _libraryexports.data
db _lib_data


