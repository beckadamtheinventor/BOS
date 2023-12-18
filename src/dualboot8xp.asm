
include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/tiformat.inc'
format ti executable 'BOSOS'

include 'include/os.inc'
include 'include/defines.inc'

os_rom
	file '../obj/bosos_dualboot.bin'
end os_rom

INSTALLER8XP := 1

	di
	call ti.RunIndicOff
	call ti.ClrLCD
	call ti.HomeUp
	ld iy,ti.flags
	ld hl,second_binary_appvar
	call ti.Mov9ToOP1
	call ti.ChkFindSym
	jq c,fail_missing_secondary
	call ti.ChkInRam
	ex de,hl
	jr z,secondary_in_ram
	ld de,9
	add	hl,de
	ld e,(hl)
	add	hl,de
	inc	hl
secondary_in_ram:
	call ti.LoadDEInd_s
	ld (os_second_binary),hl
	ld (os_second_binary.len),de
	; ld hl,backup_tios_querry
	; call _printline
; waitkey:
	; call ti.GetCSC
	; cp a,ti.sk1
	; jq z,backup_tios
	; cp a,ti.skLog
	; jq nz,waitkey
	; xor a,a
; backup_tios:
	; ld (backup_tios_flag),a
	; call ti.ArcChk ; get free archive space
	; ld hl,(ti.OSSize+1)
	; ld de,$010000 - $020000 ; get os size in bytes, add 64k to the total
	; add hl,de
	; ld de,(ti.tempFreeArc) ; check if we have enough space
	; or a,a
	; sbc hl,de
	; jq nc,installation_fail
	; add hl,de
	; push hl

	; ld hl,backingup_os_string
	; call _printline
	; ld hl,$020000
	; ld (backup_write_counter),hl
	; pop hl
; backup_tios_loop:
	; push hl
	; ld hl,tios_backup_file
	; call ti.Mov9ToOP1
	; ld hl,$FE00
	; ld a,ti.AppVarObj
	; call ti.CreateVar
	; inc de
	; inc de
	; ld hl,0
; backup_write_counter:=$-3
	; ld bc,$FE00
	; ldir
	; ld (backup_write_counter),hl
	; ld hl,tios_backup_file
	; call ti.Mov9ToOP1
	; call ti.Arc_Unarc ;archive the backup file
	; ld hl,tios_backup_file+8 ;next backup file name
	; inc (hl)
	; pop hl
	; ld bc,$FE00
	; or a,a
	; sbc hl,bc
	; jq nc,backup_tios_loop
	; jq do_installation
; installation_fail:
	; ld hl,installation_failed_string
	; call _printline
	; jp ti.RunIndicOn
do_installation:
	ld hl,installing_string
	call _printline
	os_create $3B ;erase all user flash sectors
	rst 0

fail_missing_secondary:
	ld hl,missing_secondary_str
	call _printline
	jp ti.RunIndicOn

_printline:
	call ti.PutS
	jp ti.NewLine

second_binary_appvar:
	db ti.AppVarObj,"BOSOSpt2"
installing_string:
	db "Installing BOS...",0
; backup_tios_querry:
	; db "Back up TIOS? Y/N",0
missing_secondary_str:
	db "Missing AppVar BOSOSpt2",0
; backingup_os_string:
	; db "Backing up TIOS...",0
; installation_failed_string:
	; db "Need more ARC. Aborting.",0
; install_info_string:
	; db "Please run a Garbage",0
	; db "Collect then re-run the",0
	; db "installer.",0

; tios_backup_file:
	; db ti.AppVarObj,"TIOSbkpA",0

write_os_binary
