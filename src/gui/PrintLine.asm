
gui_PrintLine:
	; xor a,a
	; ld (curcol),a
	call gui_Print
	jq gui_NewLine
