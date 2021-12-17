;-------------------------------------------------------------------------------
include '../include/library.inc'
;-------------------------------------------------------------------------------

library 'FILEIOC', 7

;-------------------------------------------------------------------------------
; no dependencies
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; v1 functions
;-------------------------------------------------------------------------------
	export ti_CloseAll
	export ti_Open
	export ti_OpenVar
	export ti_Close
	export ti_Write
	export ti_Read
	export ti_GetC
	export ti_PutC
	export ti_Delete
	export ti_DeleteVar
	export ti_Seek
	export ti_Resize
	export ti_IsArchived
	export ti_SetArchiveStatus
	export ti_Tell
	export ti_Rewind
	export ti_GetSize
;-------------------------------------------------------------------------------
; v2 functions
;-------------------------------------------------------------------------------
	export ti_GetTokenString
	export ti_GetDataPtr
	export ti_Detect
	export ti_DetectVar
;-------------------------------------------------------------------------------
; v3 functions
;-------------------------------------------------------------------------------
	export ti_SetVar
	export ti_StoVar
	export ti_RclVar
	export ti_AllocString
	export ti_AllocList
	export ti_AllocMatrix
	export ti_AllocCplxList
	export ti_AllocEqu
;-------------------------------------------------------------------------------
; v4 functions
;-------------------------------------------------------------------------------
	export ti_DetectAny
	export ti_GetVATPtr
	export ti_GetName
	export ti_Rename
	export ti_RenameVar
;-------------------------------------------------------------------------------
; v5 functions
;-------------------------------------------------------------------------------
	export ti_ArchiveHasRoom

;-------------------------------------------------------------------------------
; v6 functions
;-------------------------------------------------------------------------------
	export ti_SetGCBehavior


;-------------------------------------------------------------------------------
TI_MAX_SIZE := 65505

;-------------------------------------------------------------------------------
ti_AllocString:
ti_AllocEqu:
; allocates space for a string/equation
; args:
;  sp + 3 : len of string/equation
;  sp + 6 : pointer to alloc routine
; return:
;  hl -> allocated space
	; ld	iy, 0
	; add	iy, sp
	; ld	hl, (iy + 3)
	; ld	iy, (iy + 6)
	; push	hl
	; inc	hl
	; inc	hl
	; call	__indcall
	; pop	de
	; ld	(hl), e
	; inc	hl
	; ld	(hl), d
	; dec	hl
	; ret

;-------------------------------------------------------------------------------
ti_AllocCplxList:
; allocates space for a complex list
; args:
;  sp + 3 : dim of list
;  sp + 6 : pointer to alloc routine
; return:
;  hl -> allocated space
	; ld	iy, 0
	; add	iy, sp
	; ld	hl, (iy + 3)
	; ld	iy, (iy + 6)
	; push	hl
	; add	hl, hl
	; jr	util_alloc_var

;-------------------------------------------------------------------------------
ti_AllocList:
; allocates space for a real list
; args:
;  sp + 3 : dim of list
;  sp + 6 : pointer to alloc routine
; return:
;  hl -> allocated space
	; ld	iy, 0
	; add	iy, sp
	; ld	hl, (iy + 3)
	; ld	iy, (iy + 6)
	; push	hl
	; jr	util_alloc_var

;-------------------------------------------------------------------------------
ti_AllocMatrix:
; allocates space for a matrix
; args:
;  sp + 3 : matrix rows
;  sp + 6 : matrix cols
;  sp + 9 : pointer to alloc routine
; return:
;  hl -> allocated space
	; ld	iy, 0
	; add	iy, sp
	; ld	h, (iy + 3)
	; ld	l, (iy + 6)
	; ld	iy, (iy + 9)
	; push	hl
	; mlt	hl
; util_alloc_var:
	; call	_HLTimes9
	; inc	hl
	; inc	hl
	; push	hl
	; call	__indcall
	; pop	de
	; pop	de
	; add	hl, de
	; or	a, a
	; sbc	hl, de
	; ret	z
	; ld	(hl), e
	; inc	hl
	; ld	(hl), d
	; dec	hl
	or a,a
	sbc hl,hl
	ret

;-------------------------------------------------------------------------------
ti_CloseAll:
; closes all currently open file handles
; args:
;  n/a
; return:
;  n/a
	ld	a, $80
	ld	(vat_ptr0 + 2), a
	ld	(vat_ptr1 + 2), a
	ld	(vat_ptr2 + 2), a
	ld	(vat_ptr3 + 2), a
	ld	(vat_ptr4 + 2), a
	ret

