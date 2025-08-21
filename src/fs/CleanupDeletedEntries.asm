;@DOES Cleanup deleted directory entries
;@INPUT None
;@OUTPUT None
;@NOTE Ensures 8bpp mode and draws progress indicator.
fs_CleanupDeletedEntries:
    ; start at root directory
    ld hl,.str_cleaning_dirs
    call gui_DrawConsoleWindow

    ld hl,fs_root_dir_address
    ; call .cleanup_dirs

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

.str_cleaning_dirs:
    db "Cleaning deleted entries",0
