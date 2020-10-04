
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org $D1A881
	jq fexplore_main
	db "REX",0
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
	ld bc,0
	push bc,hl
	call bos.fs_GetClusterPtr
	pop bc,bc
	jq c,.notfound
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
;init USB
	ld bc, 1 shl 2 ;USB_USE_USB_AREA
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
	call bos.gui_DrawConsoleWindow
main_init_loop:
	di
	ld hl,ti.mpIntMask
	set ti.bIntOn,(hl)
	ei
	call usb_WaitForInterrupt
	add hl,bc
	or a,a
	sbc hl,bc
	jq nz,main_exit
	ld a,0
msd_inited:=$-1
	or a,a
	jq nz,init_explore_drive
	ld hl,(usb_device)
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.check_on_int
	ld hl,usb_device
	ld (hl),de
	ld bc,bos.usb_sector_buffer
	push bc,de,hl
	call msd_Init
	pop bc,bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	jq nz,.init_fail
	ld a,1
	ld (msd_inited),a
	ld hl,str_MsdInited
	jq .print_then_check_on_int
.init_fail:
	ld hl,str_FailedToInitMsd
.print_then_check_on_int:
	call bos.gui_Print
.check_on_int:
	ld hl,bos.prev_interrupt_status
	bit ti.bIntOn,(hl)
	jq z,main_init_loop
	jq main_exit
init_explore_drive:
	call init_fat_partition
	jq nz,.fail
	call init_fat_volume
	jq nz,.fail
	
	
.fail:
	ld hl,str_FailedToInitFat
	call bos.gui_Print
	jq main_init_start

init_fat_partition:
	ld bc,1
	push bc
	ld bc,bos.ScrapMem
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
	ld hl,str_FatInited
	call bos.gui_Print
	xor a,a
	sbc hl,hl
	ret


init_fat_volume:
	xor a,a
	ld bc,fat_volume_label
	ld (bc),a
	push bc
	ld bc,fat_device
	push bc
	call fat_GetVolumeLabel
	pop bc,bc
	add hl,bc
	or a,a
	sbc hl,bc
	ret

list_fat_dirs:
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
	ld bc,current_dir
	push bc
	ld bc,fat_device
	push bc
	call fat_DirList
	pop bc,bc,bc,bc,bc,bc
	ld bc,-1
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,.done_display
	ld iy,fat_dir_entries

.display_loop:
	add hl,bc
	or a,a
	sbc hl,bc
	ret z
	dec hl
	push hl,iy
	lea hl,iy
	call bos.gui_Print
	call bos.gui_NewLine
	pop iy,hl
	lea iy,iy+18
	jq .display_loop


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

;usb_error_t main_event_handler(usb_event_t event, void *event_data, usb_callback_data_t *callback_data);
main_event_handler:
	call ti._frameset0
	ld hl,str_EventTriggered
	call bos.gui_Print
	ld hl,(ix+6)
	or a,a
	sbc hl,de
	add hl,de
	jq z,.success
	ld a,l
	cp a, 1 ;USB_DEVICE_DISCONNECTED_EVENT
	jq z,.device_disconnected
	cp a, 2 ;USB_DEVICE_CONNECTED_EVENT
	jq z,.device_connected
	cp a, 4 ;USB_DEVICE_ENABLED_EVENT
	jq z,.device_enabled
	ld hl,str_MaybeUnhandled
.print_then_success:
	call bos.gui_Print
.success:
	pop ix
	or a,a
	sbc hl,hl
	ret
.device_enabled:
	ld hl,(ix+15)
	ld de,(ix+9)
	ld (hl),de
	ld (is_device_connected),a
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
	ld bc,msd_device
	push bc
	call msd_Deinit
	pop bc
	xor a,a
	sbc hl,hl
	ld (is_device_connected),a
	ex hl,de
	ld hl,(ix+15)
	ld (hl),de
	ld hl,str_DeviceDisconnected
	jq .print_then_success

msd_device:
usb_device:
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
	dl 0
	db 0
	dd 0
	dl 3 dup 0
	dd 8 dup 0
	dl 4 dup 0

fat_volume_label:
	db 18 dup 0

current_dir := bos.open_files_table

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
	db   "A:/LibLoad.v21",0
.len := $ - .
str_WaitingForDevice:
	db $9,"Waiting for device...",$A
	db "Please insert USB flash drive.",$A
	db "Press [on] to cancel",$A,0
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


