;@DOES Search for a '.v21' file (raw appvar) in both A and C drive's root directories
;@INPUT OP1+1 8 byte file name
;@OUTPUT HL = pointer to file length
;@OUTPUT DE = pointer to file data
;@OUTPUT Cf set if file not found or otherwise cannot be opened.
;@DESTROYS OP1 and OP2
_ChkFindSym:
	xor a,a
	ld hl,fsOP1+9
	ld (hl),a
	dec hl
	ld de,fsOP1+10  ;copy fsOP1+1 to fsOP1+3
	ld bc,8
	lddr
	ld hl,fsOP1
	db $11,"A:/" ;ld de,...
	ld (hl),de
	push hl
	ld c,12 ;bc is already zero
	cpir
	dec hl
	ex hl,de
	ld hl,.str_v21
	ld bc,.str_v21.len
	ldir
	pop hl
	push hl
	call fs_OpenFile
	pop bc
	jr nc,.get_cluster
.try_c_drive:
	ld hl,fsOP1
	db $11,"C:/" ;ld de,...
	ld (hl),de
	push hl
	call fs_OpenFile
	pop bc
	ret c
.get_cluster:
	ld bc,0
	push bc,hl
	call fs_GetClusterPtr
	pop de,bc
	ret c
	ex hl,de
	ld bc,$1C ;get pointer to file length
	add hl,bc
	ret
.str_v21:
	db ".v21",0
.str_v21.len:=$-.str_v21
