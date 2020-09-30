;-------------------------------------------------------------------------------
msd_ReadSectors:
; Reads sectors from a Mass Storage Device
; inputs:
;  sp + 3: msd device structure
;  sp + 6 & 9: first lba
;  sp + 12: number of sectors
;  sp + 15: user buffer to read into
; outputs:
;  hl: error status
	push	ix
	ld	ix,scsi.read10
	jq	util_msd_read_write_sectors

