;-------------------------------------------------------------------------------
include '../include/library.inc'
;-------------------------------------------------------------------------------

library FILEIOC, 8

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
; v7 functions
;-------------------------------------------------------------------------------
; No new functions, but a change was made to slot openness managemnent such that
; it is no longer necessary to call `ti_CloseAll` in initialization. New
; programs omitting this initialization require this change.
;-------------------------------------------------------------------------------
; v8 functions
;-------------------------------------------------------------------------------
	export ti_ArchiveHasRoomVar

;-------------------------------------------------------------------------------
vat_ptr0 := $d0244e
vat_ptr1 := $d0257b
vat_ptr2 := $d0257e
vat_ptr3 := $d02581
vat_ptr4 := $d02584
data_ptr0 := $d0067e
data_ptr1 := $d00681
data_ptr2 := $d01fed
data_ptr3 := $d01ff3
data_ptr4 := $d01ff9
resize_amount := $e30c0c
curr_slot := $e30c11
TI_MAX_SIZE := 65505
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
ti_AllocString:
ti_AllocEqu:
; allocates space for a string/equation
; args:
;  sp + 3 : len of string/equation
;  sp + 6 : pointer to alloc routine
; return:
;  hl -> allocated space
	ld	iy, 0
	add	iy, sp
	ld	hl, (iy + 3)
	ld	iy, (iy + 6)
	push	hl
	inc	hl
	inc	hl
	call	ti._indcall
	pop	de
	ld	(hl), e
	inc	hl
	ld	(hl), d
	dec	hl
	ret

;-------------------------------------------------------------------------------
ti_AllocCplxList:
; allocates space for a complex list
; args:
;  sp + 3 : dim of list
;  sp + 6 : pointer to alloc routine
; return:
;  hl -> allocated space
	ld	iy, 0
	add	iy, sp
	ld	hl, (iy + 3)
	ld	iy, (iy + 6)
	push	hl
	add	hl, hl
	jr	util_alloc_var

;-------------------------------------------------------------------------------
ti_AllocList:
; allocates space for a real list
; args:
;  sp + 3 : dim of list
;  sp + 6 : pointer to alloc routine
; return:
;  hl -> allocated space
	ld	iy, 0
	add	iy, sp
	ld	hl, (iy + 3)
	ld	iy, (iy + 6)
	push	hl
	jr	util_alloc_var

;-------------------------------------------------------------------------------
ti_AllocMatrix:
; allocates space for a matrix
; args:
;  sp + 3 : matrix rows
;  sp + 6 : matrix cols
;  sp + 9 : pointer to alloc routine
; return:
;  hl -> allocated space
	ld	iy, 0
	add	iy, sp
	ld	h, (iy + 3)
	ld	l, (iy + 6)
	ld	iy, (iy + 9)
	push	hl
	mlt	hl
util_alloc_var:
	call	ti.HLTimes9
	inc	hl
	inc	hl
	push	hl
	call	ti._indcall
	pop	de
	pop	de
	add	hl, de
	or	a, a
	sbc	hl, de
	ret	z
	ld	(hl), e
	inc	hl
	ld	(hl), d
	dec	hl
	ret

;-------------------------------------------------------------------------------
ti_CloseAll:
; closes all currently open file handles
; args:
;  n/a
; return:
;  n/a
	jp bos.fsd_CloseAll

;-------------------------------------------------------------------------------
ti_Resize:
; resizes an appvar variable
; args:
;  sp + 3 : new size
;  sp + 6 : slot index
; return:
;  hl = new size if no failure
	ld hl,6
	add hl,sp
	ld a,(hl)
	dec hl
	dec hl
	dec hl
	ld de,(hl)
	ld hl,file_descriptor_table
	call ti.AddHLAndA
	ld hl,(hl)
	push hl,de
	call bos.fsd_Resize
	pop bc,bc
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
	jr	z, util_is_in_ram
	xor	a, a
	ret
util_is_in_ram:
	ld hl,(hl)
	push hl
	call bos.fsd_InRam
	pop bc
	xor a,1
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
	db	$fe			; ld a,ti.AppVarObj -> cp a,$3e \ dec d
assert ti.AppVarObj = $15

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
	ld	(ti.OP1), a

	ld	hl, variable_offsets + (5 * 3) - 1
	ld	a, 5
.find_slot:
; slot open (in use): upper byte of offset == 0
; slot closed (free): upper byte of offset > slot
	cp	a, (hl)
	jr	c, .slot
	dec	hl
	dec	hl
	dec	hl
	dec	a
	jr	nz, .find_slot
	ret

