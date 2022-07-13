;@DOES Clean up the filesystem, resetting freed areas.
;@INPUT None
;@OUTPUT None
;@DESTROYS All
fs_GarbageCollect:
	ld hl,-18
	call ti._frameset
	ld hl,str_GarbageCollecting
	call gui_DrawConsoleWindow
	ld hl,fs_cluster_map + (65536/fs_sector_size * 2)
	; ld bc,fs_cluster_map.len - 65536/fs_sector_size
	ld (ix-3),hl
	ld (ix-9),hl
	; add hl,bc
	; ld (ix-12),hl

	ld hl,(ti.mpLcdUpbase)
	ld (ix-18),hl
	ld bc,$D52C00
	or a,a
	sbc hl,bc
	jq z,.no_buffer_swap
	add hl,bc
	ld de,$D52C00
	ld bc,ti.lcdWidth*ti.lcdHeight
	push de
	ldir
	pop de
	ld (ti.mpLcdUpbase),de
.no_buffer_swap:
	call sys_FlashUnlock
	xor a,a
	ld (curcol),a
	inc a
	ld (currow),a
	ld hl,.str_cleaning_up
	call gui_PrintString
; clean up freed sectors
; cluster map pointer decrements within each 64k sector
	ld bc,$050000
	ld (ix-6),bc
.cleanup_freed_loop_outer:
	ld hl,.str_cleaning_up_len*8
	ld (lcd_x),hl
	ld a,(ix-4)
	call gfx_PrintHexA
	ld hl,.str_trailing_zeroes
	call gfx_PrintString
	ld iy,$D50000
	ld bc,65536/fs_sector_size
.cleanup_freed_loop:
	ld a,c
	or a,b
	jr z,.done_checking_64k_sector
	dec bc
	ld hl,(ix-3) ; current cluster map byte
	dec hl
	ld a,(hl)
	ld (ix-3),hl
	or a,a
	jr z,.cleanup_freed_loop
	inc a
	jr z,.cleanup_freed_loop
; mark the sector for copying
.copy_sector:
	push bc
	ld h,b
	ld l,c
	ld c,fs_sector_size_bits
	call ti._sshl
	ld b,h
	ld c,l
	ld (iy),bc
	lea iy,iy+2
	ld hl,(ix-6)
	ld h,b
	ld l,c
	ld de,$D40000
	ld d,b
	ld e,c
	ld bc,fs_sector_size
	ldir
	pop bc
	jr .cleanup_freed_loop
.done_checking_64k_sector:
	ld a,iyh
	or a,a
	jr nz,.erase_and_writeback_sector
	ld a,iyl
	or a,a
	jr z,.cleanup_next
.erase_and_writeback_sector:
	ld a,(ix-4)
	push iy
	call sys_EraseFlashSector
	pop iy
.rewrite_loop:
	ld a,iyh
	or a,a
	jr nz,.writeback_sector
	ld a,iyl
	or a,a
	jr z,.cleanup_next
.writeback_sector:
	ld hl,$D40000
	lea iy,iy-2
	ld l,(iy)
	ld h,(iy+1)
	ld de,(ix-6)
	ld d,h
	ld e,l
	push iy
	ld bc,fs_sector_size
	call sys_WriteFlash ; write back the sector
	pop iy
	jr .rewrite_loop
.cleanup_next:
	ld bc,65536/fs_sector_size * 2
	ld hl,(ix-3)
	add hl,bc
	ld (ix-3),hl
	ld a,(ix-4)
	inc a
	ld (ix-4),a
	cp a,$3B
	jq nz,.cleanup_freed_loop_outer
	call sys_FlashLock

;TODO: move files around to free up space
; .shuffle_files:
	; ld hl,(ix-9)
	; ld bc,(ix-12)
; .find_free_space_loop:
	; or a,a
	; sbc hl,bc
	; jq nc,.done_shuffling
	; adc hl,bc
	; ld a,(hl)
	; cp a,$FE
	; jq z,.find_free_space_loop
	; ld (ix-15),hl
	; inc hl

;; found a free cluster
	; ex hl,de
	; ld hl,(ix-12)
	; or a,a
	; sbc hl,de
	; push hl
	; pop bc
	; ex hl,de
	; ld a,$FE ;search for in-use cluster following free clusters
	; cpir
	; jp po,.done_shuffling
	; ld (ix-18),hl
	
	
	; jq .shuffle_files
; .done_shuffling:

	ld bc,$D52C00
	or a,a
	sbc hl,bc
	jq z,.no_restore_vram
	add hl,bc
	ld de,$D40000
	ld bc,ti.lcdWidth*ti.lcdHeight
	push de
	ldir
	pop de
	ld (ti.mpLcdUpbase),de
.no_restore_vram:
	ld sp,ix
	pop ix
	ret

.str_trailing_zeroes:
	db "0000",0
.str_cleaning_up:
	db "Cleaning up address: $"
.str_cleaning_up_len:=$-.str_cleaning_up
	db 0
