

include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org $D1A881
	jq usbsend_main
	db "REX",0
usbsend_main:
	pop bc
	pop hl
	push hl
	push bc
	ld a,(hl)
	or a,a
	jq z,show_usage_info
	ld (_Args),hl
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	ld a,' '
	cpir
	jq nz,show_usage_info
	ld (_Arg2),hl
	dec hl
	ld (hl),0
	ld (_ErrSP),sp
	call libload_load
	jq z,usbrun_main.main
	ld hl,str_FailedToLoadLibload
	call bos.gui_Print
	scf
	sbc hl,hl
	ret
libload_load:
	ld hl,libload_name
	push hl
	call bos.fs_OpenFile
	pop bc
	jq c,.notfound
	ld bc,$0C
	add hl,bc
	ld hl,(hl)
	push hl
	call bos.fs_GetSectorAddress
	pop bc
	ld   de,libload_relocations
	ld   bc,.notfound
	push   bc
;	ld   bc,$aa55aa
	jp   (hl)

.notfound:
	xor   a,a
	inc   a
	ret
usbrun_main.main:
	ld hl,str_UsbRun
	call bos.gui_DrawConsoleWindow
;init USB
	ld bc, 12  ;USB_DEFAULT_INIT_FLAGS
	push bc
	ld bc, 0       ;use default device descriptors
	push bc
	ld bc, usb_device
	push bc     ;and pass the usb device for the Opaque pointer
	ld bc,main_event_handler
	push bc
	call usb_Init
	pop bc,bc,bc,bc
	or a,a
	add hl,bc
	sbc hl,bc
	jq nz,no_drive_found
main_init_start:
	ld hl,str_WaitingForDevice
	call bos.gui_Print
.loop:
	call usb_WaitForInterrupt
	add hl,bc
	or a,a
	sbc hl,bc
	jq nz,main_exit
	ld hl,(usb_device)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.loop
	call main_msd_Init
	jq z,.init_success
.init_fail:
	ld hl,str_FailedToInitMsd
	call bos.gui_Print
	jq main_exit
.init_success:
	ld hl,str_MsdInited
	call bos.gui_Print
init_explore_drive:
	call init_fat_partition
	jq z,send_file
.init_fat_fail:
	ld hl,str_FailedToInitFat

error_file_not_found:
	ld hl,str_FileNotFound
	jq main_print_and_exit

main_fail_memory:
	ld hl,str_MemoryError

main_print_and_exit:
	call bos.gui_Print
	call bos.sys_WaitKeyCycle
;Cleanup USB
main_exit:
	ld bc,msd_device
	push bc
	call msd_Deinit
	pop bc
	call usb_Cleanup
	ld hl,ti.mpIntAck
	set ti.bIntOn,(hl)
	jq _exit



reset_smc_bytes:
	ld a,$01 ;ld bc,...
	ld (main_msd_Init),a
	ld a,$0E ;ld c,...
	ld (init_fat_partition),a
	ret


main_msd_Init:
	ld bc,bos.usb_sector_buffer
	ld hl,msd_device
	ld de,(hl)
	push bc,de,hl
	call msd_Init
	pop bc,bc,bc
	ld a,$C9 ;smc to ret so this routine doesn't try to re-init the drive constantly.
	ld (.),a
	add hl,bc
	or a,a
	sbc hl,bc
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
	ld hl,str_LookingForPartitions
	call bos.gui_Print
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
	ld hl,str_InitializingPartition
	call bos.gui_Print
	call fat_Init
	pop bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret nz
	ld hl,str_FatInited
	call bos.gui_Print
	ld a,$C9
	ld (.),a ;smc so we don't run this code again
	or a,a
	sbc hl,hl
	ret
.no_partitions:
	ld hl,str_NoParitions
	call bos.gui_Print
	ld a,1
	or a,a
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
	jq .success
.print_then_success:
	call bos.gui_Print
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
	ld hl,str_DeviceEnabled
	jq .print_then_success
.device_connected:
	ld de,(ix+9)
	push de
	call usb_ResetDevice
	pop bc
	ld hl,str_DeviceConnected
	jq .print_then_success
.device_disconnected:
	ld de,0
	ld hl,(ix+12)
	ld (hl),de
	ld hl,str_DeviceDisconnected
	jq .print_then_success

