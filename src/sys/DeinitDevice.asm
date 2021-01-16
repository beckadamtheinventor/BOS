
;@DOES Deinitialize a device given a pointer to its file descriptor
;@INPUT int sys_DeinitDevice(void *fd);
;@OUTPUT hl = -1 and Cf set if failed. Otherwise assume 0.
sys_DeinitDevice:
	pop bc,hl
	push hl,bc
	ld bc,$B
	add hl,bc
	bit fd_device,(hl)
	jq z,.fail
	inc hl
	add hl,bc
	ld de,(hl)
	ex.s hl,de
	push hl
	call fs_GetSectorAddress
	pop bc
	ld a,(hl)
	cp a,$C9
	jq c,.fail
	inc hl
	ld a,(hl)
	cp a,2
	jq nc,.fail
	ld l,10 ; second jump in device jump table. (2*4 + 2) (files are always 512 byte aligned)
	ld a,(hl)
	cp a,$C3
	jq nz,.fail
	jp (hl)
.fail:
	xor a,a
	sbc hl,hl
	scf
	ret

