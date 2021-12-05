;@DOES Clean up the filesystem, resetting freed areas.
;@INPUT None
;@OUTPUT None
;@DESTROYS All
fs_GarbageCollect:
	ld hl,-18
	call ti._frameset
	ld hl,str_GarbageCollecting
	call gui_DrawConsoleWindow
	ld hl,fs_cluster_map + 65536/512
	; ld bc,fs_cluster_map.len - 65536/512
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
	ld bc,$050000
	ld (ix-6),bc
.cleanup_freed_loop_outer:
	ld hl,.str_cleaning_up_len*8
	ld (lcd_x),hl
	ld a,(ix-4)
	call gfx_PrintHexA
	ld iy,$D50000
	ld b,65536/512
.cleanup_freed_loop:
	ld hl,(ix-3)
	ld a,(hl)
	inc hl
	ld (ix-3),hl
	push bc
	or a,a
	jq z,.next_512
	inc a
	jq z,.next_512
.copy_512:
	ld hl,(ix-6)
	ld a,128
	sub a,b
	add a,a
	inc iy
	ld (iy),a
	ld h,a
	ld de,$D40000
	ld d,a
	ld bc,512
	ldir
.next_512:
	pop bc
	djnz .cleanup_freed_loop
	ld a,(ix-4)
	call sys_EraseFlashSector
.rewrite_loop:
	ld a,iyl
	or a,a
	jq z,.cleanup_next
	ld hl,$D40000
	ld h,(iy)
	ld de,(ix-6)
	ld d,h
	ld bc,512
	call sys_WriteFlash ; write back 512 bytes
	dec iy
	jq .rewrite_loop
.cleanup_next:
	call sys_FlashLock
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

.str_cleaning_up:
	db "Cleaning up sector: $"
.str_cleaning_up_len:=$-.str_cleaning_up
	db 0
