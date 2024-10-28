;@DOES Write a file to archive, unloading from RAM.
;@INPUT bool fsd_Archive(void** fd);
;@OUTPUT true if success.
fsd_Archive:
	pop bc,hl
	push hl,bc
.entryhl:
	call fsd_IsOpen.entryhl
	ret z
	call fsd_Close.entryflushhl ; flush to archive, unload from RAM
	or a,1
	ret
	