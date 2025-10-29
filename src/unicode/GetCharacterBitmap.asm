;@DOES Find and return a bitmap for a given Unicode character.
;@INPUT void* unicode_GetCharacterBitmap(unsigned int codepoint);
;@OUTPUT Pointer to 16x16 character bitmap, or 0 and Cf set if failed.
unicode_GetCharacterBitmap:
    pop bc
    ex (sp),hl
    push bc
.entryhl:
; DE = L * 32
; HL = UH * 2
    ld d,16
    ld e,l
    mlt de
    add hl,hl ; x2
; shift hl down 8 bits
    push hl
    inc sp
    pop hl
    dec sp
; clamp DE and HL to 16 bits
    ex.s de,hl
    ex de,hl
    ld bc,(unicode_font_ptr)
; &font[H * 2]
    add hl,bc
    mlt bc ; zero BCU
; offset = *(uint16_t*)(&font[H * 2]);
    ld c,(hl)
    inc hl
    ld b,(hl)
    inc hl
; fail if offset is zero
    ld a,c
    or a,b
    jr z,.fail
; add offset * 16 to get code page
    push bc
    ex (sp),hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ex (sp),hl
    pop bc
; add (codepoint & 0xff) * 32
    add hl,de
; HL now points to list of 16x16 bitmaps for a given codepage (32 bytes each)
    ; or a,a ; unnecessary because of prior or instruction resetting carry flag
    ret
.fail:
    scf ; set carry flag
    sbc hl,hl ; HL = -1
    inc hl ; HL = 0
    ret
