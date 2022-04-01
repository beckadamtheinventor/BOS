
;@DOES return the amount of free archive space at ti.tempFreeArc
_ArcChk:
	call fs_GetFreeSpace
	ld (ti.tempFreeArc),hl
	ret