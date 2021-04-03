
;@DOES execute a file given a pointer to it's data section in HL
;@INPUT HL = pointer to file data section
;@OUTPUT -1 if file is not a valid executable format
;@DESTROYS All, OP6.
sys_ExecuteFileHL:
	ld de,$FF0000
	jq sys_ExecuteFile.entryhlde
