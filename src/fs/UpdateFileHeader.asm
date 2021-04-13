
;@DOES update a file's header given a file descriptor
;@INPUT bool fs_UpdateFileHeader(void *fd, void *new_header);
;@OUTPUT true if success, otherwise fail
fs_UpdateFileHeader:
	call ti._frameset0
	push iy
	ld iy,(ix+6)
	bit fsbit_readonly,(iy+fsentry_fileattr)
	pop iy
	jq c,.fail
	ld de,(ix+6)
	ld hl,(ix+9)
	ld bc,16 ;update full header
	push bc,hl,de
	call sys_WriteFlashFullRam
	pop bc,bc,bc
	db $3E ;ld a,...
.fail:
	xor a,a
	pop ix
	or a,a
	ret

