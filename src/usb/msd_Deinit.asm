;-------------------------------------------------------------------------------
msd_Deinit:
; Deinitializes the MSD structure as needed.
; args:
;  sp + 3  : msd device structure
; return:
;  hl = error status
	ld	iy,0
	add	iy,sp
	ld	hl,(iy + 3)
	push	hl
	pop	de
	ld	(hl),0
	inc	hl
	ld	bc,sizeof msdDevice
	ldir
	ret
