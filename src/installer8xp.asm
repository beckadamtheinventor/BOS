
include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/tiformat.inc'
format ti executable 'BOSOS'

include 'include/os.inc'
include 'include/defines.inc'

os_rom
	file '../obj/bosos.bin'
end os_rom

INSTALLER8XP := 1

	di
	call ti.RunIndicOff
	call ti.ClrLCD
	call ti.HomeUp
	ld hl,backup_tios_querry
	call _printline
waitkey:
	call ti.GetCSC
	cp a,ti.skLog
	jq z,do_installation
	cp a,ti.sk1
	jq nz,waitkey

backup_tios:
	call ti.ArcChk ; get free archive space
	ld hl,(ti.OSSize+1)
	ld de,$010000 - $020000 ; get os size in bytes, add 64k to the total
	add hl,de
	ld de,(ti.tempFreeArc) ; check if we have enough space
	or a,a
	sbc hl,de
	jq nc,installation_fail
	add hl,de
	push hl

	ld hl,backingup_os_string
	call _printline
	ld hl,$020000
	ld (backup_write_counter),hl
	pop hl
backup_tios_loop:
	push hl
	ld hl,tios_backup_file
	call ti.Mov9ToOP1
	ld hl,$FE00
	ld a,ti.AppVarObj
	call ti.CreateVar
	inc de
	inc de
	ld hl,0
backup_write_counter:=$-3
	ld bc,$FE00
	ldir
	ld (backup_write_counter),hl
	ld hl,tios_backup_file
	call ti.Mov9ToOP1
	call ti.Arc_Unarc ;archive the backup file
	ld hl,tios_backup_file+8 ;next backup file name
	inc (hl)
	pop hl
	ld bc,$FE00
	or a,a
	sbc hl,bc
	jq nc,backup_tios_loop
	jq do_installation
installation_fail:
	ld hl,installation_failed_string
	call _printline
	jp ti.RunIndicOn
_printline:
	call ti.PutS
	jp ti.NewLine
do_installation:
	ld hl,installing_string
	call _printline
	os_create $05 ;erase up until sector $05 to erase OS sectors and trigger BOS to format/convert the filesystem.

installing_string:
	db "Installing BOS...",0
backup_tios_querry:
	db "Back up TIOS? Y/N",0
backingup_os_string:
	db "Backing up TIOS...",0
installation_failed_string:
	db "Need more ARC. Aborting.",0
install_info_string:
	db "Please run a Garbage",0
	db "Collect then re-run the",0
	db "installer.",0

tios_backup_file:
	db ti.AppVarObj,"TIOSbkpA",0

write_os_binary
