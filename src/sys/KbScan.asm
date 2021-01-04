;-------------------------------------------------------------------------------
;@DOES Scans the keypad and updates data registers
;@DESTROYS HL,AF
kb_Scan:
sys_KbScan:
	ld	hl,$f50200		; DI_Mode = $f5xx00
	ld	(hl),h
	xor	a,a
.loop:
	cp	a,(hl)
	jr	nz,.loop
	ret