.slot:
	ld (curr_slot),a
	push hl
	call bos._OP1ToAbsPath
	ld iy,3
	add iy,sp
	ld de,(iy+6)
	push de,hl
	call bos.fsd_Open
	pop bc,bc
	xor a,a
	add hl,de
	sbc hl,de
	pop de
	ret z
	ex hl,de
	ld (hl),0
	ld	a, (curr_slot)
	ld	c, a
	ld	b, 3
	mlt	bc
	ld	hl, file_descriptor_table - 3
	add	hl, bc
	ld	(hl), de
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
	jr	nz,ti_Read.return_zero
	ld	a,e
	or	a,a
	ld hl,(hl)
	push hl
	jr	z,.unarc
.arc:
	call bos.fsd_Archive
	pop bc
	ret
.unarc:
	call bos.fsd_UnArchive
	pop bc
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
	ld iy,0
	add iy,sp
	ld c,(iy+12)
	call util_is_slot_open
	jr nz,ti_Read.return_zero
	ld hl,(hl)
	push hl
	ld hl,(iy+9)
	push hl
	ld hl,(iy+6)
	push hl
	ld hl,(iy+3)
	push hl
	call bos.fsd_Write
	pop bc,bc,bc,bc
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
	ld iy,0
	add iy,sp
	ld c,(iy+12)
	call util_is_slot_open
	jr nz,.return_zero
	ld hl,(hl)
	push hl
	ld hl,(iy+9)
	push hl
	ld hl,(iy+6)
	push hl
	ld hl,(iy+3)
	push hl
	call bos.fsd_Read
	pop bc,bc,bc,bc
	ret
.return_zero:
	xor a,a
	sbc hl,hl
	ret

;-------------------------------------------------------------------------------
ti_GetC:
; gets a single byte character from a slot, advances the offset
; args:
;  sp + 3 : slot index
; return:
;  a = character read if success
	pop hl,bc
	push bc,hl
	call util_is_slot_open
	jr nz,ti_Read.return_zero
	ld hl,(hl)
	push hl
	ld hl,1
	push hl,hl
	dec hl
	add hl,sp
	push hl ; read the character into the stack in the same spot as the buffer
	call bos.fsd_Read
	pop hl,bc,bc,bc
	jr ti_PutC.common_return_int_l

;-------------------------------------------------------------------------------
ti_PutC:
; Performs an fputc on an AppVar
; args:
;  sp + 3 : Character to place
;  sp + 6 : Slot number
; return:
;  Character written if no failure
	pop	hl
	pop	de
	pop	bc
	push	bc
	push	de
	push	hl
	push de
	call	util_is_slot_open
	pop de
	jr	nz, ti_Seek.ret_neg_one
	ld bc,(hl)
	sbc hl,hl
	add hl,sp
	push hl
	ld (hl),e ; put the character to be written on the stack behind the file descriptor
	push bc
	ld de,1
	push de,de
	push hl
	call bos.fsd_Write
	pop bc,bc,bc,bc,hl
.common_return_int_l:
	ld h,1
	mlt hl
	ret

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
	jr	nz, .ret_neg_one
	ld hl,(hl)
	push hl
	ld hl, (iy + 6) ; origin location
	push hl
	ld hl, (iy + 3) ; origin position
	push hl
	call bos.fsd_Seek
	ld sp,iy
	ret
.ret_neg_one:
	scf
	sbc	hl, hl
	ret

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
	db	$fe			; ld a,ti.AppVarObj -> cp a,$3E \ dec d
assert ti.AppVarObj = $15

;-------------------------------------------------------------------------------
ti_Delete:
; deletes an appvar
; args:
;  sp + 3 : pointer to appvar name
; return:
;  hl = 0 if failure
	ld	a,ti.AppVarObj
.start:
	pop	de
	pop	hl
	push	hl
	push	de
	dec	hl
	push	af
	call	ti.Mov9ToOP1
	pop	af
	ld	(ti.OP1), a
	call bos._OP1ToAbsPath
	push hl
	call bos.fsd_IsOpen
	or a,a
	push hl
	call nz,bos.fsd_ForceClose
	pop hl
	call bos.fs_DeleteFile
	pop bc
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
	jr	nz, ti_Tell.ret_neg_one
	ld hl,(hl)
	push hl
	sbc hl,hl
	push hl,hl
	call bos.fsd_Seek
	pop bc,bc,bc
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
	jr	nz, .ret_neg_one
	ld hl,(hl)
	push hl
	call bos.fsd_Tell
	pop bc
	ret
.ret_neg_one:
	scf
	sbc	hl, hl
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
	jr	nz, ti_Tell.ret_neg_one
	ld hl,(hl)
	push hl
	call bos.fsd_GetSize
	pop bc
	ret

