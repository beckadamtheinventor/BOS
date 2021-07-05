
USB_DEFAULT_INIT_FLAGS := 36106
USB_DEVICE_CONNECTED_EVENT := 2
USB_HOST_CONFIGURE_EVENT := 8
SRL_INTERFACE_ANY := $FF
bUSB_ROLE_DEVICE := 4
SRL_BAUD_RATE := 115200

_serial_exe:
trx 127
	; jr .init
	; db "TRX",0,3
	; dw .full_len
	; dw .num_relocations
; .relocations:
	; dw .re0, .re1, .re2, .re3, .re4, .re5, .re6, .re7, .re8, .re9, .re10, .re11, .re12, .re13, .re14, .re15, .re16
; .num_relocations := ($ - .relocations) shr 1
; .init:
	; db _serial_exe_data

; virtual at 0
	call .load_libload
.re3:=$-3
	ret nz
	call .srl_GetCDCStandardDescriptors
.re4:=$-3
	ld bc,USB_DEFAULT_INIT_FLAGS
	push bc,hl
	ld c,0
	ld b,c
	ld hl,.usb_event_handler
.re5:=$-3
	push bc,hl
	call .usb_Init
.re6:=$-3
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
.re14:=$-3
	or a,a
	jr nz,.wait_for_events_loop
.exit_deinit:
	ld hl,.srl_device
.re15:=$-3
	push hl
	call .srl_Close
.re16:=$-3
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
.re7:=$-3
	bit bUSB_ROLE_DEVICE,l
	jq nz,.exit_.usb_event_handler
.host_configure_event:
	ld hl,.srl_device
.re8:=$-3
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
.re9:=$-3
	pop bc,bc,bc,bc,bc,bc
	ld a,l
	ld (.serial_inited),a
.re10:=$-3
	jr .exit_.usb_event_handler
.check_disconnected_event:
	ld hl,.srl_device
.re11:=$-3
	push hl
	call .srl_Close
.re12:=$-3
	pop bc
	ld a,$FF
	ld (.serial_inited),a
.re13:=$-3
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
.re0:=$-3
	push hl
	call bos.fs_GetFilePtr
	pop bc
	ld bc,.fail
.re2:=$-3
	push bc
	ret c
	ld bc,$aa5aa5
	ld de,.libload_relocations
.re1:=$-3
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

; .full_len := $-$$
; load _serial_exe_data: $-$$ from $$
; end virtual
end trx

