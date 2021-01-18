;@DOES Clean up and optimize the filesystem, and reset freed areas.
;@INPUT None
;@OUTPUT None
;@DESTROYS All
;@NOTE will sanity-check the filesystem if the cluster map is not found.
fs_GarbageCollect:
	ld hl,-12
	call ti._frameset
	ld bc,fs_cluster_map_file
	push bc
	call fs_OpenFile
	pop bc
	jq c,fs_SanityCheck
	ld (ix-3),hl
	ld (ix-9),hl
	ld bc,8192
	add hl,bc
	ld (ix-12),hl

; clean up freed sectors
	ld bc,$040000
	ld (ix-6),bc
.cleanup_freed_loop_outer:
	ld hl,(ix-6)
	call .check_sector
	cp a,$FF
	jq z,.cleanup_next
	ld a,$3F
	call sys_EraseFlashSector
	ld hl,(ix-3)
	ld b,128
.cleanup_freed_loop:
	ld a,(hl)
	cp a,$FF
	jq z,.cleanup_next
	or a,a
	jq z,.cleanup_next
	push hl,bc
	ld a,128
	sub a,b
	add a,a
	ld de,$3F0000
	ld hl,(ix-6)
	ld d,a
	ld h,a
	ld bc,512
	call sys_WriteFlash
	pop bc,hl
.cleanup_next:
	inc hl
	djnz .cleanup_freed_loop
	ld a,(ix-4)
	call sys_EraseFlashSector
	ld hl,$3F0000
	ld de,(ix-6)
	ld bc,$010000
	call sys_WriteFlash
	ld a,(ix-4)
	inc a
	ld (ix-4),a
	cp a,$3F
	jq nz,.cleanup_freed_loop_outer

;TODO: move files around to free up space
;	ld hl,(ix-9)
;	ld bc,(ix-12)
;.find_free_space_loop:
;	or a,a
;	sbc hl,bc
;	jq nc,.done_reallocating
;	adc hl,bc
;	ld a,(hl)
;	cp a,$FE
;	jq z,.find_free_space_loop
;	inc hl
;
;; found a free cluster
;	ex hl,de
;	ld hl,(ix-12)
;	or a,a
;	sbc hl,de
;	push hl
;	pop bc
;	ex hl,de
;	ld a,$FE ;search for in-use cluster following free clusters
;	cpir

;.done_reallocating:
	call fs_InitClusterMap

	ld sp,ix
	pop ix
	ret

.check_sector:
	ld a,(hl)
	ld bc,0
.check_sector_loop:
	and a,(hl)
	inc hl
	djnz .check_sector_loop
	dec c
	jq nz,.check_sector_loop
	ret

