util_msd_status_xfer:
	ld	a,(ymsdDevice.bulkinaddr)
	ld	ix,tmp.csw
	ld	bc,sizeof packetCSW
	jq	util_msd_bulk_transfer