;-------------------------------------------------------------------------------
ti_Close:
; closes an open slot index
; args:
;  sp + 3 : slot index
; return:
;  n/a
	pop	de
	pop	bc
	push	bc
	push	de
	call	util_is_slot_open
	jq	nz, util_ret_null
	ld hl,(hl)
	push hl
	ld hl,variable_offsets-1
	add hl,bc
	ld	(hl), 255
	call bos.fsd_Close
	pop bc
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
	ld	a,$ff
	jr	ti_Detect.start_flag

;-------------------------------------------------------------------------------
ti_DetectVar:
; finds a variable that starts with some data
; args:
;  sp + 3 : address of pointer to being search
;  sp + 6 : pointer to null terminated string of data to search for
;  sp + 9 : type of variable to search for
; return:
;  hl -> name of variable
	ld	hl,9
	add	hl,sp
	ld	a,(hl)
;	jr	ti_Detect.start		; emulated by dummifying next instruction:
	db	$fe			; ld a,ti.AppVarObj -> cp a,$3E \ dec d
assert ti.AppVarObj = $15

;-------------------------------------------------------------------------------
ti_Detect:
; finds an appvar that starts with some data
;  sp + 3 : address of pointer to being search
;  sp + 6 : pointer to null terminated string of data to search for
; return:
;  hl -> name of variable
	ld	a,ti.AppVarObj
.start:
	ld	(.smc_type), a
	xor	a,a
