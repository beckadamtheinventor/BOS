;-------------------------------------------------------------------------------
msd_Reset:
; Attempts to reset and restore normal working order.
; args:
;  sp + 3  : msd device structure
; return:
;  hl = error status
	pop	de,iy
	push	iy,de
	bit	MSD_FLAG_IS_INIT,(ymsdDevice.flags)
	jq	nz,.enter
	ld	hl,MSD_ERROR_NOT_INITIALIZED
	ret
.enter:
	push	iy
	ld	bc,0
	ld	c,(ymsdDevice.configindex)
	push	bc
	ld	bc,(ymsdDevice.dev)	; usb device
	push	bc
	call	usb_GetConfigurationDescriptorTotalLength
	pop	bc,bc
	pop	iy
	compare_hl_zero
	jq	z,.usberror
	push	iy
	ld	bc,tmp.length		; storage for length of descriptor
	push	bc
	push	hl			; length of configuration descriptor
	ld	bc,(ymsdDevice.buffer)
	push	bc
	ld	bc,0
	ld	c,(ymsdDevice.configindex)
	push	bc			; configuration index
	ld	bc,2			; USB_CONFIGURATION_DESCRIPTOR
	push	bc
	ld	bc,(ymsdDevice.dev)
	push	bc
	call	usb_GetDescriptor
	pop	bc,bc,bc,bc,bc,bc
	pop	iy
	compare_hl_zero
	jq	nz,.usberror			; ensure success
	push	iy
	ld	bc,(tmp.length)
	push	bc
	ld	bc,(ymsdDevice.buffer)
	push	bc
	ld	bc,(ymsdDevice.dev)
	push	bc
	call	usb_SetConfiguration
	pop	bc
	pop	bc
	pop	bc
	pop	iy
	compare_hl_zero
	jq	z,.configuredmsd
.usberror:
	ld	hl,MSD_ERROR_USB_FAILED
	ret
.configuredmsd:
	call	util_msd_reset
	compare_hl_zero
	jq	nz,.usberror
	call	util_msd_get_max_lun
	compare_hl_zero
	jq	nz,.usberror
	jq	util_scsi_init		; return success if init scsi

