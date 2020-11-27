;@DOES write data to a file
;@INPUT int fs_Write(void *data, int len, uint8_t count, void *fd, int offset);
;@OUTPUT Returns -1 if failed to write
;@DESTROYS All. Assume OP5, OP6
;@NOTE file must be at least offset + len bytes in size.
fs_Write:
	ret

