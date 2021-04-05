
include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/tiformat.inc'

include 'include/os.inc'
include 'include/defines.inc'
include 'include/bos.inc'

org ti.userMem-2

os_rom
	file '../obj/bosos.bin'
end os_rom

	db $EF,$7B
updater_start:
	call bos._ClrScrn
	call bos._HomeUp
	ld hl,installing_string
	call bos._PutS

	os_create $03 ;erase only OS sectors as to not clobber the filesystem.

installing_string:
	db "Updating BOS...",0

write_os_binary

