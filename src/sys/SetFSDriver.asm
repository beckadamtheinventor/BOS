;@DOES set the currently active filesystem driver
;@NOTE this will eventually allow for multiple filesystem types
sys_SetFSDriver:
	cp a,1
	ret nc ;return if invalid.
	ld (filesystem_driver),a
	ret

