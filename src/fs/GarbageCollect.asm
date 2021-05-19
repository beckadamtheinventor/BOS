;@DOES Clean up and optimize the filesystem, and reset freed areas.
;@INPUT None
;@OUTPUT None
;@DESTROYS All
;@NOTE will sanity-check the filesystem if the cluster map is not found.
fs_GarbageCollect:
	ld hl,-18
	call ti._frameset
	ld bc,fs_cluster_map_file
	push bc
	call fs_GetFilePtr
	pop bc
	jq c,fs_SanityCheck
	ld (ix-3),hl
	ld (ix-9),hl
	ld bc,8192
	add hl,bc
	ld (ix-12),hl

	call sys_FlashUnlock

	ld hl,(ti.mpLcdUpbase)
	push hl
	ld bc,$D40000
	or a,a
	sbc hl,bc
	jq nz,.no_buffer_swap
	ld de,$D52C00
	ld hl,$D40000
	ld bc,$010000
	ld (ti.mpLcdUpbase),de
	ldir
.no_buffer_swap:
	ld a,1
	call gfx_SetDraw
	ld hl,$D50000 ;set to 0xff to be used later
	push hl
	pop de
	inc de
	ld (hl),$FF
	ld bc,512
	ldir
; clean up freed sectors
	ld bc,$040000
	ld (ix-6),bc
.cleanup_freed_loop_outer:
	xor a,a
	ld (curcol),a
	ld (currow),a
	ld hl,.str_cleaning_up
	call gui_PrintString
	ld a,(ix-4)
	call gfx_PrintHexA
	ld hl,(ix-6)
	call .check_sector
	cp a,$FF
	jq z,.cleanup_next
	ld b,65536/512
.cleanup_freed_loop:
	ld hl,(ix-3)
	ld a,(hl)
	inc hl
	ld (ix-3),hl
	push bc
	or a,a
	jq z,.copy_ff
	inc a
	jq nz,.copy_sector
.copy_ff:
	ld hl,$D50000
	ld a,128
	sub a,b
	add a,a
	jq .copy_512_to_vram
.copy_sector:
	ld hl,(ix-6)
	ld a,128
	sub a,b
	add a,a
	ld h,a
.copy_512_to_vram:
	ld de,$D40000
	ld d,a
	ld bc,512
	ldir
	pop bc
	djnz .cleanup_freed_loop
	ld a,(ix-4)
	call sys_EraseFlashSector
	ld hl,$D40000
	ld de,(ix-6)
	ld bc,$010000
	call sys_WriteFlash
.cleanup_next:
	ld a,(ix-4)
	inc a
	ld (ix-4),a
	cp a,$3B
	jq nz,.cleanup_freed_loop_outer

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
	call sys_FlashLock
	call fs_InitClusterMap

	pop hl
	ld bc,$D40000
	or a,a
	sbc hl,bc
	jq z,.no_restore_vram
	ld hl,$D52C00
	ld de,$D40000
	ld bc,$010000
	ld (ti.mpLcdUpbase),hl
	ldir
.no_restore_vram:
	ld sp,ix
	pop ix
	ret

.check_sector:
	ld a,$FF
	ld bc,0
.check_sector_loop:
	and a,(hl)
	cp a,$FF
	ret nz
	inc hl
	djnz .check_sector_loop
	dec c
	jq nz,.check_sector_loop
	ret
.str_cleaning_up:
	db "Cleaning up sector: $",0
