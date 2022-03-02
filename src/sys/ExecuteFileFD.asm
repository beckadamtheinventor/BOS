
;@DOES execute a file given a file descriptor
;@INPUT HL = pointer to file descriptor, DE = pointer to argument string
;@OUTPUT same as sys_ExecuteFile
;@DESTROYS All, OP5, OP6.
sys_ExecuteFileFD:=sys_ExecuteFile.entryfd
