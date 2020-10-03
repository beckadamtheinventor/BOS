
include 'include/ez80.inc'
include 'include/ti84pceg.inc'
include 'include/bos.inc'

org ti.userMem
	jr fexplore_main
	db "REX",0
fexplore_main:
	ld (_ErrSP),sp
	call libload_load
	jr z,.main
	ld hl,str_FailedToLoadLibload
	call bos.gui_Print
	scf
	sbc hl,hl
	ret
.main:
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
	ld hl,str_WaitingForDevice
	call bos.gui_DrawConsoleWindow
main_explore_loop:
	call bos.sys_GetKey
	cp a,15
	jr z,.exit
	call usb_HandleEvents
	ld a,0
is_device_connected:=$-1
	or a,a
	jr z,main_explore_loop
	cp a,1
	jq z,_fat_Find
	cp a,2
	jq z,_fat_List
	
	
	jr main_explore_loop
;Cleanup USB
.exit:
	ld bc,msd_device
	push bc
	call msd_Deinit
	pop bc
	call usb_Cleanup
	jq _exit
_fat_List:
	xor a,a
	ld bc,fat_volume_label
	ld (bc),a
	push bc
	ld bc,fat_device
	push bc
	call fat_GetVolumeLabel
	pop bc,bc
	ld bc,0
dir_skip:=$-3
	push bc
	ld bc,16
	push bc
	ld bc,fat_dir_entries
	push bc
	ld bc,0
	push bc
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
	jq z,main_explore_loop
	ld iy,fat_dir_entries
.display_loop:
	add hl,bc
	or a,a
	sbc hl,bc
	jq z,main_explore_loop
	dec hl
	push hl,iy
	call bos.gui_Print
	call bos.gui_NewLine
	pop iy,hl
	lea iy,iy+18
	jr .display_loop
_fat_Find:
	ld bc,1
	push bc
	ld bc,.thrown_away_value
.thrown_away_value:=$-3
	push bc
	ld bc,partition_descriptor
	push bc
	ld bc,msd_device
	push bc
	call fat_Find
	pop bc,bc,bc,bc
	ld a,2
	ld (is_device_connected),a
	add hl,bc
	or a,a
	sbc hl,bc
	ld hl,str_FailedToLocatePartition
	call nz,bos.gui_Print
	jq main_explore_loop


;usb_error_t main_event_handler(usb_event_t event, void *event_data, usb_callback_data_t *callback_data);
main_event_handler:
	call ti._frameset0
	ld de,(ix+6)
	ld hl, 2 ;USB_DEVICE_CONNECTED_EVENT
	or a,a
	sbc hl,de
	jr z,.device_connected
	ld hl, 1 ;USB_DEVICE_DISCONNECTED_EVENT
	or a,a
	sbc hl,de
	jr z,.device_disconnected
.success:
	pop ix
	or a,a
	sbc hl,hl
	ret
.device_connected:
	ld de,(ix+9)
	ld hl,usb_device
	ld (hl),de
	ld a,1
	ld (is_device_connected),a
	ld bc,bos.usb_sector_buffer
	push bc,de,hl
	call msd_Init
	pop bc,bc,bc
	jq .success
.device_disconnected:
	ld bc,msd_device
	push bc
	call msd_Deinit
	pop bc
	pop ix
	xor a,a
	ld (is_device_connected),a
	sbc hl,hl
	ld (usb_device),hl
	ret

msd_device:
usb_device:
	dl 0       ;usb_device_t dev
	db 0       ;uint8_t bulk in addr
	db 0       ;uint8_t bulk out addr
	db 0       ;uint8_t configindex
	dl 0       ;uint24_t tag
	dd 0       ;uint32_t LBA of LUN
	dd 512     ;uint32_t block size
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
	ret

str_WaitingForDevice:
	db $9,"Waiting for device...",$A
	db "Please insert USB flash drive.",$A,0
str_FailedToLocatePartition:
	db $9,"Failed to locate any partitions.",$A
	db "Are you sure this is a FAT32 formatted drive?",$A,0

libload_load:
	ld hl,libload_name
	push hl
	call bos.fs_OpenFile
	pop bc
	jr c,.notfound
	ld bc,0
	push bc,hl
	call bos.fs_GetClusterPtr
	pop bc,bc
	ld   de,.relocations
	ld   bc,.notfound
	push   bc
	ld   bc,$aa55aa
	jp   (hl)

.notfound:
	xor   a,a
	inc   a
	ret

.relocations:
db $C0,"USBDRVCE",0,0
usb_Init:
	jp 0
usb_Cleanup:
	jp 3
usb_HandleEvents:
	jp 9

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

libload_name:
	db   "A:/LibLoad.v21", 0
.len := $ - .

str_HelloWorld:
	db "Hello World!",0
str_FailedToLoadLibload:
	db "Failed to load libload.",0

