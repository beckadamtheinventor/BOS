
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org $D1A881
	; jq fexplore_main
	; db "REX",0
fexplore_main:
	ld (_ErrSP),sp
	call libload_load
	jq z,fexplore_main.main
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
fexplore_main.main:
	pop bc,hl
	push hl,bc
	ld (current_dir),hl
	ld hl,str_DriveExplorer
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
	ld hl,main_exit_cleanup
	call bos.sys_SetupOnInterruptHandler
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
	jq nz,.init_fat_fail
	call init_fat_volume
	jq z,fexplore_explore_files
.init_fat_fail:
	ld hl,str_FailedToInitFat
.print_and_exit:
	call bos.gui_Print
	call bos.sys_WaitKeyCycle
	jq main_exit

main_fail_memory:
	ld hl,str_MemoryError

main_print_and_exit:
	call bos.gui_Print
;Cleanup USB
main_exit:
	ld bc,msd_device
	push bc
	call msd_Deinit
	ld hl,usb_device
	ex (sp),hl
	call usb_DisableDevice
	pop bc
main_exit_cleanup:
	call usb_Cleanup
	ld hl,ti.mpIntAck
	set ti.bIntOn,(hl)
	jq _exit



reset_smc_bytes:
	ld a,$01 ;ld bc,...
	ld (main_msd_Init),a
	ld a,$0E ;ld c,...
	ld (init_fat_partition),a
	ld a,$AF ;xor a,a
	ld (init_fat_volume),a
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
str_NoParitions:
	db "No Partitions found.",$A,0
str_LookingForPartitions:
	db "Looking for partitions...",$A,0
str_InitializingPartition:
	db "Initializing partition...",$A,0
found_partitions:
	dl 0


init_fat_volume:
	xor a,a
	ld bc,fat_volume_label
	ld (bc),a
	push bc
	ld bc,fat_device
	push bc
	call fat_GetVolumeLabel
	pop bc,bc
	ld a,$C9
	ld (.),a
	add hl,bc
	or a,a
	sbc hl,bc
	ret

list_fat_dirs:
	ld hl,0
current_dir:=$-3
	call bos.gui_DrawConsoleWindow
	ld hl,1
	call .entry
	or a,a
	sbc hl,hl
.entry:
	ld bc,0
dir_skip:=$-3
	push bc
	ld bc,16
	push bc
	ld bc,fat_dir_entries
	push bc
	push hl
	ld bc,(current_dir)
	push bc
	ld bc,fat_device
	push bc
	call fat_DirList
	pop bc,bc,bc,bc,bc,bc

	ld iy,fat_dir_entries
	ld hl,16

.display_loop:
	ld a,(iy)
	or a,a
	ret z
	dec hl
	add hl,bc
	or a,a
	sbc hl,bc
	ret z
	dec hl
	push hl,iy
	bit 4,(iy+13)
	ld hl,str_DirEntryStr
	jq nz,.display_print
	ld hl,str_FileEntryStr
.display_print:
	call bos.gui_Print
	lea hl,iy
	call bos.gui_Print
	call bos.gui_NewLine
	pop iy,hl
	lea iy,iy+18
	jq .display_loop

str_FileEntryStr:
	db $9,0
str_DirEntryStr:
	db $9,"/",0

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

fat_dir_entries:
	db 18*8 dup 0


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
	db   "/lib/LibLoad.dll",0
.len := $ - .
str_DriveExplorer:
	db "FAT32 Flash Drive explorer",$A,0
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
str_MaybeUnhandled:
	db "Maybe unhandled event?",$A,0
str_EventTriggered:
	db "Event Triggered.",$A,0
str_DeviceEnabled:
	db "Device Enabled.",$A,0
str_NotYetImplemented:
	db $9,"This program is not fully implemented.",$A,0
str_NoArguments:
	db $9,"Usage: FEXPLORE mode file",$A,0
str_FileNotFound:
	db $9,"File not found.",$A,0
str_MemoryError:
	db $9,"Not Enough Memory.",$A,0

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
usb_DisableDevice:
	jp 42

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
fat_DirList:
	jp 33
fat_GetVolumeLabel:
	jp 36
fat_Open:
	jp 39
fat_Close:
	jp 42
fat_SetSize:
	jp 45
fat_GetSize:
	jp 48
fat_SetAttrib:
	jp 51
fat_GetAttrib:
	jp 54
fat_SetFilePos:
	jp 57
fat_GetFilePos:
	jp 60
fat_ReadSectors:
	jp 63
fat_WriteSectors:
	jp 66
fat_Create:
	jp 69
fat_Delete:
	jp 72

	xor   a,a      ; return z (loaded)
	pop   hl      ; pop error return
	ret

fexplore_explore_files:
	call list_fat_dirs
.key_loop:
	call bos.sys_WaitKeyCycle
	or a,a
	jq z,.key_loop
	cp a,15
	jq z,main_exit
	jq fexplore_explore_files



