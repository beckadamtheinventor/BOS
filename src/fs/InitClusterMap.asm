;@DOES initialize cluster map given data within the file system.
;@INPUT void fs_InitClusterMap(void);
;@NOTE uses the first half of vRam as scrap.
fs_InitClusterMap:
	ld a,(fs_cluster_map)
	inc a
	inc a
	ret z ; dont build the cluster map if its already been built
.reinit:
	ld hl,-4
	call ti._frameset

	ld hl,(ti.mpLcdUpbase)
	push hl
	ld de,ti.vRam
	or a,a
	sbc hl,de
	jq nz,.no_needed_blit
	add hl,de
; blit lcd to buffer
	ld bc,ti.lcdWidth*ti.lcdHeight
	add hl,bc
	ex hl,de
	push de
	ldir
	pop de
; render from buffer
	ld (ti.mpLcdUpbase),de

.no_needed_blit:
	ld hl,fs_cluster_map
	ld de,ti.vRam+$10000
	ld bc,fs_cluster_map.len
	push de,bc
	ldir
	pop bc
	xor a,a
	cpdr ; find the last freed sector that hasn't been cleaned up yet
	inc bc
	pop de
	jp po,.dont_clean_up ; don't try to clean up if there's nothing to clean up

; hl = cluster map stored in ti.vRam+$10000
; de = current flash sector
; (ix-4) = cluster map sector counter (128 per physical 64k sector)
; bc = remaining cluster map sectors to be processed
	ld de,start_of_user_archive
	ld a,65536/512
	ld (ix-4),a
	jq .copy_next_sector
.writeback_sector: ; write the sector back from vRam into flash
	call sys_FlashUnlock
	push hl,bc
	ld (ix-3),de ; save pointer to flash
	ld a,(ix-1)
	call sys_EraseFlashSector
	ld de,(ix-3)
	ld e,d
	ld bc,$010000
	call sys_WriteFlash
	ld de,(ix-3)
	pop bc,hl
.copy_next_sector: ; copy sector into vRam
	push hl,de,bc
	ex hl,de
	ld de,ti.vRam
	ld bc,$010000
	ldir
	pop bc,de,hl
	ld a,65536/512
	ld (ix-4),a
.cleanup_loop: ; check cluster map sectors and reset them in vRam
	ld a,(hl)
	or a,a
	jq nz,.dont_clear
	push bc,hl
	dec a
	ld (hl),a
assert ~ti.vRam and $FFFF
	ld hl,ti.vRam
	ld h,d
	ld l,e
	ld (hl),a
	push hl
	pop de
	inc de
	ldir
	ld d,h
	ld e,l
	pop hl,bc
.dont_clear:
	inc hl ; check next cluster map sector
	dec bc
	ld a,b
	or a,c
	jq z,.done_cleaning_up
	dec (ix-4)
	jq nz,.writeback_sector

.done_cleaning_up:
.dont_clean_up:
	ld a,$FE
	ld (ti.vRam+$10000),a
	ld iy,$040000
	call .traverse

	ld hl,fs_cluster_map and $FF0000
	ld de,ti.vRam
	ld bc,$010000
	ldir
	ex hl,de
	ld de,ti.vRam+$E000
	ld bc,fs_cluster_map.len
	ldir

	call sys_FlashUnlock
	ld a,fs_cluster_map shr 16
	call sys_EraseFlashSector

	ld hl,ti.vRam
	ld de,fs_cluster_map and $FF0000
	ld bc,$E000+fs_cluster_map.len
	call sys_WriteFlash

	call sys_FlashLock

	pop hl
	ld de,ti.vRam
	or a,a
	sbc hl,de
	jq nz,.dont_restore_vram ; if we weren't drawing from vRam originally, there's no need to blit again
	add hl,de
	ld bc,ti.lcdWidth*ti.lcdHeight
	add hl,bc
	push de
	ldir
	pop de
	ld (ti.mpLcdUpbase),de

.dont_restore_vram:
	ld sp,ix
	pop ix
	ret
.traverse:
	ld a,(iy)
	or a,a
	jq z,.traverse_next
	inc a
	ret z
	inc a
	jq z,.traverse_into_jump
	cp a,'.'+2
	jq z,.traverse_next
	bit fd_subfile, (iy+fsentry_fileattr)
	jq z,.regular_file
	ld hl,(iy+fsentry_filesector)
	ex.s hl,de
	lea hl,iy
	ld l,0
	res 0,h
	add hl,de
	ld de,-$040000
	add hl,de
	call fs_CeilDivBySector
	ld de,fs_cluster_map
	add hl,de
	push hl
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	call fs_CeilDivBySector
	pop de
	ld b,l
	jq .mark_file_entry
.regular_file:
	ld de,(iy+fsentry_filelen)
	ex.s hl,de
	call fs_CeilDivBySector
	ld b,l
	ld de,(iy+fsentry_filesector)
	ex.s hl,de
	ld de,ti.vRam+$10000
	add hl,de
	ex hl,de
.mark_file_entry:
	push iy
	ld a,$FE
.mark_file_loop:
	ld (de),a
	inc de
	djnz .mark_file_loop
	pop iy
	bit fd_subdir, (iy+fsentry_fileattr)
	call nz,.traverse_into
.traverse_next:
	lea iy,iy+16
	jq .traverse
.traverse_into:
	push iy
	call .traverse_into_jump
	pop iy
	ret
.traverse_into_jump:
	ld hl,(iy+fsentry_filesector)
	push hl
	call fs_GetSectorAddress
	ex (sp),hl
	pop iy
	jq .traverse

