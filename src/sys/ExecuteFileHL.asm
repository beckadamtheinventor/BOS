
;@DOES execute a file given a pointer to it's path in HL
;@INPUT HL = pointer to file path
;@OUTPUT same as sys_ExecuteFile
;@DESTROYS All, OP5, OP6.
sys_ExecuteFileHL:
	ld de,$FF0000
	jq sys_ExecuteFileHLDE
