
;@DOES Initialize a device given a path to it
;@INPUT void *sys_InitDevice(const char *name);
;@OUTPUT pointer to device file descriptor
;@OUTPUT hl=-1 and Cf set if failed
sys_InitDevice:
	pop bc,hl
	push hl,bc
	ld a,(hl)
	cp a,'/'
	push hl
	call nz,fs_AbsPath
	ex (sp),hl
	call fs_OpenFile
	pop bc
	jq c,.fail
	push hl
	ld bc,$C
	add hl,bc
	ld de,(hl)
	ex.s hl,de
	push hl
	call fs_GetSectorAddress
	pop bc
	ld a,(hl)
	cp a,$C9
	pop de
	jq c,.fail
	inc hl
	ld a,(hl)
	cp a,2
	jq nc,.fail
	push de
	inc hl
	ld a,(hl)
	cp a,$C3
	call z,.jumphl
	pop de
	jq c,.fail
	ex hl,de
	or a,a
	ret
.fail:
	scf
	sbc hl,hl
	ret
.jumphl:
	jp (hl)

