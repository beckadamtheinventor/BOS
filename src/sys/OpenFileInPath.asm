
;@DOES open a file, looking in directories from $PATH variable if file not found
;@INPUT void *sys_OpenFileInPath(const char *path);
;@OUTPUT pointer to file descriptor
sys_OpenFileInPath:
	ld hl,-15
	call ti._frameset
	ld hl,string_path_variable
.entryhl:
	push hl
	call fs_GetFilePtr
	jq c,.fail ;fail if /var/PATH not found
	pop de
.entry_hlbc:
	ld (ix-6),hl
	ld (ix-9),bc
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jq z,.fail ;fail if null path
	push hl
	call fs_OpenFile
	pop bc
	jq nc,.success ;succeed if file found
	ld a,(bc)
	cp a,'/'
	jq z,.fail ;fail if absolute path not found
	push bc
	call ti._strlen
	ld (ix-3),hl
	pop bc
.loop:
	ld hl,(ix-6)
	ld bc,(ix-9)
	ld a,c
	or a,b
	jq z,.fail
	ld (ix-12),hl
	call .pathentrylen
	ld (ix-6),hl
	ld (ix-9),bc
	ld (ix-15),de
	ld hl,(ix-3)
	add hl,de
	inc hl
	inc hl
	push hl
	call sys_Malloc
	jq c,.fail
	pop bc
	ex hl,de
	push de
	ld hl,(ix-12)
	ld bc,(ix-15)
	ldir
	dec de
	ld a,(de)
	inc de
	cp a,'/'
	jq z,.dontputslash
	ld a,'/'
	ld (de),a
	inc de
.dontputslash:
	ld hl,(ix+6)
	ld bc,(ix-3)
	ldir
	xor a,a
	ld (de),a
	call fs_OpenFile
	pop bc
	push af,hl,bc
	call sys_Free
	pop bc,hl,af
	jq c,.loop
.success:
	db $01
.fail:
	scf
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
.pathentrylen:
	ld de,0
.pathentrylenloop:
	ld a,b
	or a,c
	ret z
	ld a,(hl)
	inc hl
	dec bc
	cp a,':'
	ret z
	inc de
	jq .pathentrylenloop
