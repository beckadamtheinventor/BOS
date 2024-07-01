
include 'include/ti84pceg.inc'
include 'include/ez80.inc'
include 'include/tiformat.inc'
format ti executable 'BOSOS'

include 'include/os.inc'
include 'include/defines.inc'
include 'include/bos.inc'

os_rom
	file '../obj/bosos.bin'
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
	ld hl,reinstaller_2_header + reinstaller_2_header.len-2
	ld (hl),e
	inc hl
	ld (hl),d
	ld hl,backup_tios_query
	call _printline
.waitkey:
	call ti.GetCSC
	cp a,ti.skLog
	jq z,do_installation
	cp a,ti.sk1
	jr nz,.waitkey
backup_tios:
	ld hl,($020104+1)
	ld bc,$020000+$104-$020000 ; installer backup minus OS size computed from jump location
	add hl,bc
	ld bc,$3B0000-fs_os_backup_location
	or a,a
	sbc hl,bc
	jr c,.continue
	ld hl,failed_to_backup_os_string
	call _printline
	ld hl,continue_anyways_string
	call _printline
.waitkey:
	call ti.GetCSC
	cp a,ti.sk1
	jq z,do_installation
	cp a,ti.skLog
	jr nz,.waitkey
	ret
.continue:
	ld hl,backingup_os_string
	call _printline
	ld a,1
	ld (backup_os_flag),a
	ld a,bos.fs_os_backup_location shr 16
	ld (_final_sector_smc),a
do_installation:
	ld hl,installing_string
	call _printline
	; create the OS and erase user flash.
	; user flash end location is $3B0000,
	; unless backing up TIOS in which case the end location is $300000
	os_create $3B

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
backup_tios_query:
	db "Back up TIOS? Y/N",0
missing_secondary_str:
	db "Missing AppVar BOSOSpt2",0
backingup_os_string:
	db "Backing up TIOS &",0
failed_to_backup_os_string:
	db "OS too large to backup",0
continue_anyways_string:
	db "Continue anyways?",0

reinstaller_header:
	db $f0,$fc,$2c,$d9,$06,$00,$00,$01,$00,$0c,$05,$42,$4f,$53,$4f,$53
	dw installer_size
	db $EF,$7B
.len := $-.

reinstaller_2_header:
	db $f0,$fc,$c1,$87,$15,$00,$00,$01,$00,$0d,$08,$42,$4f,$53,$4f,$53,$70,$74,$32,$00,$00
.len := $-.

; installation_failed_string:
	; db "Need more ARC. Aborting.",0
; install_info_string:
	; db "Please run a Garbage",0
	; db "Collect then re-run the",0
	; db "installer.",0

; tios_backup_file:
	; db ti.AppVarObj,"TIOSbkpA",0

write_os_binary

installer_size := $+2-$D1A881
