
;@DOES Overwrite all data stored in a file from a given data pointer.
;@INPUT int WriteFile(void *data, int len, void *fd);
;@OUTPUT number of bytes written. 0 if failed to write
;@NOTE Only the number of clusters aready allocated to the file will be written. Call fs_SetSize() to reallocate file clusters.
fs_WriteFile:
	ret


