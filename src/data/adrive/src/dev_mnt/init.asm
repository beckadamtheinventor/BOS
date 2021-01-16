include '../include/ez80.inc'
include '../include/ti84pceg.inc'
include '../include/bos.inc'
include 'usbRAM.inc'


org bos.driverExecRAM
	call load_libload
	jq nz,_return_fail
	ld (_ErrSP),sp
	ld hl,main_event_handler.source
	ld de,main_event_handler.destination
	ld bc,main_event_handler.len
	ldir
;init USB
	ld bc, 12  ;USB_DEFAULT_INIT_FLAGS
	push bc
	ld bc, 0       ;use default device descriptors
	push bc
	ld bc, usb_device
	push bc     ;and pass the usb device for the Opaque pointer
	ld bc,main_event_handler.destination
	push bc
	call usb_Init
	pop bc,bc,bc,bc
	or a,a
	add hl,bc
	sbc hl,bc
	jq nz,_return_fail
wait_for_device_loop:
	call usb_WaitForInterrupt
	add hl,bc
	or a,a
	sbc hl,bc
	jq nz,_return_fail
	ld hl,(usb_device)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,wait_for_device_loop
	call main_msd_Init
	


reset_smc_bytes:
	ld a,$01 ;ld bc,...
	ld (main_msd_Init),a
	ld a,$0E ;ld c,...
	ld (init_fat_partition),a
;	ld a,$AF ;xor a,a
;	ld (init_fat_volume),a
	ret

main_msd_Init:
	ld bc,bos.usb_sector_buffer
	ld hl,msd_device
	ld de,(hl)
	push bc,de,hl
	call msd_Init
	pop bc,bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret nz
	ld a,$C9 ;smc to ret so this routine doesn't try to re-init the drive constantly.
	ld (.),a
	ret


init_fat_partition:
	ld c,1
	push bc
	ld bc,found_partitions
	push bc
	ld bc,partition_descriptor
	push bc
	ld bc,msd_device
	push bc
	call fat_Find
	pop bc,bc,bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret nz
	ld hl,(found_partitions)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.no_partitions
	ld bc,partition_descriptor
	push bc
	ld bc,fat_device
	push bc
	call fat_Init
	pop bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret nz
	ld a,$C9
	ld (.),a ;smc so we don't run this code again
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
	ld sp,0
_ErrSP:=$-3
	scf
	sbc hl,hl
	ret

load_libload:
	ld hl,libload_file
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,.fail
	ld bc,$0C
	add hl,bc
	ld hl,(hl)
	push hl
	call bos.fs_GetSectorAddress
	pop bc
	ld de,libload_relocations
	ld bc,$aa55aa
	jp (hl)
.fail:
	xor a,a
	inc a
	ret
libload_file:
	db "/lib/LibLoad.LLL",0


libload_relocations:
db $C0,"USBDRVCE",0,0
usb_Init:
	jp 0
usb_Cleanup:
	jp 3
usb_HandleEvents:
	jp 9
usb_WaitForInterrupt:
	jp 15
usb_ResetDevice:
	jp 39

db $C0,"FATDRVCE",0,1
msd_Init:
	jp 0
msd_Reset:
	jp 9
fat_Find:
	jp 24
fat_Init:
	jp 27
fat_Deinit:
	jp 30
fat_DirList:
	jp 33
fat_GetVolumeLabel:
	jp 36

	xor a,a
	pop hl
	ret

main_event_handler.destination := bos.reservedRAM
virtual at main_event_handler.destination
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
	call usb_ResetDevice
	pop bc
	jq .success
.device_disconnected:
	ld de,0
	ld hl,(ix+12)
	ld (hl),de
	jq .success

load main_event_handler.data: $-$$ from $$
main_event_handler.len:=$-$$
end virtual
main_event_handler.source:
	db main_event_handler.data

