;@DOES Handle an on interrupt if they are enabled and one happens.
;@NOTE Preserves interrupt state.
sys_HandleOnInterrupt:
	ld a,(ti.mpIntMask)
	bit ti.bIntOn,a
	ret z
	ld a,r
	push af
	ei
	ld b,0
	djnz $
	pop af
	ret pe
	di
	ret
