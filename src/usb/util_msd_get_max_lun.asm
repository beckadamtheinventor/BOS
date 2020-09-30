; inputs:
;  iy : msd structure
util_msd_get_max_lun:
	ld	a,(ymsdDevice.interface)
	ld	(setup.msdmaxlun + 4),a
	ld	hl,setup.msdmaxlun
	lea	de,ymsdDevice.maxlun
	jq	util_msd_ctl_packet

