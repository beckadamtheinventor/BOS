;@DOES Temporarily enable handling of interrupts.
;@NOTE Preserves interrupt state.
sys_HandleOnInterrupt:
    push bc,af
;    push hl,bc
;	ld hl,ti.mpIntMask
;    bit ti.bIntOn,(hl)
;    push af
;    set ti.bIntOn,(hl)
	ei
	ld b,0
	djnz $
    di
;    pop af
;    jr nz,.dont_redisable
;	ld hl,ti.mpIntMask
;    res ti.bIntOn,(hl)
;.dont_redisable:
;    pop bc,hl
    pop af,bc
	ret

