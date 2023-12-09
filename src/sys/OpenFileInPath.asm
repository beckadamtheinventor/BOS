
;@DOES open a file, looking in directories from $PATH variable if file not found
;@INPUT void *sys_OpenFileInPath(const char *path);
;@OUTPUT pointer to file descriptor
sys_OpenFileInPath:
	ld hl,-12
	call ti._frameset
	ld hl,string_path_variable
.entryhl:
	push hl
	call fs_GetFilePtr
	pop de
	jr nc,.entry_hlbc
; use default if /var/PATH not found
	ld hl,str_DefaultPathVarData
	ld bc,str_DefaultPathVarData.len
.entry_hlbc:
	ld (ix-6),hl
	ld (ix-9),bc
	ld hl,(ix+6)
	ld a,(hl)
	or a,a
	jr z,.fail ;fail if null path
	xor a,a
	ld (ix-10),a
	push hl
	call fs_OpenFile
	pop bc
	jr nc,.success ;succeed if file found
.loop:
	ld bc,(ix+6) ; argument
	ld de,(ix-6) ; current search directory
	push bc,de
	call fs_JoinPath
	pop bc,bc
	push hl
	call fs_OpenFile
	ex (sp),hl
	push af
	call sys_Free.entryhl
	pop af,hl
	jr nc,.success
	ld de,(ix-6) ; current search directory
	call fs_PathLen.entryde
	inc hl
	inc de
	ld (ix-6),de
	ex hl,de
	ld hl,(ix-9)
	or a,a
	sbc hl,de
	jr c,.fail ; fail if no more directories to search in
	ld (ix-9),hl
	jr .loop
.success:
	db $01
.fail:
	scf
	sbc hl,hl
	ld sp,ix
	pop ix
	ret
