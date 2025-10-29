;@DOES Return a single character codepoint from a UTF-8 encoded string.
;@INPUT int unicode_UTF8ToCodepoint(const char* str, unsigned int* offset);
;@OUTPUT 24-bit codepoint, -1 if data is invalid. Updates offset with the number of bytes read.
;@NOTE offset is used to index the string so this function can be easily chained. It must NOT be null.
unicode_UTF8ToCodepoint:
    call ti._frameset0

    ld hl,(ix+9)
    ld hl,(hl)
    ld de,(ix+6)
    add hl,de

    ld a,(hl)
    add a,a
    jr c,.over_1b
    ld a,(hl)
    sbc hl,hl
    ld l,a
    ld c,1
    jr .done

.over_1b:
    add a,a
    jr c,.fail
    add a,a
    jr c,.over_2b
    ld a,(hl)
    inc hl
    ld c,(hl)
    and a,$1f
    call .common_2b
    ld c,2
    jr .done

.over_2b:
    add a,a
    jr c,.over_3b
    ld a,(hl)
    inc hl
    ld c,(hl)
    inc hl
    ld e,(hl)
    call .common_2b
    call .common_3b
    ld c,3
    jr .done

.over_3b:
    add a,a
    jr c,.fail
    ld a,(hl)
    inc hl
    ld c,(hl)
    inc hl
    ld e,(hl)
    inc hl
    ld d,(hl)
    push de
    call .common_2b
    call .common_3b
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    pop de
    ld e,1
    mlt de
    add hl,de
    ld c,4
.done:
    push hl
    ld hl,(ix+9)
    ld de,(hl)
    ex de,hl
    ld b,1
    mlt bc
    add hl,bc
    ex de,hl
    ld (hl),de
    pop hl
    jr ._done
.fail:
    sbc hl,hl
._done:
    pop ix
    ret

.common_2b:
    or a,a
    sbc hl,hl
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld b,1
    mlt bc
    add hl,bc
    ret

.common_3b:
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl
    ld d,1
    mlt de
    add hl,de
    ret
