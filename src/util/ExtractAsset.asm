;@DOES Extract an asset to asset memory and return an asset handle
;@INPUT int util_ExtractAsset(const void *fd, const char *name);
;@OUTPUT asset handle. Returns -1 if asset not found, 0 if invalid asset
util_ExtractAsset:
	ld hl,-3
	call ti._frameset
	ld hl,(ix+6)
	ld de,(ix+9)
	push de,hl
	call fs_OpenFileInDir
	pop bc,bc
	jq c,.fail_hl
	push hl
	call fs_GetFDPtr
	pop bc
	ld de,(hl)
	inc hl
	inc hl
	push hl
	ex.s hl,de
	ld b,8
.mult_loop:
	add hl,hl
	djnz .mult_loop
	push hl
	call util_AllocAssetLoc
	ld (ix-3),hl
	pop bc,hl
	ld bc,(hl)
	ex hl,de
	db $21,"zx7"
	or a,a
	sbc hl,bc
	jq z,.extract_zx7
.success:
	ld hl,(ix-3)
	db $01 ;ld bc,...
.fail_0:
	xor a,a
	sbc hl,hl
.fail_hl:
	ld sp,ix
	pop ix
	ret

.extract_zx7:
	ld hl,(ix-3)
	push de,hl
	call util_GetAssetLocPtr
	ex (sp),hl
	call util_Zx7DecompressToFlash
	pop bc,bc
	jq .success
