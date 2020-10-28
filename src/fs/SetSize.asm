
;@DOES Resizes a file descriptor.
;@INPUT int fs_SetSize(int len, void *fd);
;@OUTPUT number of bytes allocated to the file
;@NOTE Will allocate enough sectors to contain len bytes.
fs_SetSize:
	call ti._frameset0
	
	pop ix
	ret