;-------------------------------------------------------------------------------
ti_Resize:
; resizes an appvar variable
; args:
;  sp + 3 : new size
;  sp + 6 : slot index
; return:
;  hl = new size if no failure
	pop	de
	pop	hl			; hl = new size
	pop	bc			; c = slot
	push	bc
	push	hl
	push	de
	call	util_is_slot_open
	jp	z, util_ret_neg_one
	ld	de, TI_MAX_SIZE
	or	a,a
	sbc	hl,de
	add	hl,de
	push	af
	push	hl
	call	ti_Rewind.rewind	; rewind file offset
	pop	hl
	pop	af
	jp	nc,util_ret_null	; return if too big
	push	hl
	call	util_get_slot_size
	pop	hl
	ret	z
	push	hl
	call	util_get_vat_ptr
	pop	de
	ld	bc,(hl)
	push	hl,bc,de
	call	bos.fs_SetSize
	pop	bc,de,de
	ret	c
	ex	hl,de
	ld	(hl),de
	push	bc
	pop	hl
	ret

;-------------------------------------------------------------------------------
ti_IsArchived:
; Checks if a variable is archived
; args:
;  sp + 3 : Slot number
; return:
;  0 if not archived
	pop	de
	pop	bc
	push	bc
	push	de
	call	util_is_slot_open
	jp	z, util_ret_null
util_is_in_ram:
	call	util_get_vat_ptr
	ld	hl, (hl)
	push	hl
	call	bos.fs_GetFDPtr
	pop	de
	ld	de,$D00000
	xor	a,a
	sbc	hl,de
	adc	a,a
	ret

;-------------------------------------------------------------------------------
ti_OpenVar:
; opens a variable
; args:
;  sp + 3 : pointer to variable name
;  sp + 6 : open flags
;  sp + 9 : variable Type
; return:
;  slot index if no error
	ld	iy, 0
	add	iy, sp
	ld	a, (iy + 9)
;	jr	ti_Open.start		; emulated by dummifying next instruction
	db	$fe			; ld a,appVarObj -> cp a,$3e \ dec d
;assert appVarObj = $15

;-------------------------------------------------------------------------------
ti_Open:
; opens an appvar, acting as a file handle
; args:
;  sp + 3 : pointer to appvar name
;  sp + 6 : open flags
; return:
;  a = slot index if no error
	ld	a, ti.AppVarObj
.start:
	ld	(.smc_type), a
	ld	(bos.fsOP1), a
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	c,1
	ld	a,$80
	ld	b,5
.find_slot_loop:
	ld	hl, vat_ptr0+2
	cp	a,(hl)
	jr	z, .slot
	inc c
	inc hl
	inc hl
	inc hl
	djnz	.find_slot_loop
	jp	util_ret_null_pop_ix
.slot:
	ld	a,c
	ld	(curr_slot), a
	ld	hl, (ix + 6)
	ld	de, ti.OP1 + 1
	call	bos._Mov8b
	xor	a, a
	ld	(de), a
	ld	hl, (ix + 9)
	ld	a, (hl)
	cp	a, 'w'
	ld	iy, ti.flags
	jr	nz, .no_overwite
	call	bos._DelVar
.no_overwite:
	ld	hl, (ix + 9)
	ld	a, (hl)
	cp	a, 'r'
	jr	z, .mode
	cp	a, 'a'
	jr	z, .mode
	cp	a, 'w'
	jp	nz, util_ret_null_pop_ix
.mode:
	call	bos._ChkFindSym
	jr	c, .not_found
	push	hl
	ld	hl, (ix + 9)
	ld	a, (hl)
	cp	a, 'r'
	pop	hl
	jp	nz, util_ret_null_pop_ix
	jr	.save_ptrs
.not_found:
	ld	hl, (ix + 9)
	ld	a, (hl)
	cp	a, 'r'
	jp	z, util_ret_null_pop_ix
	or	a, a
	sbc	hl, hl
	ld	a, 0
.smc_type := $-1
	call	bos._CreateVar
.save_ptrs:
	push	hl
	call	util_get_vat_ptr
	pop	bc
	ld	(hl), bc
	call	util_get_data_ptr
	ld	(hl), de
	ld	bc, 0
	ld	hl, (ix + 9)
	ld	a, 'a'
	cp	a, (hl)
	call	z, util_get_slot_size
	call	util_set_offset
	pop	ix
	xor	a, a
	sbc	hl, hl
	ld	a, (curr_slot)
	ld	l, a
	ret

;-------------------------------------------------------------------------------
ti_SetArchiveStatus:
; sets the archive status of a slot index
; args:
;  sp + 3 : boolean value
;  sp + 6 : slot index
; return:
;  n/a
	pop	hl
	pop	de
	pop	bc
	push	bc
	push	de
	push	hl
	call	util_is_slot_open
	jp	z, util_ret_null
	ld	a, e
	push	af
	call	util_get_vat_ptr
	ld	hl, (hl)
	push	hl
	call	bos.fs_GetFDPtr
	pop	de
	call	_ChkInRam
	push	af
	pop	bc
	pop	af
	or	a, a
	push	bc
	jr	z, .set_not_archived
