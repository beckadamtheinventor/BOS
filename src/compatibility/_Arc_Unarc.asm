
_Arc_Unarc.unarchive:
	xor a,a
	inc a
	db $06 ; ld b,...
_Arc_Unarc.archive:
	xor a,a
	inc a
	db $06 ; ld b,...
_Arc_Unarc:
	xor a,a
	ld (ScrapMem),a
	ld hl,-8
	call ti._frameset
	ld hl,fsOP1+1
	push hl
	xor a,a
	ld bc,8
	cpir
	pop de
	sbc hl,de
	ld (ix-5),l ; save file name length
	call _OP1ToAbsPath
	ld (ix-3),hl
	call fs_GetFilePtr.entryname
	ld (ix-8),hl
	call _ChkInRam
	push af
	ld a,(ScrapMem)
	jr nz,.inarc
	dec a
.inarc:
	dec a
	jr z,.done ; dont move the file if we're trying to move it to X but it's already in X
.toram:
	pop af
	jr z,.toarchive ; move into arc if in ram and vice versa
	inc hl
	dec bc
	push hl,bc,bc
	pop hl
	ld de,(top_of_UserMem)
	push de
	call _InsertMem
	pop hl,bc,de
	sbc a,a
	jq c,.done
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	push bc,hl
	ex hl,de
	ld a,c
	or a,b
	jr z,.dont_copy
	ldir
.dont_copy:
	ld hl,(ix-3)
	ld c,0
	push bc,hl
	call fs_CreateRamFile
	pop bc
	sbc a,a
	ld (ix-4),a
	call sys_Free
	pop bc,bc,bc
	ld a,(ix-4)
.done: ; Return if A=0, Memory error otherwise
	ld sp,ix
	pop ix
	or a,a
	ret z
	jq _ErrMemory

.toarchive:
	push bc,bc
	pop hl
 ; 3 bytes unused + var type byte + 6 bytes unused + name length byte + name + data length + file data
	ld bc,10
	add hl,bc
	ld c,(ix-5)
	add hl,bc ; 10 bytes header + file name bytes + file data bytes (including file length)
	push hl
	ld c,b
	ld hl,(ix-3)
	push bc,hl
	call fs_CreateFile
	pop bc,bc

	ld bc,3
	push bc,hl
	ld a,(fsOP1)
	ld c,a
	push bc
	call fs_WriteByte ; write var type byte
	pop bc,hl,bc

	ld c,9
	push bc,hl
	ld c,(ix-5)
	push bc
	call fs_WriteByte ; write file name length
	pop bc,hl,bc
	
	ld c,10
	push bc,hl
	ld c,1
	push bc
	ld a,(ix-5)
	add a,11
	push bc
	ld hl,fsOP1
	push hl
	call fs_WriteRaw ; write file name
	pop bc,bc,bc,hl,bc

	ld a,(ix-5) ; file name length + 10
	add a,10
	ld c,a
	push bc,hl
	ld c,1
	push bc
	ld hl,(ix-8)
	ld c,(hl)
	inc hl
	ld b,(hl)
	dec hl
	inc bc
	inc bc
	push bc,hl
	call fs_WriteRaw ; write length prefixed file data
	sbc a,a
	jq .done
