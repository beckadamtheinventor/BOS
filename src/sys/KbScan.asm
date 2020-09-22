;-------------------------------------------------------------------------------
;@DOES Scans the keypad and updates data registers
;@NOTE Disables interrupts during execution, and restores on exit
;@DESTROYS HL,AF
kb_Scan:
sys_KbScan:
	di
	ld	hl,$f50200		; DI_Mode = $f5xx00
	ld	(hl),h
	xor	a,a
.loop:
	cp	a,(hl)
	jr	nz,.loop
	ret

