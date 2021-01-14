
;@DOES Get a pointer for raw access to a device given a file descriptor
;@INPUT void *sys_GetDeviceAddress(void *dest, void *src, size_t len, void *fd);
;@OUTPUT assume hl points to device address. Device return may vary. Some devices do not have a physical address.
;@OUTPUT hl = 0 and Cf set if failed
sys_GetDeviceAddress:
	call ti._frameset0
	ld hl,(ix+15)
	ld bc,$B
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
	pop de
	jq c,.fail
	inc hl
	ld a,(hl)
	cp a,2
	jq nc,.fail
	push de
	ld l,14 ; third jump in device jump table. (3*4 + 2) (files are always 512 byte aligned)
	ld a,(hl)
	cp a,$C3
	pop de
	jq nz,.fail
	ex hl,de
	jp (hl)
.fail:
	xor a,a
	sbc hl,hl
	scf
	ret

