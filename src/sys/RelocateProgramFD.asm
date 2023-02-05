
;@DOES Relocate an RFX format executable into flash
;@INPUT void *sys_RelocateProgram(void *fd);
;@OUTPUT file descriptor of relocated program, -1 and Cf set if failed.
sys_RelocateProgramFD:
	pop bc,hl
	push hl,bc
.entryhl:
	call fs_GetFilePtr.entryfd
	bit fd_subdir,a
	jr nz,.fail ; a directory is not a program
	call sys_GetExecType.entryhlbc
	jr c,.fail
	push de
	ld de,(hl)
	db $21, 'RFX' ; ld hl
	or a,a
	sbc hl,de
	pop de
	jr z,.relocate
.fail:
	scf
	sbc hl,hl
	ret

.relocate:
	ex hl,de
	ld bc,(hl)
	push hl,bc
	call fs_Alloc
	pop bc
	ex (sp),hl
	pop iy
	
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	
	
	
	ret