.set_archived:
	pop	af
	call	z, bos.fs_ArcUnarcFD
	jr	.relocate_var
.set_not_archived:
	pop	af
	call	nz, bos.fs_ArcUnarcFD
.relocate_var:
	push	hl
	call	util_get_vat_ptr
	pop	bc
	ld	(hl),bc
	push	hl
	call`	bos.fs_GetFDPtr
	ex	(sp),hl
	call	util_get_data_ptr
	pop	de
	ld	(hl), de
	ret

;-------------------------------------------------------------------------------
ti_Write:
; writes a chunk of data into a slot handle
; args:
;  sp + 3 : pointer to data to write
;  sp + 6 : size of chunks in bytes
;  sp + 9 : number of chunks
;  sp + 12 : slot index
; return:
;  hl = number of chunks written if success
	ld hl,-6
	call ti._frameset
	ld c,(ix+15)
	call util_is_slot_open
	jq nz,util_ret_null_pop_ix
	call util_get_vat_ptr
	ld hl,(hl)
	ld (ix-3),hl
	call util_get_offset
	ld a,(ix+12)
	ld hl,(ix+9)
	call ti._imul_b
	add hl,bc ; offset+len*count
	ld (ix-6),hl
	push hl
	call util_get_slot_size
	pop hl
	or a,a
	sbc hl,bc
	jr c,.dont_resize
	add hl,bc
	ld de,(ix-3)
	push de,hl
	call bos.fs_SetSize
	jq c,.done
	ld (ix-3),hl
	pop bc,bc
.dont_resize:
	call util_get_offset
	push bc
	ld bc,(ix-3)
	push bc
	ld bc,(ix+12)
	push bc
	ld bc,(ix+9)
	push bc
	ld bc,(ix+6)
	push bc
	call bos.fs_Write
	pop bc,bc,bc,bc,bc
	jr c,.done
	push hl
	call util_get_vat_ptr
	pop de
	ld (hl),de
	ld bc,(ix-6)
	call util_set_offset
.done:
	ld sp,ix
	pop ix
	ret

;-------------------------------------------------------------------------------
ti_Read:
; reads a chunk of data from a slot handle
; args:
;  sp + 3 : pointer to buffer to read into
;  sp + 6 : size of chunks in bytes
;  sp + 9 : number of chunks
;  sp + 12 : slot index
; return:
;  hl = number of chunks read if success
	call ti._frameset0
	ld c,(ix+15)
	call util_is_slot_open
	jq nz,util_ret_null_pop_ix
	call util_get_vat_ptr
	ld hl,(hl)
	ld bc,-$E
	add hl,bc
	push hl
	call util_get_offset
	pop hl
	push bc,hl
	ld bc,(ix+12)
	push bc
	ld bc,(ix+9)
	push bc
	ld bc,(ix+6)
	push bc
	call bos.fs_Read
	pop bc,de,hl,bc,bc
	ld b,e
	ex hl,de
	or a,a
	sbc hl,hl
.count_loop:
	add hl,de
	djnz .count_loop
	push hl
	pop bc
	pop ix
	jq util_set_offset

;-------------------------------------------------------------------------------
ti_GetC:
; gets a single byte character from a slot, advances the offset
; args:
;  sp + 3 : slot index
; return:
;  hl = character read if success
	pop hl
	pop bc
	push bc
	push hl
	call util_is_slot_open
	jq nz,util_ret_neg_one
	call util_get_slot_size
	push bc
	call util_get_offset
	pop hl
	or a,a
	dec hl
	sbc hl,bc
	jq c,util_ret_neg_one
	call util_get_data_ptr
	ld de,(hl)
	ex hl,de
	add hl,bc
	ld a,(hl)
	inc bc
	push af
	call util_set_offset
	pop af
	or a,a
	sbc hl,hl
	ld l,a
	ret

;-------------------------------------------------------------------------------
ti_PutC:
; Performs an fputc on an AppVar
; args:
;  sp + 3 : Character to place
;  sp + 6 : Slot number
; return:
;  hl = Character written if no failure
	pop hl
	pop de
	pop bc
	push bc
	push de
	push hl
	ld a,e
	ld (.buffer),a
	call util_is_slot_open
	jq nz,util_ret_neg_one
	call util_get_vat_ptr
	ld bc,-$E
	add hl,bc
	push hl
	call util_get_offset
	pop hl
	push bc,hl
	push bc
	call util_get_slot_size
	pop hl
	inc hl
	or a,a
	sbc hl,bc
	add hl,bc
	pop bc
	push bc
	push bc,hl
	call nc,bos.fs_SetSize
	pop hl,bc

	ld bc,0
.buffer:=$-3
	push bc
	call bos.fs_WriteByte
	pop bc,bc,bc
	inc bc
	ld hl,(.buffer)
	jq util_set_offset


;-------------------------------------------------------------------------------
ti_Seek:
; seeks to a particular offset in an slot index
; args:
;  sp + 3 : positional offset to seek to
;  sp + 6 : origin position
;  sp + 9 : slot index
; return:
;  hl = -1 if failure
	ld	iy, 0
	add	iy, sp
	ld	de, (iy + 3)
	ld	c, (iy + 9)
	call	util_is_slot_open
	jp	z, util_ret_neg_one
	ld	a, (iy + 6)		; origin location
	or	a, a
	jr	z, .seek_set
	dec	a
	jr	z, .seek_curr
	dec	a
	jp	nz, util_ret_neg_one
.seek_end:
	push	de
	call	util_get_slot_size
.seek_set_asm:
	pop	hl
	add	hl, bc
	ex	de, hl
.seek_set:
	call	util_get_slot_size
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	push	de
	pop	bc
	jp	c, util_ret_neg_one
	jp	util_set_offset
.seek_curr:
	push	de
	call	util_get_offset
	jr	.seek_set_asm


;-------------------------------------------------------------------------------
ti_DeleteVar:
; deletes an arbitrary variable
; args:
;  sp + 3 : pointer to variable name
;  sp + 6 : variable type
; return:
;  hl = 0 if failure
	pop	hl
	pop	de
	pop	bc
	push	bc
	push	de
	push	hl
	ld	a, c
;	jr	ti_Delete.start		; emulated by dummifying next instruction:
	db	$fe			; ld a,appVarObj -> cp a,$3E \ dec d
;assert appVarObj = $15

;-------------------------------------------------------------------------------
ti_Delete:
; deletes an appvar
; args:
;  sp + 3 : pointer to appvar name
; return:
;  hl = 0 if failure
	ld	a,ti.AppVarObj
; .start:
	pop	de
	pop	hl
	push	hl
	push	de
	dec	hl
	push	af
	call	bos._Mov9ToOP1
	pop	af
	ld	(bos.fsOP1), a
	call	bos._ChkFindSym
	jp	c, util_ret_null
	call	bos._DelVar
	scf
	sbc	hl, hl
	ret

;-------------------------------------------------------------------------------
ti_Rewind:
; Performs an frewind on a variable
; args:
;  sp + 3 : Slot number
; return:
;  hl = -1 if failure
	pop	hl
	pop	bc
	push	bc
	push	hl
	call	util_is_slot_open
	jq nz, util_ret_neg_one
.rewind:
	ld	bc, 0
	call	util_set_offset
	or	a, a
	sbc	hl, hl
	ret

;-------------------------------------------------------------------------------
ti_Tell:
; gets the current offset of an open slot index
; args:
;  sp + 3 : slot index
; return:
;  hl = -1 if failure
	pop	hl
	pop	bc
	push	bc
	push	hl
	call	util_is_slot_open
	jq	nz, util_ret_neg_one
	call	util_get_offset
	push	bc
	pop	hl
	ret

;-------------------------------------------------------------------------------
ti_GetSize:
; gets the size of an open slot index
; args:
;  sp + 3 : slot index
; return:
;  hl = -1 if failure
	pop	hl
	pop	bc
	push	bc
	push	hl
	call	util_is_slot_open
	jq	nz, util_ret_neg_one
	call	util_get_slot_size
	push	bc
	pop	hl
	ret

;-------------------------------------------------------------------------------
ti_Close:
; closes an open slot index
; args:
;  sp + 3 : slot index
; return:
;  n/a
	pop	hl
	pop	bc
	push	bc
	push	hl
	ld	a, c
	ld	(curr_slot), a
	call	util_get_vat_ptr
	inc	hl
	inc	hl
	ld	(hl), $80
	ret

;-------------------------------------------------------------------------------
ti_DetectAny:
; finds any variable that starts with some data
; args:
;  sp + 3 : address of pointer to being search
;  sp + 6 : pointer to null terminated string of data to search for
;  sp + 9 : pointer storage of type of variable found
; return:
;  hl -> name of variable
;	ld	a,$ff
;	jr	ti_Detect.start_flag

;-------------------------------------------------------------------------------
ti_DetectVar:
; finds a variable that starts with some data
; args:
;  sp + 3 : address of pointer to being search
;  sp + 6 : pointer to null terminated string of data to search for
;  sp + 9 : type of variable to search for
; return:
;  hl -> name of variable
;	ld	hl,9
;	add	hl,sp
;	ld	a,(hl)
;	jr	ti_Detect.start		; emulated by dummifying next instruction:
;	db	$fe			; ld a,appVarObj -> cp a,$3E \ dec d
;assert appVarObj = $15

;-------------------------------------------------------------------------------
ti_Detect:
; finds an appvar that starts with some data
;  sp + 3 : address of pointer to being search
;  sp + 6 : pointer to null terminated string of data to search for
; return:
;  hl -> name of variable
	; ld	a,appVarObj
; .start:
	; ld	(.smc_type), a
	; xor	a,a
; .start_flag:
	; ld	(.smc_flag), a
	; push	ix
	; ld	ix, 0
	; add	ix, sp
	; ld	hl, (ix + 9)
	; add	hl, bc
	; or	a, a
	; sbc	hl, bc
	; jr	nz, .detectall		; if null, then detect everything
	; ld	hl, .fdetectall
	; ld	(ix + 9), hl
; .detectall:
	; ld	hl, (ix + 6)
	; add	hl, bc
	; or	a, a
	; sbc	hl, bc
	; jr	z, .fstart
	; ld	hl, (hl)
	; add	hl, bc
	; or	a, a
	; sbc	hl, bc
	; jr	nz, .fdetect
; .fstart:
	; ld	hl, (progPtr)
; .fdetect:
	; ld	de, (pTemp)
	; or	a, a
	; sbc	hl, de
	; jr	c, .finish
	; jr	z, .finish
	; add	hl, de
	; jr	.fcontinue

; .finish:
	; xor	a, a
	; sbc	hl, hl
	; pop	ix
	; ret

; .fcontinue:
	; push	hl
	; ld	a, 0
; .smc_flag := $-1
	; or	a, a
	; ld	a, (hl)
	; jr	z, .fdetectnormal
	; ld	de, (ix + 12)
	; ld	(de), a
	; jr	.fgoodtype
; .fdetectnormal:
	; cp	a, appVarObj
; .smc_type := $-1
	; jr	nz, .fskip
; .fgoodtype:
	; dec	hl
	; dec	hl
	; dec	hl
	; ld	e, (hl)
	; dec	hl
	; ld	d, (hl)
	; dec	hl
	; ld	a, (hl)
	; call	_SetDEUToA
	; ex	de,hl
	; cp	a, $d0
	; jr	nc, .finram
	; ld	de, 9
	; add	hl, de			; skip archive vat stuff
	; ld	e, (hl)
	; add	hl, de
	; inc	hl
; .finram:
	; inc	hl
	; inc	hl			; hl -> data
	; ld	bc, (ix + 9)
; .fcmp:
	; ld	a, (bc)
	; or	a, a
	; jr	z, .ffound
	; cp	a, (hl)
	; inc	bc
	; inc	de
	; inc	hl
	; jr	z, .fcmp		; check the string in memory
; .fskip:
	; pop	hl
	; call	.fbypassname
	; jr	.fdetect

; .ffound:
	; pop	hl
	; call	.fbypassname
	; ex	de, hl
	; ld	hl, (ix + 6)
	; add	hl, de
	; or	a, a
	; sbc	hl, de
	; jr	z, .isnull
	; ld	(hl), de
; .isnull:
	; ld	hl, OP6
	; pop	ix
	; ret

; .fbypassname:				; bypass the name in the vat
	; ld	de, OP6
	; ld	bc, -6
	; add	hl, bc
	; ld	b, (hl)
	; dec	hl
; .loop:
	; ld	a, (hl)
	; ld	(de), a
	; dec	hl
	; inc	de
	; djnz	.loop
	; xor	a, a
	; ld	(de), a

;.fdetectall:
;	dl	0

;-------------------------------------------------------------------------------
ti_GetTokenString:
; return pointer to next token string
; args:
;  sp + 3 : slot index
; return:
;  hl -> os string to display
	; ld	iy, 0
	; add	iy, sp
	; ld	a, 1
	; ld	(.smc_length), a
	; ld	hl, (iy + 3)
	; ld	hl, (hl)
	; push	hl
	; ld	a, (hl)
	; call	_Isa2ByteTok
	; ex	de, hl
	; jr	nz, .not2byte
	; inc	de
	; ld	hl, .smc_length
	; inc	(hl)
; .not2byte:
	; inc	de
	; ld	hl, (iy + 3)
	; ld	(hl), de
	; pop	hl
	; push	iy
	; ld	iy, ti.flags
	; call	_Get_Tok_Strng
	; pop	iy
	; ld	hl, (iy + 9)
	; add	hl, bc
	; or	a, a
	; sbc	hl, bc
	; jr	z, .skip
	; ld	(hl), bc
; .skip:
	; ld	hl, (iy + 6)
	; add	hl, bc
	; or	a, a
	; sbc	hl ,bc
	; jr	z, .skipstore
	; ld	(hl), 1
; .smc_length := $-1
; .skipstore:
	; ld	hl, OP3
	or a,a
	sbc hl,hl
	ret

;-------------------------------------------------------------------------------
ti_GetDataPtr:
; return a pointer to the current location in the given variable
; args:
;  sp + 3 : slot index
; return:
;  hl -> current offset data
	pop	de
	pop	bc
	push	bc
	push	de
	call	util_is_slot_open
	jq	nz, util_ret_null
	call	util_get_data_ptr
	ld hl,(hl)
	push hl
	call	util_get_offset
	pop	hl
	add	hl,bc
	ret

;-------------------------------------------------------------------------------
ti_GetVATPtr:
; return a pointer to the vat location in the given variable
; args:
;  sp + 3 : slot index
; return:
;  hl -> vat location of variable
	pop	de
	pop	bc
	push	bc
	push	de
	call	util_is_slot_open
	jq	nz, util_ret_null
	call	util_get_vat_ptr
	ld	hl, (hl)
	ret

;-------------------------------------------------------------------------------
ti_GetName:
; gets the variable name of an open slot index
; args:
;  sp + 3 : name buffer
;  sp + 6 : slot index
; return:
;  n/a
	pop	de
	pop	hl
	pop	bc
	push	bc
	push	hl
	push	de
	push	hl
	call	util_is_slot_open
	pop	de
	ret	nz
	call	util_get_vat_ptr
	ld	hl, (hl)
	push hl,de
	call bos.fs_CopyFileName
	pop bc,bc
	ret
	; ld	bc, -6
	; add	hl, bc
	; ld	b, (hl)			; length of name
	; dec	hl
; .copy:
	; ld	a, (hl)
	; ld	(de), a
	; inc	de
	; dec	hl
	; djnz	.copy
	; xor	a, a
	; ld	(de), a			; terminate the string
	; ret

;-------------------------------------------------------------------------------
ti_RenameVar:
; renames a variable with a new name
; args:
;  sp + 3 : old name pointer
;  sp + 6 : new name pointer
;  sp + 9 : variable type
; return:
;  a = 0 if success
;  a = 1 if new file already exists
;  a = 2 if old file does not exist
;  a = 3 if other error
	ld	iy, 0
	add	iy, sp
	ld	a, (iy + 9)
;	ld	iy, ti.flags		; probably not needed
;	jr	ti_Rename.start		; emulated by dummifying next instruction
	db	$fe			; ld a,appVarObj -> cp a,$3E \ dec d

;-------------------------------------------------------------------------------
ti_Rename:
; renames an appvar with a new name
; args:
;  sp + 3 : old name pointer
;  sp + 6 : new name pointer
; return:
;  a = 0 if success
;  a = 1 if new file already exists
;  a = 2 if old file does not exist
;  a = 3 if other error
	ld	a,ti.AppVarObj		; file type
.start:
	pop	bc
	pop	hl
	pop	de
	push	de			; de -> new name
	push	hl			; hl -> old name
	push	bc
	push	de			; new
	ld	de, bos.fsOP2
	ld	(de), a
	inc	de
	call	bos._Mov8b
	pop	hl			; new name
	ld	de, bos.fsOP1 + 1
	call	bos._Mov8b
	call	bos._ChkFindSym
	jr	nc, .return_1		; check if name already exists
.locate_program:
	call	bos._ChkFindSym		; find old name
	jr	c, .return_2 ;fail if old name doesn't exist
	ld a,e   ;zero the latter nibble to get the file descriptor
	and a,$F0
	ld e,a
	ld hl,bos.fsOP2+1 ;old name
	ld bc,.tivars_dir
	push de,hl,bc
	call bos.fs_RenameFile
	pop bc,bc,bc
	xor	a, a
	ret
.return_1:
	pop	de			; new name
	ld	a, 1
	ret
.return_2:
	pop	de			; new name
	ld	a, 2
	ret
.tivars_dir:
	db "/usr/tivars",0

;-------------------------------------------------------------------------------
ti_SetVar:
; sets an os variable structure value
; args:
;  sp + 3 : type of variable to set
;  sp + 6 : pointer to name of variable
;  sp + 9 : pointer to data to set
; return:
;  a = any error code, 0 if success
	; push	ix
	; ld	ix, 0
	; add	ix, sp
	; ld	hl, (ix + 9)		; pointer to data
	; ld	a, (ix + 6)
	; call	util_set_var_str
	; call	_ChkFindSym
	; call	nc, _DelVarArc
	; ld	a, (ix + 6)
	; ld	hl, (ix + 12)
	; and	a, $3f
	; call	_DataSize
	; pop	ix
	; push	hl
	; ex	de, hl
	; dec	hl
	; dec	hl
	; call	_CreateVar
	; inc	bc
	; inc	bc
	; pop	hl
	; ldir
	; xor	a, a
	; ret

;-------------------------------------------------------------------------------
ti_StoVar:
; stores an os variable to a variable data structure
; args:
;  sp + 3 : type of variable to store to
;  sp + 6 : pointer to data to store to
;  sp + 9 : type of variable to get from
;  sp + 12 : pointer to data to get from
; return:
;  a = any error code, 0 if success
	; ld	iy, 0
	; add	iy, sp
	; ld	hl, (iy + 12)		; pointer to data
	; call	util_set_var_str
	; ld	a, (iy + 9)
	; or	a, a			; if real look up the variable
	; jr	z, .iscr
	; cp	a, $0c			; if cplx look up the variable
	; jr	nz, .notcr
; .iscr:
	; call	_FindSym
	; jp	c, .notcr		; fill it with zeros
	; and	a, $3f
	; ex	de, hl
	; call	_Mov9OP1OP2
; .notcr:
	; call	_PushOP1
	; ld	hl, (iy + 6)		; pointer to var string
	; ld	a, (iy + 3)
	; call	util_set_var_str
	; ld	iy, ti.flags
	; ld	hl, util_ret_neg_one_byte
	; call	_PushErrorHandler
	; call	_StoOther
	; call	_PopErrorHandler
	; xor	a, a
	; ret

;-------------------------------------------------------------------------------
ti_RclVar:
; gets a pointer to a variable data structure
; args:
;  sp + 3 : pointer to variable name string
;  sp + 6 : pointer to data structure pointer
; return:
;  a = type of variable
	; ld	iy, 0
	; add	iy, sp
	; ld	hl, (iy + 6)		; pointer to data
	; ld	a, (iy + 3)		; var type
	; ld	iy, ti.flags
	; call	util_set_var_str
	; call	_FindSym
	; jp	c, util_ret_neg_one_byte
	; push	af
	; call	_ChkInRAM
	; pop	bc
	; ld	a, b
	; jp	nz, util_ret_neg_one_byte
	; ld	iy, 0
	; add	iy, sp
	; and	a, $3f
	; cp	a, (iy + 3)		; var type
	; jp	nz, util_ret_neg_one_byte
	; ld	hl, (iy + 9)
	; ld	(hl), de
	scf
	sbc	a,a
	ret

;-------------------------------------------------------------------------------
ti_ArchiveHasRoom:
; checks if there is room in the archive before a garbage collect
; args:
;  sp + 3 : number of bytes to store into the archive
; return:
;  true if there is room, false if not
	; pop	de
	; ex	(sp),hl
	; push	de
; util_ArchiveHasRoom:
	; ld	bc,12
	; add	hl,bc
	; call	_FindFreeArcSpot
	; ld	a,1
	; ret	nz
	; dec	a

;-------------------------------------------------------------------------------
ti_SetGCBehavior:
;Set routines to run before and after a garbage collect would be triggered.
; args:
;   sp + 3 : pointer to routine to be run before. Set to 0 to use default handler.
;	sp + 6 : pointer to routine to be run after. Set to 0 to use default handler.
; return:
;   None
	; pop	de
	; pop	bc
	; ex	(sp),hl
	; push	bc
	; push	de
	; add	hl,de
	; or	a,a
	; sbc	hl,de
	; jr	nz,.notdefault1
	; ld	hl,util_post_gc_default_handler
; .notdefault1:
	; ld	(util_post_gc_handler),hl
	; sbc	hl,hl
	; adc	hl,bc
	; jr	nz,.notdefault2
	; ld	hl,util_pre_gc_default_handler
; .notdefault2:
	; ld	(util_pre_gc_handler),hl
;util_post_gc_default_handler := util_no_op
;util_pre_gc_default_handler := util_no_op

;-------------------------------------------------------------------------------
; internal library routines
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
util_skip_archive_header:
; in:
;  hl -> start of archived vat entry
; out:
;  hl -> actual variable data
	; ex	de, hl
	; ld	bc, 9
	; add	hl, bc
	; ld	c, (hl)
	; inc	hl
	; add	hl, bc
	; ex	de, hl
util_no_op:
	ret

;-------------------------------------------------------------------------------
util_set_var_str:
; in:
;  hl -> string
;  a = type
; out:
;  OP1 = variable combo
	; ld	de, OP1 + 1
	; call	_Mov8b
	; and	a, $3f
	; ld	(OP1), a
	ret

;-------------------------------------------------------------------------------
util_insert_mem:
	; push	hl
	; ld	hl, (hl)
	; push	hl
	; call	util_get_offset
	; pop	hl
	; add	hl, bc
	; inc	hl			; bypass size bytes
	; inc	hl
	; ex	de, hl
	; ld	hl, (resize_amount)
	; push	hl
	; push	de
	; call	_EnoughMem
	; pop	de
	; pop	hl
	; jr	c, util_ret_null_byte
	; call	_InsertMem
	; pop	hl
	; ld	hl, (hl)
	; push	hl
	; ld	de, 0
	; ld	e, (hl)
	; inc	hl
	; ld	d, (hl)
	; ex	de, hl
	; ld	bc, (resize_amount)
	; add	hl, bc			; increase by 5
	; jr	util_save_size
util_delete_mem:
	; call	util_get_data_ptr
	; push	hl
	; ld	hl, (hl)
	; push	hl
	; call	util_get_offset
	; pop	hl
	; add	hl, bc
	; inc	hl
	; inc	hl
	; ld	de, (resize_amount)
	; call	_DelMem
	; pop	hl
	; ld	hl, (hl)
	; push	hl
	; ld	de, 0
	; ld	e, (hl)
	; inc	hl
	; ld	d, (hl)
	; ex	de, hl
	; ld	bc, (resize_amount)
	; or	a, a
	; sbc	hl, bc			; decrease amount
util_save_size:
	ex	de, hl
	pop	hl			; pointer to size bytes location
	ld	(hl), e
	inc	hl
	ld	(hl), d			; write new size
util_ret_neg_one_byte:
	ld	a, 255
	ret
util_ret_null_byte:
	xor	a, a
	ret

util_ret_null_pop_ix:
	pop	ix
util_ret_null:
	xor	a, a
	sbc	hl, hl
	ret
util_ret_neg_one:
	scf
	sbc	hl, hl
	ret

util_is_slot_open:
	ld	a, c
	ld	(curr_slot), a
	push	hl
	call	util_get_vat_ptr
	inc	hl
	inc	hl
	bit	7, (hl)
	pop	hl
	ret
util_get_vat_ptr:
	ld	a, (curr_slot)
	ld	hl, vat_ptrs
	dec a
	ret z
	ld c,a
	add a,a
	add a,c
	jp bos.sys_AddHLAndA
util_get_data_ptr:
	ld	a, (curr_slot)
	ld	hl, data_ptrs
	dec a
	ret z
	ld c,a
	add a,a
	add a,c
	jp bos.sys_AddHLAndA
util_get_offset_ptr:
	push	bc
	or	a,a
	sbc	hl,hl
	ld	a, (curr_slot)
	ld	b,a
	add	a,a
	add	a,b
	ld	l,a
	ld	bc, variable_offsets
	add	hl,bc
	pop	bc
	ret
util_get_slot_size:
	call	util_get_vat_ptr
	ld	hl,(hl)
	ld	bc, 0
	ld	c,$E
	add	hl,bc
	ld	c, (hl)
	inc	hl
	ld	b, (hl)
	ret
util_get_offset:
	call	util_get_offset_ptr
	ld	bc, (hl)
	ret
util_set_offset:
	call	util_get_offset_ptr
	ld	(hl), bc
	ret

util_get_open_slot:
	ld b,5
	ld hl,vat_ptrs+2
.loop:
	bit 7,(hl)
	jr z,.return
	inc hl
	inc hl
	inc hl
	djnz .loop
	scf
	ret
.return:
	ld a,6
	sub a,b
	dec hl
	dec hl
	ret

; util_Arc_Unarc: ;properly handle garbage collects :P
	; call	_ChkInRAM
	; jp	nz,_Arc_Unarc ;if the file is already in archive, we won't trigger a gc
	; ex	hl,de
	; call	_LoadDEInd_s
	; ex	hl,de
	; call	util_ArchiveHasRoom
	; jp	nz,_Arc_Unarc ;gc will not be triggered
	; call	util_pre_gc_default_handler
; util_pre_gc_handler:=$-3
	; call	_Arc_Unarc
	; jp	util_post_gc_default_handler
; util_post_gc_handler:=$-3



;-------------------------------------------------------------------------------
; Internal library data
;-------------------------------------------------------------------------------


vat_ptrs:
vat_ptr0:
	dl $800000
vat_ptr1:
	dl $800000
vat_ptr2:
	dl $800000
vat_ptr3:
	dl $800000
vat_ptr4:
	dl $800000
data_ptrs:
data_ptr0:
	dl 0
data_ptr1:
	dl 0
data_ptr2:
	dl 0
data_ptr3:
	dl 0
data_ptr4:
	dl 0
curr_slot:
	db 0
variable_offsets:
	dl	5 dup 0
