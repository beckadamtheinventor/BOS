
;@DOES get absolute path representation of hl
;@INPUT char *fs_AbsPath(const char *path);
;@OUTPUT hl = absolute path. Will be equal to the input if it is already an absolute path
;@OUTPUT Cf set if failed
fs_AbsPath:
	ld hl,-12
	call ti._frameset
	ld hl,current_working_dir
	ld (ix-9),hl
	ld hl,(ix+6)
	ld (ix-12),hl
	ld a,(hl)
	cp a,'/'
	jq z,.dup_str ;just clone the string if it's already an absolute path
	ld hl,current_working_dir
	ld a,(hl)
	or a,a
	jq nz,.cwdnonzero
	ld (hl),'/'
	inc hl
	ld (hl),0
.cwdnonzero:
.entry:
	ld hl,(ix-12)
	push hl
	call ti._strlen
	pop bc
	ld (ix-3),hl
	push hl
	ld hl,(ix-9)
	push hl
	call ti._strlen
	pop bc,bc
	ld (ix-6),hl
	add hl,bc
	inc hl
	push hl
	call sys_Malloc
	jq c,.fail
	push hl
	ex hl,de
	ld hl,(ix-9)
	ld bc,(ix-6)
	ldir
	ld hl,(ix-12)
	ld bc,(ix-3)
	ldir
	xor a,a
	ld (de),a
	pop hl
	db $01 ;ld bc,...
.fail:
	scf
	sbc hl,hl
.return:
	ld sp,ix
	pop ix
	ret
.dup_str: ;clone the string if it's already an absolute path
	push hl
	call ti._strlen
	inc hl
	push hl
	call sys_Malloc
	ex hl,de
	pop bc,hl
	jq c,.fail
	push de
	ldir
	pop hl
	jq .return
