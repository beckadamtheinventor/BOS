usb_ControlTransfer:
	ld	hl,usb_ScheduleControlTransfer.enter
	jq	usb_Transfer.enter
