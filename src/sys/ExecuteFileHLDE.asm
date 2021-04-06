
;@DOES execute a file given a pointer to it's data section in HL
;@INPUT HL = pointer to file data section, DE = pointer to args
;@OUTPUT -1 if file is not a valid executable format
;@DESTROYS All, OP6.
sys_ExecuteFileHLDE:=sys_ExecuteFile.entryhlde
