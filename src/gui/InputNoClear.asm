;@DOES get user input without clearing the provided buffer first.
;@INPUT uint8_t gui_InputNoClear(char *buffer, int max_len);
;@OUTPUT 0 if user exit, 1 if user enter, 9/12 if user presses down/up arrow key
;@DESTROYS All
gui_InputNoClear:
	ld hl,-8
	call ti._frameset
	ld hl,(ix+6)
	push hl
	call ti._strlen
	pop bc
	ld (ix-3),hl
	ld a,1
	ld (ix-4),a
	jq gui_Input.enter_no_clear_buffer

