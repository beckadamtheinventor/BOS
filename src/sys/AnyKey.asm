;-------------------------------------------------------------------------------
;@DOES Scans the keypad and updates data registers; checking if a key was pressed
;@NOTE Disables interrupts during execution
;@DESTROYS HL,AF
;@OUTPUT 0 if no keys pressed
kb_AnyKey:
sys_AnyKey:
	di
	ld	hl,$f50200		; DI_Mode = $f5xx00
	ld	(hl),h
	xor	a,a
.loop:
	cp	a,(hl)
	jr	nz,.loop
	ld	l,$12			; kbdG1 = $f5xx12
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	inc	hl
	inc	hl
	or	a,(hl)
	ret


