
; BC = 0 - BC
_NegBC:
	push hl
	or a,a
	sbc hl,hl
	sbc hl,bc
	ex (sp),hl
	pop bc
	ret

; DE = 0 - DE
_NegDE:
	push hl
	or a,a
	sbc hl,hl
	sbc hl,de
	ex (sp),hl
	pop de
	ret
