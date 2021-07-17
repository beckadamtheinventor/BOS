
USB_DEFAULT_INIT_FLAGS := 36106
USB_DEVICE_CONNECTED_EVENT := 2
USB_HOST_CONFIGURE_EVENT := 8
SRL_INTERFACE_ANY := $FF
bUSB_ROLE_DEVICE := 4
SRL_BAUD_RATE := 115200

_serial_exe:
trx 127
	call .load_libload
	ret nz
	call .srl_GetCDCStandardDescriptors
	ld bc,USB_DEFAULT_INIT_FLAGS
	push bc,hl
	ld c,0
	ld b,c
	ld hl,.usb_event_handler
	push bc,hl
	call .usb_Init
	pop bc,bc,bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret nz
.wait_for_events_loop:
	HandleNextThread
assert ~bos.thread_map and $FF
	ld hl,bos.thread_map
	ld a,(bos.current_thread)
	ld l,a
	bit 6,(hl)
	jr nz,.exit_deinit
	ld a,(.serial_inited)
	or a,a
	jr nz,.wait_for_events_loop
.exit_deinit:
	ld hl,.srl_device
	push hl
	call .srl_Close
	pop bc
	ret
.exit:
	xor a,a
	ld (bos.last_keypress),a
	ret

.usb_event_handler:
	call ti._frameset0
	ld de,(ix+6)
	ld hl,USB_HOST_CONFIGURE_EVENT
	or a,a
	sbc hl,de
	jr z,.host_configure_event
	ld hl,USB_DEVICE_CONNECTED_EVENT
	or a,a
	sbc hl,de
	jr nz,.check_disconnected_event
	call .usb_GetRole
	bit bUSB_ROLE_DEVICE,l
	jq nz,.exit_.usb_event_handler
.host_configure_event:
	ld hl,.srl_device
	ld de,(ix+9)
	ld bc,SRL_BAUD_RATE
	push bc
	ld bc,SRL_INTERFACE_ANY
	push bc
	ld b,2 ;set bc to 0x200 = 512 bytes
assert ~(SRL_INTERFACE_ANY + 1) and $FF
	inc c
	push bc
	ld bc,bos.usb_sector_buffer
	push bc,de,hl
	call .srl_Open
	pop bc,bc,bc,bc,bc,bc
	ld a,l
	ld (.serial_inited),a
	jr .exit_.usb_event_handler
.check_disconnected_event:
	ld hl,.srl_device
	push hl
	call .srl_Close
	pop bc
	ld a,$FF
	ld (.serial_inited),a
.exit_.usb_event_handler:
	or a,a
	sbc hl,hl
	pop ix
	ret
.serial_inited:
	db 1
.srl_device:
	db 39 dup 0
.load_libload:
	ld hl,.libload_name
	push hl
	call bos.fs_GetFilePtr
	pop bc
	ld bc,.fail
	push bc
	ret c
	ld bc,$aa5aa5
	ld de,.libload_relocations
	jp (hl)
.fail:
	xor a,a
	inc a
	ret
.libload_relocations:
	db $C0,"USBDRVCE",0,0
.usb_Init:
	jp 0
.usb_CleanUp:
	jp 3
.usb_HandleEvents:
	jp 9
.usb_GetRole:
	jp 114
	db $C0,"SRLDRVCE",0,0
.srl_Open:
	jp 0
.srl_Close:
	jp 3
.srl_Read:
	jp 6
.srl_Write:
	jp 9
.srl_GetCDCStandardDescriptors:
	jp 12
	xor a,a
	pop hl
	ret
.libload_name:
	db "/lib/LibLoad.dll",0
end trx

