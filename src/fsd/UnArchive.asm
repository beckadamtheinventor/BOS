;@DOES Read a file from archive into RAM.
;@INPUT bool fsd_UnArchive(void** fd);
;@OUTPUT true if success.
fsd_UnArchive:
	pop bc,hl
	push hl,bc
.entryhl:
	call fsd_IsOpen.entryhl
	ret z
	push hl
	ex (sp),iy
	call fsd_Open.unarc
	pop iy
	or a,1
	ret