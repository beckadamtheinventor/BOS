include '../include/ez80.inc'
include '../include/ti84pceg.inc'
include '../include/bos.inc'
include 'usbRAM.inc'

macro CallOffset? offset
	rst $28
	dl offset
end macro

; files are passed a pointer to themselves in HL when run, so should device driver routines
virtual at 0
	ld a,(bos.running_process_id)
	ld (bos.fsOP6+15),a
	ld a,1
	ld (bos.running_process_id),a
	ld bc,main_code.source
	add hl,bc
	ld bc,main_code.len
	push hl,bc
	call bos.sys_Malloc
	ex hl,de
	pop bc,hl
	ret c
	push de
	ldir
	ld a,(bos.fsOP6+15)
	ld (bos.running_process_id),a
	pop hl
	ld bc,main_code.start
	add hl,bc
	jp (hl)
main_code.source:
	db main_code.data
load dev_init_code:$-$$ from $$
end virtual

	db dev_init_code

virtual at 0
libload_relocations:
	db $C0,"USBDRVCE",0,0
	jp 0
	jp 3
	jp 9
	jp 15
	jp 39
	db $C0,"FATDRVCE",0,1
	jp 0
	jp 3
	jp 6
	jp 9
	jp 12
	jp 15
	jp 18
	jp 21
	jp 24
	jp 27
	jp 30
	jp 33
	jp 36
	jp 39
	jp 42
	jp 45
	jp 48
	jp 51
	jp 54
	jp 57
	jp 60
	jp 63
	jp 66
	jp 69
	jp 72

	xor a,a
	pop hl
	ret

libload_load:
	ld hl,.file
	push de,hl
	call bos.fs_GetFilePtr
	pop bc,bc
	jr c,.fail
	ld de,.fail
	push de
	ex hl,de
	ld hl,libload_relocations
	ld bc,(bos.running_program_ptr)
	add hl,bc
	ex hl,de
	ld bc,$aa5aa5 ;tell libload to use malloc
	jp (hl)
.fail:
	scf
	sbc a,a
	sbc hl,hl
	ret
.file:
	db "/lib/LibLoad.dll",0
main_code.start:
	CallOffset libload_load
;init USB
	ld bc, 12  ;USB_DEFAULT_INIT_FLAGS
	push bc
	ld bc, 0       ;use default device descriptors
	push bc
	ld bc, usb_device
	push bc     ;and pass the usb device for the Opaque pointer
	ld bc,main_event_handler
	ld hl,(bos.running_program_ptr)
	add hl,bc
	push hl
	CallOffset usb_Init
	pop bc,bc,bc,bc
	or a,a
	add hl,bc
	sbc hl,bc
	jq nz,_return_fail
	ld bc,2
	push bc
	call bos.sys_Malloc
	pop bc
	jq c,_return_fail
	ld (current_dir_ptr),hl
wait_for_device_loop:
	CallOffset usb_WaitForInterrupt
	add hl,bc
	or a,a
	sbc hl,bc
	jq nz,_return_fail
	ld hl,(usb_device)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,wait_for_device_loop
	CallOffset main_msd_init
	ret


reset_smc_bytes:
	ld a,$01 ;ld bc,...
	ld hl,main_msd_init
	ld bc,(bos.running_program_ptr)
	add hl,bc
	ld (hl),a
	ld a,$0E ;ld c,...
	ld hl,init_fat_partition
	add hl,bc
	ld (hl),a
;	ld a,$AF ;xor a,a
;	ld (init_fat_volume),a
	ret

main_msd_init:
	ld bc,bos.usb_sector_buffer
	ld hl,msd_device
	ld de,(hl)
	push bc,de,hl
	CallOffset msd_Init
	pop bc,bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret nz
	ld hl,.
	ld bc,(bos.running_program_ptr)
	add hl,bc
	ld a,$C9
	ld (hl),a ;smc so we don't run this code again
	ret


init_fat_partition:
	ld c,1
	push bc
	ld hl,found_partitions
	ld bc,(bos.running_program_ptr)
	add hl,bc
	push bc
	ld bc,partition_descriptor
	push bc
	ld bc,msd_device
	push bc
	CallOffset fat_Find
	pop bc,bc,bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret nz
	ld hl,found_partitions
	ld bc,(bos.running_program_ptr)
	add hl,bc
	ld hl,(hl)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.no_partitions
	ld bc,partition_descriptor
	push bc
	ld bc,fat_device
	push bc
	CallOffset fat_Init
	pop bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret nz
	ld hl,.
	ld bc,(bos.running_program_ptr)
	add hl,bc
	ld a,$C9
	ld (hl),a ;smc so we don't run this code again
	or a,a
	sbc hl,hl
	ret
.no_partitions:
	ld a,1
	or a,a
	ret
found_partitions:
	dl 0
 _return_fail:
	scf
	sbc hl,hl
	ret

;usb_error_t main_event_handler(usb_event_t event, void *event_data, usb_callback_data_t *callback_data);
main_event_handler:
	call ti._frameset0
	ld hl,(ix+6)
	ld a,l
	cp a, 1 ;USB_DEVICE_DISCONNECTED_EVENT
	jq z,.device_disconnected
	cp a, 2 ;USB_DEVICE_CONNECTED_EVENT
	jq z,.device_connected
	cp a, 4 ;USB_DEVICE_ENABLED_EVENT
	jq z,.device_enabled
.success:
	pop ix
	xor a,a
	sbc hl,hl
	ret
.device_enabled:
	ld de,(ix+9)
	ld (usb_device),de
	ld hl,(ix+12)
	ld (hl),de
	jq .success
.device_connected:
	ld de,(ix+9)
	push de
	CallOffset usb_ResetDevice
	pop bc
	jq .success
.device_disconnected:
	ld de,0
	ld hl,(ix+12)
	ld (hl),de
	jq .success

	load main_code.data: $-$$ from $$
	main_code.len:=$-$$
end virtual