.start_flag:
	ld	(.smc_flag), a
	push	ix
	ld	ix, 0
	add	ix, sp
	ld	hl, (ix + 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .detectall		; if null, then detect everything
	ld	hl, .fdetectall
	ld	(ix + 9), hl
.detectall:
	ld	hl, (ix + 6)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .fstart
	ld	hl, (hl)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .fdetect
.fstart:
	ld	hl, (ti.progPtr)
.fdetect:
	ld	de, (ti.pTemp)
	or	a, a
	sbc	hl, de
	jr	c, .finish
	jr	z, .finish
	add	hl, de
	jr	.fcontinue

.finish:
	xor	a, a
	sbc	hl, hl
	pop	ix
	ret

.fcontinue:
	push	hl
	ld	a, 0
.smc_flag := $-1
	or	a, a
	ld	a, (hl)
	jr	z, .fdetectnormal
	ld	de, (ix + 12)
	ld	(de), a
	jr	.fgoodtype
.fdetectnormal:
	cp	a, ti.AppVarObj
.smc_type := $-1
	jr	nz, .fskip
.fgoodtype:
	dec	hl
	dec	hl
	dec	hl
	ld	e, (hl)
	dec	hl
	ld	d, (hl)
	dec	hl
	ld	a, (hl)
	call	ti.SetDEUToA
	ex	de,hl
	cp	a, $d0
	jr	nc, .finram
	ld	de, 9
	add	hl, de			; skip archive vat stuff
	ld	e, (hl)
	add	hl, de
	inc	hl
.finram:
	inc	hl
	inc	hl			; hl -> data
	ld	bc, (ix + 9)
.fcmp:
	ld	a, (bc)
	or	a, a
	jr	z, .ffound
	cp	a, (hl)
	inc	bc
	inc	de
	inc	hl
	jr	z, .fcmp		; check the string in memory
.fskip:
	pop	hl
	call	.fbypassname
	jr	.fdetect

.ffound:
	pop	hl
	call	.fbypassname
	ex	de, hl
	ld	hl, (ix + 6)
	add	hl, de
	or	a, a
	sbc	hl, de
	jr	z, .isnull
	ld	(hl), de
.isnull:
	ld	hl, ti.OP6
	pop	ix
	ret

.fbypassname:				; bypass the name in the vat
	ld	de, ti.OP6
	ld	bc, -6
	add	hl, bc
	ld	b, (hl)
	dec	hl
.loop:
	ld	a, (hl)
	ld	(de), a
	dec	hl
	inc	de
	djnz	.loop
	xor	a, a
	ld	(de), a
	ret

.fdetectall:
	dl	0

;-------------------------------------------------------------------------------
ti_GetTokenString:
; return pointer to next token string
; args:
;  sp + 3 : slot index
; return:
;  hl -> os string to display
	ld	iy, 0
	add	iy, sp
	ld	a, 1
	ld	(.smc_length), a
	ld	hl, (iy + 3)
	ld	hl, (hl)
	push	hl
	ld	a, (hl)
	call	ti.Isa2ByteTok
	ex	de, hl
	jr	nz, .not2byte
	inc	de
	ld	hl, .smc_length
	inc	(hl)
.not2byte:
	inc	de
	ld	hl, (iy + 3)
	ld	(hl), de
	pop	hl
	push	iy
	ld	iy, ti.flags
	call	ti.Get_Tok_Strng
	pop	iy
	ld	hl, (iy + 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .skip
	ld	(hl), bc
.skip:
	ld	hl, (iy + 6)
	add	hl, bc
	or	a, a
	sbc	hl ,bc
	jr	z, .skipstore
	ld	(hl), 1
.smc_length := $-1
.skipstore:
	ld	hl, ti.OP3
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
	jr	nz, ti_GetVATPtr.ret_null
	ld hl,(hl)
	push hl
	call bos.fsd_GetDataPtr
	pop bc
	ret

;-------------------------------------------------------------------------------
ti_GetVATPtr:
; return a pointer to the vat location in the given variable
; args:
;  sp + 3 : slot index
; return:
;  hl -> vat location of variable
.ret_null:
	xor	a, a
	sbc	hl, hl
	ret

;-------------------------------------------------------------------------------
ti_GetName:
; gets the variable name of an open slot index
; args:
;  sp + 3 : name buffer
;  sp + 6 : slot index
; return:
;  n/a
	pop	hl
	pop	de
	pop	bc
	push	bc
	push	de
	push	hl
	xor	a, a
	ld	(de), a			; terminate the string
	ret

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
	ld	iy, ti.flags		; probably not needed
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
	ld	a, 3
	ret

;-------------------------------------------------------------------------------
ti_SetVar:
; sets an os variable structure value
; args:
;  sp + 3 : type of variable to set
;  sp + 6 : pointer to name of variable
;  sp + 9 : pointer to data to set
; return:
;  a = any error code, 0 if success

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
	scf
	sbc a,a
	ret

;-------------------------------------------------------------------------------
ti_RclVar:
; gets a pointer to a variable data structure
; args:
;  sp + 3 : pointer to variable name string
;  sp + 6 : pointer to data structure pointer
; return:
;  a = type of variable
	xor a,a
	ret

;-------------------------------------------------------------------------------
ti_ArchiveHasRoom:
; checks if there is room in the archive without triggering a garbage collect.
; args:
;  sp + 3 : number of bytes to store into the archive
; return:
;  true if there is room, false if not
	call ti.ArcChk
	pop	de
	pop	bc
	push	bc
	push	de
	or a,a
	sbc hl,bc
	sbc a,a
	inc a
	ret

;-------------------------------------------------------------------------------
ti_ArchiveHasRoomVar:
; checks if there is room in the archive without triggering a garbage collect.
; args:
;  sp + 3 : handle to variable
; return:
;  true if there is room, false if not
	pop	de
	pop	bc
	push	bc
	push	de
	call	util_is_slot_open
	jr	nz,.fail
	ld hl,(hl)
	push hl
	call bos.fsd_GetSize
	ex (sp),hl
	call ti.ArcChk
	pop bc
	or a,a
	sbc hl,bc
	ld	a,1
	ret	nc
.fail:
	xor	a,a
	ret

;-------------------------------------------------------------------------------
ti_SetGCBehavior:
;Set routines to run before and after a garbage collect would be triggered.
; args:
;   sp + 3 : pointer to routine to be run before. Set to 0 to use default handler.
;	sp + 6 : pointer to routine to be run after. Set to 0 to use default handler.
; return:
;   None
	ret
;-------------------------------------------------------------------------------
; internal library routines
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
util_set_var_str:
; in:
;  hl -> string
;  a = type
; out:
;  OP1 = variable combo
	ld	de, ti.OP1
	and	a, $3f
	ld	(de), a
	inc	de
	jp	ti.Mov8b

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
; in:
;  c = slot
; out:
;  a = 0
;  ubc = slot * 3
;  uhl = pointer to file descriptor
;  zf = open
;  (curr_slot) = slot
	ld	a, c
	cp	a, 6
	jr	nc, .not_open
	ld	(curr_slot), a
	ld	b, 3
	mlt	bc
	ld	hl, file_descriptor_table - 1
	add	hl, bc
	ld	a, b
	cp	a, (hl)
	dec hl
	dec hl
	ret
.not_open:
	xor	a, a
	inc	a
	ret

;-------------------------------------------------------------------------------
; Internal library data
;-------------------------------------------------------------------------------

	db	255			; handle edge case of 0 for slot
variable_offsets:
	dl	-1, -1, -1, -1, -1

file_descriptor_table:
	dl	0, 0, 0, 0, 0