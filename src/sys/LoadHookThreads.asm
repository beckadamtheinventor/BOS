
;@DOES run threads given a pointer to a file path structure
;@INPUT void sys_LoadHookThreads(void *ptr, size_t len);
;@NOTE data structure: type byte, entry length byte, offset of data in file (2 bytes), stack size byte, file name (null-terminated), end of entry
sys_LoadHookThreads:
	pop de,bc,hl
	push hl,bc,de
.entryhlbc:
	push ix,bc
	ld ix,0
.load_hooks_loop:
	ld a,(hl)
	inc hl
	or a,a
	jr z,.skip_hook
	inc hl
	mlt de
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld a,(hl)
	ld ixl,a
	inc hl
	push de,hl
	call fs_GetFilePtr
	jr c,.dont_load_file
	ld a,b
	or a,c
	jr z,.dont_load_file
	pop af,de
	push af
	push hl
	ex hl,de
	or a,a
	sbc hl,bc
	add hl,bc
	pop de
	jr nc,.dont_load_file
	add hl,de
	push hl
	lea hl,ix
	ld a,l
	dec hl
	or a,a
	jr z,.dont_malloc
	inc hl
	call sys_Malloc.entryhl
.dont_malloc:
	pop bc
	jr c,.dont_load_file
	ld de,$FF0000
	push de
	mlt de
	push de
	push hl,bc
	call th_CreateThread
	pop bc,bc,bc,bc
.dont_load_file:
	pop hl
	dec hl
.skip_hook:
	ld b,0
	ld c,(hl)
	add hl,bc
	inc hl
	ex (sp),hl
	dec hl
	or a,a
	sbc hl,bc
	ex (sp),hl
	jr z,.done_loading_hooks
	jr nc,.load_hooks_loop
.done_loading_hooks:
	pop bc,ix
	ret
