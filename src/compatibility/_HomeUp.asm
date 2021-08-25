;@DOES Set the cursor position to 0,0
_HomeUp:
	xor a,a
	ld (console_line),a
	ld (console_col),a
	ret