usb_device:
msd_device:
	dl 0       ;usb_device_t dev
	db 0       ;uint8_t bulk in addr
	db 0       ;uint8_t bulk out addr
	db 0       ;uint8_t configindex
	dl 0       ;uint24_t tag
	dd 0       ;uint32_t LBA of LUN
	dd 0       ;uint32_t block size
	db 0       ;uint8_t interface
	db 0       ;uint8_t max LUN
	db 0       ;uint8_t flags
	dl 0       ;void *buffer

partition_descriptor:
	dd 0
	dl 0

fat_device:
	db 64 dup 0

fat_volume_label:
	db 18 dup 0

current_dir := bos.open_files_table

fat_dir_entries:
	db 18*8 dup 0

show_usage_info:
	ld hl,str_UsageStr
	call bos.gui_Print
	xor a,a
	sbc hl,hl
	ret

no_drive_found:
	ld hl,.string
	call bos.gui_Print
	ld hl,-2
	jq _exit
.string:
	db $9,"No avalible drive found.",$A,0

_exit:
	ld sp,0
_ErrSP:=$-3
	xor a,a
	sbc hl,hl
	ret

libload_name:
	db   "/lib/LibLoad.LLL",0
.len := $ - .
str_NoParitions:
	db "No Partitions found.",$A,0
str_LookingForPartitions:
	db "Looking for partitions...",$A,0
str_InitializingPartition:
	db "Initializing partition...",$A,0
found_partitions:
	dl 0
str_UsbRun:
	db "USB File Writer",$A,0
str_WaitingForDevice:
	db $9,"Waiting for device...",$A
	db "Please insert USB flash drive.",$A,0
str_FailedToInitFat:
	db $9,"Failed to initialize drive.",$A
	db "Are you sure it is FAT32 formatted?",$A,0
str_FailedToInitMsd:
	db $9,"Failed to init device.",$A,0
str_FailedToLoadLibload:
	db "Failed to load libload.",$A,0
str_DeviceConnected:
	db "Device connected.",$A,0
str_DeviceDisconnected:
	db "Device disconnected",$A,0
str_FatInited:
	db "FAT Filesystem initialized.",$A,"Read/Write can now occur",$A,0
str_MsdInited:
	db "Device initialized.",$A,0
str_DeviceEnabled:
	db "Device Enabled.",$A,0
str_FileNotFound:
	db $9,"File not found.",$A,0
str_MemoryError:
	db $9,"Not Enough Memory.",$A,0
str_Finished:
	db "Finished.",$A,0
str_UsageStr:
	db "Usage: USBSEND source dest",$A,0


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
msd_Deinit:
	jp 6
msd_Reset:
	jp 9
fat_Find:
	jp 24
fat_Init:
	jp 27
fat_Deinit:
	jp 30
fat_Open:
	jp 39
fat_Close:
	jp 42
fat_SetSize:
	jp 45
fat_WriteSectors:
	jp 66
fat_Delete:
	jp 72

	xor   a,a      ; return z (loaded)
	pop   hl      ; pop error return
	ret

send_file:
	ld hl,0
_Args:=$-3
	push hl
	call bos.fs_OpenFile
	pop bc
	ld (.source_fd),hl
	jq c,error_file_not_found
	ld bc,$1C
	add hl,bc
	ld hl,(hl) ;get local file size in bytes
	push hl
	ld hl,0
_Arg2:=$-3
	ld bc,fat_device
	push hl,bc
	call fat_Delete
	pop de,hl
	push hl,de
	call fat_SetSize
	pop de,hl,bc
	ld c,1 shl 1 ;FAT_WRONLY
	push bc,hl,de
	call fat_Open
	pop bc,bc,bc
	ld (.dest_fd),hl
	or a,a
	sbc hl,hl
.write_file_loop:
	push hl
	ld hl,0
.source_fd:=$-3
	ld bc,$0C
	add hl,bc
	ld hl,(hl)
	call bos.fs_GetSectorAddress
	ld a,(bos.current_sectors_per_cluster)
	ld bc,0
	ld c,a
	ld de,0
.dest_fd:=$-3
	push hl,bc,de
	call fat_WriteSectors
	pop bc,bc,bc
	pop hl
	inc hl
	jr .write_file_loop
.finished:
	ld bc,(.source_fd)
	push bc
	call fat_Close
	pop bc
	ld hl,str_Finished
	jq main_print_and_exit

