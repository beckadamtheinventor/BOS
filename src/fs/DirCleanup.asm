
;@DOES Re-allocate a directory, removing deleted entries.
;@INPUT void fs_DirCleanup(void *fd);
;@DESTROYS Up to fs_directory_size*2 bytes starting at ti.pixelShadow.
;@NOTE Does nothing if there are no deleted entries in the directory.
fs_DirCleanup:
	pop bc,hl
	push hl,bc
.entryfd:
	call fs_GetFDPtr.entry
.entryptr:
    push hl,hl ; save pointer to directory
    call fs_GetDirSize.entryptr
    ex (sp),hl
    call fs_GetDirSize.skip_deleted_entries
    pop de
    or a,a
    sbc hl,de
    pop hl ; restore pointer to directory
    ret z ; don't do anything if there are no deleted entries
    push ix,iy
    push hl

    ld hl,ti.pixelShadow
    ld bc,fs_directory_size*2-1
    ld (hl),$FF
    push hl
    pop de
    inc de
    ldir

    call sys_ReadSectorCache.only_handle_vram
    pop ix ; start of read pointer
    lea hl,ix
.loop_entry:
    ld iy,ti.pixelShadow
    lea de,iy
; input read pointer in hl
; input write pointer in de
; input start of read pointer in ix
; input start of write pointer in iy
.loop:
    ld bc,fs_file_desc_size
    ld a,(hl)
    or a,a
    jr z,.skip_entry
    inc a
    jr z,.done
    cp a,fsentry_dirextender+1
    jr nz,.copy_entry
    push de
    ld (ti.scrapMem),hl ; save current read pointer
    call fs_GetFDPtr.entry
    pop de
    jr nc,.loop
    call .flush
    jr .done
.skip_entry:
    add hl,bc
    jr .loop
.copy_entry:
    ldir
    push hl,de
    ld hl,-ti.pixelShadow
    add hl,de ; write pointer offset from pixelShadow
    lea de,ix ; start of current source pointer
    add hl,de
    ld a,(hl) ; check for dirextender
    ld (ti.scrapMem),hl ; save pointer to potential dirextender
    pop de,hl
    cp a,fsentry_dirextender
    jr nz,.loop
    call .flush
    push hl
    ex hl,de
    call fs_GetFDPtr.entry
    ex (sp),hl ; hl = current read pointer
    pop ix ; ix = new start of read pointer
    jr nc,.loop_entry
.done:
    pop iy,ix
    ret

.flush:
    push hl ; save read pointer
    ld hl,(ti.scrapMem) ; pointer to dirextender
    push hl
    lea bc,ix ; start of directory section in flash
    or a,a
    sbc hl,bc
    push hl ; length to write
    push iy ; start of current source pointer
    push bc ; destination pointer
    call nz,sys_WriteFlashFullRam ; only write if len>0
    pop bc
    pop iy
    pop bc
    pop hl ; read pointer
    pop de ; pointer to dirextender
    ret
