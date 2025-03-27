;@DOES Clean up the filesystem, resetting freed areas.
;@INPUT None
;@OUTPUT None
;@DESTROYS All
fs_GarbageCollect:
	ld hl,-18
	call ti._frameset
	ld hl,str_GarbageCollecting
	call gui_DrawConsoleWindow
	ld hl,fs_cluster_map + 65536/fs_sector_size
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

; clean root directory
    ld hl,.str_cleaning_dirs
    call .print_cleaning_str

    ld hl,fs_root_dir_address
    call .cleanup_dirs

	ld hl,.str_cleaning_up_step_1
    call .print_cleaning_str
; clean up freed sectors
; cluster map pointer decrements within each 64k sector
	ld bc,start_of_user_archive
	ld (ix-6),bc
.cleanup_freed_loop_outer:
	ld hl,(lcd_x)
	push hl
	ld a,(ix-4)
	sub a,3
	ld l,a
	ld a, 2
	call gfx_PrintUInt
	pop hl
	ld (lcd_x),hl
	; ld hl,.str_trailing_zeroes
	; call gfx_PrintString
	ld iy,$D50000
	ld bc,65536/fs_sector_size
.cleanup_freed_loop:
	ld hl,(ix-3) ; current cluster map byte
	dec hl
	dec bc
	ld a,(hl)
	ld (ix-3),hl
	inc a
	jr z,.next_cleanup_freed_loop
	dec a
	jr z,.next_cleanup_freed_loop
; mark the sector for copying
.copy_sector:
	push bc
	ld a,b
	ld b,fs_sector_size_bits
.sshl_loop:
	or a,a
	rl c
	rla
	djnz .sshl_loop
	ld b,a
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
.next_cleanup_freed_loop:
	ld a,c
	or a,b
	jr nz,.cleanup_freed_loop
.done_checking_64k_sector:
	ld a,iyh
	cp a,512/fs_sector_size
	jr z,.cleanup_next ; don't erase and copy back the sector if it's fully written
	or a,iyl
	jr z,.cleanup_next ; don't erase and copy back the sector if none of the fs sectors require cleaning
.erase_and_writeback_sector:
	ld a,(ix-4)
	push iy
	call sys_EraseFlashSector
	pop iy
.rewrite_loop:
	ld a,iyh
	or a,iyl
	jr z,.cleanup_next
.writeback_sector:
	lea iy,iy-2
	ld hl,$D40000
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

	; xor a,a
	; ld (curcol),a
	; inc a
	; ld (currow),a
	; ld hl,.str_cleaning_dirs
	; call gui_PrintString
	; ld iy,start_of_user_archive
	; call .cleanup_dirs_traverse

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
	; ld hl,(ti.mpLcdUpbase)
	; ld bc,$D52C00
	; or a,a
	; sbc hl,bc
	; jr z,.no_restore_vram
	; add hl,bc
	; ld de,$D40000
	; ld bc,ti.lcdWidth*ti.lcdHeight
	; push de
	; ldir
	; pop de
	; ld (ti.mpLcdUpbase),de
; .no_restore_vram:
	call fs_InitClusterMap.reinit
	pop hl
	ld bc,$D52C00
	or a,a
	sbc hl,bc
	jr z,.no_restore_vram
	add hl,bc
	ex hl,de
	ld bc,ti.lcdWidth * ti.lcdHeight
	ld hl,ti.vRam
	ldir
.no_restore_vram:
	ld sp,ix
	pop ix
	ret

; .cleanup_dirs_traverse:
	; ret

; .str_trailing_zeroes:
	; db "0000",0

.cleanup_directory:
    ld a,(hl) ; ensure we're pathing into a valid entry
    or a,a
    ret z
    inc a
    ret z
    inc a
    ret z
    call fs_GetFDPtr.entry
.cleanup_dirs:
    push hl
    call fs_DirCleanup.entryptr
    pop hl
.cleanup_dirs_loop:
    push hl
    call fs_GetFDAttr.entry
    bit fd_subdir,a
    pop hl
    push hl
    call nz,.cleanup_directory
    pop hl
    ld bc,fs_file_desc_size
    add hl,bc
    ld a,(hl)
    inc a
    ret z
    inc a
    jr nz,.cleanup_dirs_loop
    call fs_GetFDPtr.entry
    ret c
    jr .cleanup_dirs_loop


; input hl = string to print
; sets lcd_x to the end of the string minus 5 characters
.print_cleaning_str:
	xor a,a
	ld (curcol),a
	inc a
	ld (currow),a
	call gui_PrintString
	ld hl,(lcd_x)
	ld bc,-5*8
	add hl,bc
	ld (lcd_x),hl
    ret

.str_cleaning_dirs:
    db "Cleaning dirs",0

.str_cleaning_up_step_1:
	db "Cleaning: 00/55", 0
