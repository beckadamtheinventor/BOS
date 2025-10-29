;@DOES Write a UTF-8 string from a Unicode codepoint.
;@INPUT int unicode_CodepointToUTF8(char* str, int codepoint);
;@OUTPUT number of bytes written. 0 if codepoint is out of range.
unicode_CodepointToUTF8:
    call ti._frameset0
    ld de,(ix+9)
    ld hl,$7F
    or a,a
    sbc hl,de
    jr c,.over_7F
    ld hl,(ix+6)
    ld (hl),e
    ld hl,1
    jr .done

.over_7F:
    ld hl,$7FF
    or a,a
    sbc hl,de
    jr c,.over_7FF
    ld hl,(ix+6)
    ld c,d
    ld a,e
    rlca
    rl d
    rlca
    ld a,d
    rla
    or a,$C0
    ld d,a
    ld a,e
    and a,$3F
    or a,$80
    ld (hl),a
    inc hl
    ld (hl),d
    ld hl,2
    jr .done

.over_7FF:
    ld hl,$FFFF
    or a,a
    sbc hl,de
    jr c,.over_FFFF
    ld hl,(ix+6)
    ld a,d
    rrca
    rrca
    rrca
    rrca
    or a,$E0
    ld (hl),a
    inc hl
    ld a,d
    ld c,e
    rlc c
    rlca
    rlc c
    rlca
    and a,$3F
    or a,$80
    ld (hl),a
    inc hl
    ld a,e
    and a,$3F
    or a,$80
    ld (hl),a
    ld hl,3
    jr .done

.over_FFFF:
    ld hl,$10FFFF
    or a,a
    sbc hl,de
    jr nc,.under_10FFFF
    or a,a
    sbc hl,hl
    jr .done
.under_10FFFF:
    ld hl,(ix+6)
    push de
    pop de
    ld a,(ix-3) ; a = upper byte of de
    rrca
    rrca
    or a,$F0
    ld (hl),a
    inc hl
    ld a,(ix-3) ; a = upper byte of de
    rrca
    rrca
    rrca
    rrca
    ld c,a
    ld a,d
    and a,$F
    or a,c
    and a,$3F
    or a,$80
    ld (hl),a
    inc hl
    ld a,d
    rlca
    rlca
    ld c,a
    ld a,e
    rla
    rla
    and a,$3
    or a,c
    and a,$3F
    or a,$80
    ld (hl),a
    inc hl
    ld a,e
    and a,$3F
    or a,$80
    ld (hl),a
    ld hl,4
.done:
    pop ix
    ret
