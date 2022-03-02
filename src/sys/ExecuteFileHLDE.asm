
;@DOES execute a file given a pointer to it's path in HL and arguments string in DE
;@INPUT HL = pointer to file path, DE = pointer to arguments string.
;@OUTPUT same as sys_ExecuteFile
;@DESTROYS All, OP5, OP6.
sys_ExecuteFileHLDE:=sys_ExecuteFile.entryhlde
