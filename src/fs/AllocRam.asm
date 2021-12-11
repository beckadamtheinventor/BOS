
fs_AllocRam:
	pop de
	ex (sp),hl
	push de
	ld de,(top_of_UserMem)
	call _InsertMem
	ret nc
	sbc hl,hl
	ret
