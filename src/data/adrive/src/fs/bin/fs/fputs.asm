    jr _fputs_main
    db "FEX",0
_fputs_main:
    ld hl,-10
    call ti._frameset
    ld (ix-1),0
    ld a,(ix+6)
    cp a,3
    jp c,.info
    cp a,4
    jr c,.no_extra_args
    syscall _argv_3
    call .extra_arg
    ld a,(ix+6)
    cp a,5
    jr c,.no_extra_args
    syscall _argv_4
    call .extra_arg
.no_extra_args:
    syscall _argv_2
    push hl
    call ti._strlen
    ld (ix-10),hl ; string length
    ld a,(ix-1)
    or a,a
    jr z,.no_extra_byte
    inc hl
    cp a,3 ; both bits 0 and 1
    jr z,.no_extra_byte
    inc hl
.no_extra_byte:
    ld (ix-4),hl ; string length + extra bytes
    ex (sp),hl
    ld l,0 ; file attribute byte
    push hl
    syscall _argv_1 ; file name
    push hl
    call bos.fs_OpenFile
    call nc,bos.fs_CreateFile
    ld (ix-7),hl
    ex (sp),hl
    call bos.fs_GetFDLen
    add hl,bc
    or a,a
    sbc hl,bc
    jr z,.no_need_resize
    ld bc,(ix-4)
    add hl,bc
    push hl ; file size
    call bos.fs_SetSize
    jr c,.fail
    pop bc ; file length
; hl = new file descriptor
    ld de,0
    push de,hl ; offset, descriptor
    ld e,1
    push de,bc ; count, len
    ld hl,(ix-7) ; old desc
    push hl
    call bos.fs_GetFDPtr
    ex (sp),hl ; store old file pointer
    call bos.fs_Write ; rewrite old data
    ld (ix-7),hl
    pop bc,bc,bc,hl,bc
.no_need_resize:
    ex (sp),hl ; store file size
    ld hl,(ix-7)
    push hl ; file descriptor
    ld l,1 ; write count
    push hl
    ld hl,(ix-4) ; string length
    push hl
    syscall _argv_2 ; string
    push hl
    call bos.fs_Write
    pop bc,hl,bc,de
    ex (sp),hl ; new write offset
    push de ; file descriptor
    ld l,$A ; newline character
    push hl
    bit 1,(ix-1)
    call nz,bos.fs_WriteByte
    pop bc,de
    bit 1,(ix-1)
    jr z,.no_newline_dont_inc_offset
    pop hl
    inc hl
    push hl
.no_newline_dont_inc_offset:
    push de ; file descriptor
    ld l,0 ; null character
    push hl
    bit 0,(ix-1)
    call nz,bos.fs_WriteByte
    pop bc,bc,bc
    jr .done
.fail:
    ld hl,.failed_to_write_file
    jr .print_and_done
.info:
    ld hl,.infostr
.print_and_done:
    call bos.gui_PrintLine
.done:
    or a,a
    sbc hl,hl
    ld sp,ix
    pop ix
    ret

.extra_arg:
    ld a,(hl)
    cp a,'-'
    ret nz
    inc hl
    ld a,(hl)
    cp a,'0'
    jr nz,.not_extra_null_char
    set 0,(ix-1)
.not_extra_null_char:
    cp a,'l'
    ret nz
    set 1,(ix-1)
    ret

.infostr:
    db "Usage: fputs file str [-0][-l]",$A
    db "-0 includes null character",$A
    db "-l includes newline character",0

.failed_to_write_file:
    db "Failed to write file",0

