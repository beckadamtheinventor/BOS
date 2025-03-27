;@DOES Get the actual size of a directory.
;@INPUT int fs_GetDirSize(const char* path);
;@NOTE returns pointer to first empty entry or non-allocated dirextender in de
fs_GetDirSize:
    pop bc,hl
    push hl,bc
.entryhl:
    call fs_OpenFile.entryhl
.entryfd:
    call fs_GetFDPtr.entry
.entryptr:
    ld de,0
    push iy
    ld iyl,0 ; don't skip deleted entries
    jr .loop_entry
.skip_deleted_entries:
    ld de,0
    push iy
    ld iyl,1
    jr .loop_entry
.loop:
    ld bc,fs_file_desc_size
    add hl,bc
    ex hl,de
    add hl,bc
    ex hl,de
.loop_entry:
    ld a,iyl
    or a,a
    jr z,.dont_skip_deleted
    ld a,(hl)
    or a,a
    jr nz,.dont_skip_deleted
    ld bc,fs_file_desc_size
    add hl,bc
    jr .loop_entry
.dont_skip_deleted:
    ld a,(hl)
assert fsentry_endofdir = $FF
    inc a
    jr z,.return_de
assert fsentry_dirextender = $FE
    inc a
    jr nz,.loop
    push hl,de
    call fs_GetFDPtr.entry ; get pointer to next directory section
    pop de
    jr c,.pop_hl_return_de ; next directory not allocated
    pop bc
    jr .loop
.pop_hl_return_de:
    pop hl
.return_de:
    ex hl,de
    pop iy
    ret

