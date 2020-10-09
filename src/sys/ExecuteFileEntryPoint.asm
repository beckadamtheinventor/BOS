
;@DOES execute a file from a given entry point
;@INPUT int sys_ExecuteFileEntryPoint(char *path, char *args);
;@OUTPUT -1 if file does not exist or is not a valid executable format
;@NOTE entry point is essentially "file.whatever:entrypoint/whatever"
sys_ExecuteFileEntryPoint:
	pop bc
	pop de
	pop hl
	push hl
	push de
	push bc
	push hl,de
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	ld a,':'
	cpir
	ld (hl),0
	inc hl
	ld (fsOP4),hl
	call sys_PushArgumentStack
	pop bc
	call fs_OpenFile
	pop bc
	ld bc,0
	push bc,hl
	call fs_GetClusterPtr
	pop de,bc
	ld a,(hl)
	cp a,$18
	jq z,.skip2
	cp a,$C3
	jq z,.skip4
.continue:
	push hl
	ld hl,(hl)
	db $01,"LIB" ;ld bc
	or a,a
	sbc hl,bc
	jq z,.open_lib
	pop hl
	scf
	sbc hl,hl
	ret
.skip4:
	inc hl
	inc hl
.skip2:
	inc hl
	inc hl
	jq .continue
.fail:
	pop ix
	scf
	sbc hl,hl
	ret
.open_lib:
	ex (sp),ix
	lea ix,ix+4
.entry_point_loop:
	ld hl,(ix)
	ld a,(hl)
	or a,a
	jr z,.fail
	ld bc,(fsOP4)
	push hl,bc
	call ti._strcmp
	pop bc,bc
	jr z,.found
	lea ix,ix+6
	jr .entry_point_loop
.found:
	ld de,(ix+3)
	pop ix
	call sys_GetArgumentStack ;only modifies hl
	push hl
	ex hl,de
	jq sys_ExecuteFile.run_hl

