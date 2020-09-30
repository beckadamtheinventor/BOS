;-------------------------------------------------------------------------------
msd_IsInit:
; Checks if the MSD has been successfully initialized.
; args:
;  sp + 3  : msd device structure
; return:
;  hl = error status
	ld	iy,0
	add	iy,sp
	ld	iy,(iy + 3)
	bit	MSD_FLAG_IS_INIT,(ymsdDevice.flags)
	jq	z,.notinit
	or	a,a
	sbc	hl,hl
	ret
.notinit:
	ld	hl,MSD_ERROR_NOT_INITIALIZED
	ret

