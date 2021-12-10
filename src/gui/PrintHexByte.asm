;@DOES print a byte in hexadecimal
;@INPUT A number to display
;@NOTE does not blit the lcd buffer
gui_PrintHexByte:
	push af
	rrca
	rrca
	rrca
	rrca
	and a,$F
	cp a,10
	jr c,.printupper
	add a,'A' - $3A
.printupper:
	add a,'0'
	call gui_PrintChar
	pop af
	and a,$F
	cp a,10
	jr c,.printlower
	add a,'A' - $3A
.printlower:
	add a,'0'
	jq gui_PrintChar
