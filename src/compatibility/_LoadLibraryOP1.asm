;@DOES locate and return a pointer to a library from a ".LLL" file in the "/lib/" directory
;@INPUT OP1 name of library
;@OUTPUT hl points to file length, de points to file data. Cf set if failed
_LoadLibraryOP1:
	ld hl,8+.dir_len+.ext_len
	push hl
	call sys_Malloc
	ex hl,de
	pop bc
	ret c
	push iy,de
	ld hl,.dir_name
	ld bc,.dir_len
	ldir
	ld hl,fsOP1+1
	xor a,a
	ld c,8
.copy_loop:
	cp a,(hl)
	jq z,.next
	ldi
	jp pe,.copy_loop
.next:
	ld hl,.ext_name
	ld bc,.ext_len
	ldir
	call fs_OpenFile
	pop bc,iy
	ret c
	ld bc,fsentry_filesector
	add hl,bc
	call _LoadDEInd_s
	push hl,de
	call fs_GetSectorAddress
	ex hl,de
	pop bc,hl
	ret
.dir_name:
	db "/lib/"
.dir_len:=$-.dir_name
.ext_name:
	db ".dll",0
.ext_len:=$-.ext_name
