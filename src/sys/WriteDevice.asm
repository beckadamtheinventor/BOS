
;@DOES Write to a device given a file descriptor
;@INPUT int sys_WriteDevice(void *dest, void *src, size_t len, void *fd);
;@OUTPUT assume hl = number of bytes written. Device return may vary.
;@OUTPUT hl = 0 and Cf set if failed
sys_WriteDevice:
	call ti._frameset0
	ld hl,(ix+15)
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
	ld l,22 ; fifth jump in device jump table. (5*4 + 2) (files are always 512 byte aligned)
	ld a,(hl)
	cp a,$C3
	jq nz,.fail
	inc hl
	ld hl,(hl)
	jp (hl)
.fail:
	or a,a
	sbc hl,hl
	scf
	ret

