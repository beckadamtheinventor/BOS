; iy -> msd structure
util_msd_reset:
	xor	a,a
	sbc	hl,hl
	ld	(ymsdDevice.tag + 0),hl
	ld	(ymsdDevice.tag + 3),a	; reset tag
	ld	a,(ymsdDevice.interface)
	ld	(setup.msdreset + 4),a
	ld	hl,setup.msdreset
	jq	util_msd_ctl_packet

