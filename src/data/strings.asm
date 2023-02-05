
; str_CheckingFilesystem:
	; db "Checking Filesystem for errors.",0
; str_Filesystem_Corrupt:
	; db "Filesystem is corrupted!",0
str_Formatting:
	db "Formatting...",0
str_ErasingSector:
	db "Erasing Sector: $",0
str_ErasedUserMemory:
	db "Erased user memory.",0
str_WritingFilesystem:
	db "Writing filesystem...",0
str_PressAnyKey:
	db "Press any key to continue...",0
str_BadInterrupt:
	db "Repeated interrupt restart",$A
	db "called by program.",$A,0
str_UnimplementedOSCall:
	db "Unimplemented OS routine called",$A
	db "by program.",$A,0
str_TerminateOrContinue:
	db "Press enter to terminate",$A," and return to OS.",$A
	db "Press clear to continue",$A," and ignore this error.",$A,0
str_Address0x:
	db "Address: 0x",0
str_Prompt:
	db ">",0
; string_FilesystemCorrupt:
	; db "Filesystem corrupted!",$A,"Filesystem will now be formatted.",$A,"Press enter to continue.",$A,0
; string_FilesystemReformatted:
	; db "Format complete.",$A,"Press enter to continue to BOS.",$A,0
str_BuildingVAT:
	db "Building VAT...",0
str_GarbageCollecting:
	db "Garbage collecting...",0
str_tivars_dir:
	db "/tivars/"
.len:=$-.
	db 0
str_HexChars:
	db "0123456789ABCDEF"
string_os_info:
	file 'buildno.txt'
	db 0
str_SplashCredit:
	db " Splash screen by LogicalJoe",0
string_os_recovery_menu:
	db "--OS Recovery/Reset--",$A
	db $9,"Press clear to reboot",$A
	db $9,"Press O/7 to turn off calculator",$A
	db $9,"Press enter to attempt recovery",$A
	; db $9,"Press 6/V to verify system files",$A
	db $9,"Press mode to reset filesystem",$A
	db $9,"Press del to uninstall BOS",$A
	db $9,"Press 2nd to try running cmd line",$A
	db $9,"Press alpha to open emergency shell",$A,0
string_press_enter_confirm:
	db "Press enter to confirm.",$A,0
str_ErrorOccurred:
	db "Error:",0
str_ErrorMemory:
	db "Not Enough Memory",0
str_ErrorUnimplemented:
	db "Feature is not yet implemented",0
str_ErrorDataType:
	db "Data Type",0
str_PressAnyKeyToSoftReboot:
	db "Press any key to soft reboot.",$A,0

; string_program_requested_flash:
	; db "Error: Unauthorized flash unlock!",$A
	; db "Program requested flash unlock without elevation.",$A
	; db "Aborting program execution.",$A
	; db "Press any key to continue.",$A,0
; string_failed_to_reinstall:
	; db "Failed to reinstall TIOS, backup files are missing!",$A,0


include 'root_partition.asm'
include 'root_dir_data.asm'

fs_root_file_initializers:
	db $14, "dev",0
	db $10, "etc",0
	db $10, "etc/fontlibc",0
	db $10, "home",0
	db $10, "opt",0
	db $10, "opt"
str_bin_dir:
	db "/bin",0
	db $10, "opt"
str_lib_dir:
	db "/lib",0
	db $10, "tivars",0
	db $10, "tmp",0
	db $10, "usr",0
	db $10, "usr/bin",0
	db $10, "usr/lib",0
	db $10
str_var_dir:
	db "/var",0

	db $00, "etc/fontlibc/DrMono",0
	dw fs_file_data_drmono.len
	dw fs_file_data_drmono.zlen
virtual
	file "adrive/src/fs/etc/fontlibc/DrMono.dat"
	fs_file_data_drmono.len := $-$$
end virtual
fs_file_data_drmono:
	file "adrive/obj/DrMono.zx7.dat"
fs_file_data_drmono.zlen:=$-.

	db $00, "opt/bin/cedit",0
	dw fs_file_data_cedit.len
	dw fs_file_data_cedit.zlen
virtual
	file "adrive/src/fs/bin/cedit/bosbin/CEDIT.bin"
	fs_file_data_cedit.len := $-$$
end virtual
fs_file_data_cedit:
	file "adrive/obj/cedit.zx7.bin"
fs_file_data_cedit.zlen:=$-.

	db $00, "opt/bin/msd",0
	dw fs_file_data_msd.len
	dw fs_file_data_msd.zlen
virtual
	file "adrive/src/fs/bin/msd/bosbin/MSD.bin"
	fs_file_data_msd.len := $-$$
end virtual
fs_file_data_msd:
	file "adrive/obj/msd.zx7.bin"
fs_file_data_msd.zlen:=$-.

	db $00, "opt/bin/srl",0
	dw fs_file_data_srl.len
	dw fs_file_data_srl.zlen
virtual
	file "adrive/src/fs/bin/serial/bosbin/serial.bin"
	fs_file_data_srl.len := $-$$
end virtual
fs_file_data_srl:
	file "adrive/obj/serial.zx7.bin"
fs_file_data_srl.zlen:=$-.

	db $00, "var/PATH",0
	dw fs_file_data_path.len
	dw fs_file_data_path.zlen
virtual
	file "adrive/obj/PATH.bin"
	fs_file_data_path.len := $-$$
end virtual
fs_file_data_path:
	file "adrive/obj/PATH.zx7.bin"
fs_file_data_path.zlen:=$-.

	db $00, "var/LIB",0
	dw fs_file_data_lib.len
	dw fs_file_data_lib.zlen
virtual
	file "adrive/obj/LIB.bin"
	fs_file_data_lib.len := $-$$
end virtual
fs_file_data_lib:
	file "adrive/obj/LIB.zx7.bin"
fs_file_data_lib.zlen:=$-.

	db $00, "var/TIVARS",0
	dw fs_file_data_tivars.len
	dw fs_file_data_tivars.zlen
virtual
	file "adrive/obj/TIVARS.bin"
	fs_file_data_tivars.len := $-$$
end virtual
fs_file_data_tivars:
	file "adrive/obj/TIVARS.zx7.bin"
fs_file_data_tivars.zlen:=$-.
	dw 0

; bosfs_filesystem_header:
	; db "bosfs512fs "
; .len:=$-.

; str_ValidatingOSFiles:
	; db "Validating OS files...",0
; str_VerificationFailed:
	; db "Verification failed for file: ",0
; string_os_elevation_file:
	; db "/",$F2,"OS/ELEVATED",0
str_AutoExtractOptFile:
	db "/EXTRACT.OPT",0
str_sbin_dir:
	db "sbin",0
str_var_tivars:
	db "/var/TIVARS",0
string_path_variable:
	db "/var/PATH",0
string_lib_var:
	db "/var/LIB",0
string_var_dir:
	db "/var/",0
str_var_index_name:
	db "/tmp/cache"
.num:
	db "000.dat",0
str_ram_fs_device:
	db "/dev/ramfs",0
str_ExtractingFiles:
	db "Extracting files:",0
str_ExtractingOSBinaries:
	db "Extracting OS binaries...",0
str_ExtractingUpdates:
	db "Extracting Updates...",0
str_BootFailed:
	db "Boot has encountered a critical error",$A
	db "and cannot complete boot process.",$A
	db "Missing system executable /bin/explorer",$A
	db "Press any key to open recovery options.",$A,0
str_CmdExecutableNotFound:
	db "Could not locate system executable "
str_CmdExecutable:
	db "/bin/cmd",0
str_ExplorerExecutable:
	db "/bin/explorer",0
str_EtcConfigDir:
	db "/etc/config",0
str_EtcConfigBootDir:
	db "/etc/config/boot",0
str_CmdContinueExecutable:
	db "/bin/@cmd",0
str_CmdArguments:
	db "-x " ;flow into next string for efficiency
str_BootConfigFile:
	db "/etc/config/boot/onboot.cmd",0
str_HomeDir:
	db "/home",0

string_EZF_header:
	db $7F, "EZF"
.len:=$-.

str_onbootconfig:
	db "#programs to run on boot",$A
	db $A
	db "#main ui",$A
	db "explorer",$A
.len:=$-.

; _sha256_state_init:
	; dl 648807
	; db 106
	; dl 6794885
	; db -69
	; dl 7271282
	; db 60
	; dl 5240122
	; db -91
	; dl 938623
	; db 81
	; dl 354444
	; db -101
	; dl -8136277
	; db 31
	; dl -2044647
	; db 91

; _sha256_k:
	; dd	1116352408
	; dd	1899447441
	; dd	3049323471
	; dd	3921009573
	; dd	961987163
	; dd	1508970993
	; dd	2453635748
	; dd	2870763221
	; dd	3624381080
	; dd	310598401
	; dd	607225278
	; dd	1426881987
	; dd	1925078388
	; dd	2162078206
	; dd	2614888103
	; dd	3248222580
	; dd	3835390401
	; dd	4022224774
	; dd	264347078
	; dd	604807628
	; dd	770255983
	; dd	1249150122
	; dd	1555081692
	; dd	1996064986
	; dd	2554220882
	; dd	2821834349
	; dd	2952996808
	; dd	3210313671
	; dd	3336571891
	; dd	3584528711
	; dd	113926993
	; dd	338241895
	; dd	666307205
	; dd	773529912
	; dd	1294757372
	; dd	1396182291
	; dd	1695183700
	; dd	1986661051
	; dd	2177026350
	; dd	2456956037
	; dd	2730485921
	; dd	2820302411
	; dd	3259730800
	; dd	3345764771
	; dd	3516065817
	; dd	3600352804
	; dd	4094571909
	; dd	275423344
	; dd	430227734
	; dd	506948616
	; dd	659060556
	; dd	883997877
	; dd	958139571
	; dd	1322822218
	; dd	1537002063
	; dd	1747873779
	; dd	1955562222
	; dd	2024104815
	; dd	2227730452
	; dd	2361852424
	; dd	2428436474
	; dd	2756734187
	; dd	3204031479
	; dd	3329325298

BOS_B_width := 38
BOS_B_height := 41
BOS_B_size := 110
BOS_B_compressed:
	db	$26,$21,$29,$e3,$b4,$00,$00,$64,$00,$12,$c7,$27,$c3,$15,$f0,$26,$bc,$37,$7c,$25,$35,$26,$0d,$a0,$12,$e3,$67,$25,$8f,$26,$81,$ae
	db	$25,$06,$60,$e3,$8f,$24,$83,$92,$c7,$82,$23,$93,$82,$c4,$86,$b8,$17,$24,$ac,$48,$5e,$25,$78,$0d,$2f,$ab,$44,$e3,$3e,$8d,$50,$58
	db	$fb,$30,$26,$1c,$b9,$f0,$15,$fb,$a5,$40,$94,$25,$e3,$83,$f8,$25,$12,$c1,$97,$e3,$05,$d0,$25,$7e,$a1,$50,$e2,$c3,$a1,$e3,$f3,$92
	db	$87,$d2,$f9,$08,$66,$fc,$1f,$c7,$a8,$2b,$00,$80,$00,$40

BOS_O_width := 43
BOS_O_height := 42
BOS_O_size := 114
BOS_O_compressed:
	db	$2b,$23,$2a,$00,$91,$00,$e3,$31,$00,$f0,$1a,$bc,$27,$3b,$2e,$3c,$1e,$7c,$0d,$3d,$28,$0d,$cf,$2c,$17,$0f,$c1,$13,$5c,$15,$14,$a1
	db	$6b,$e3,$f4,$2a,$e3,$3f,$29,$08,$a0,$1a,$e3,$ca,$2a,$1c,$94,$28,$7f,$54,$00,$83,$3f,$2a,$1d,$0b,$81,$7a,$2a,$1f,$ec,$38,$15,$50
	db	$2a,$e3,$1a,$a8,$2a,$00,$0b,$58,$2a,$7c,$ae,$f8,$00,$1f,$20,$2a,$b9,$86,$a0,$ad,$87,$e1,$a8,$2a,$f8,$19,$2b,$88,$88,$62,$de,$10
	db	$e3,$10,$93,$ca,$0f,$8c,$ed,$14,$5c,$e3,$3f,$27,$04,$03,$e4,$00,$00,$80

BOS_S_width := 28
BOS_S_height := 43
BOS_S_size := 131
BOS_S_compressed:
	db	$1c,$20,$2b,$00,$89,$00,$e3,$11,$00,$3c,$10,$23,$19,$3f,$1d,$05,$17,$19,$0a,$4f,$3f,$09,$1d,$43,$1f,$35,$1f,$47,$1f,$1a,$3c,$12
	db	$29,$36,$70,$14,$d5,$1b,$dc,$15,$04,$18,$54,$1b,$17,$68,$b1,$42,$e8,$1b,$e3,$6e,$1b,$3e,$1c,$78,$1b,$66,$74,$19,$1d,$46,$e3,$c3
	db	$00,$71,$1b,$e3,$d9,$1f,$00,$07,$28,$1c,$e3,$3f,$1c,$83,$e0,$91,$84,$20,$1d,$a4,$a3,$63,$e0,$1d,$ac,$fb,$63,$21,$1d,$f5,$b7,$87
	db	$e0,$1c,$c2,$1b,$0c,$d0,$38,$00,$d0,$e3,$43,$2b,$c6,$0b,$24,$f3,$f0,$10,$b9,$e8,$4f,$08,$19,$1e,$19,$0a,$0c,$8c,$e2,$7c,$4b,$5c
	db	$5c,$00,$02

BOS_B := safeRAM ; D05200
BOS_O := BOS_B + (BOS_B_width * BOS_B_height) + 2 + 1
BOS_S := BOS_O + (BOS_O_width * BOS_O_height) + 2 + 1

str_ecks:
	db	"eck's",0
str_perate:
	db	'perating',0
str_ystem:
	db	'ystem',0

str_Zero:
	db '0',0

str_EmergencyShellInfo:
	db "available commands:",$A
	db "extract.[all|os|opt|rot]",$A
	db "format",$A
	; db "flock/funlock",$A
	; db "  lock/unlock flash",$A
	; db "secclear hex",$A
	; db "  erase flash sector",$A
	db 0

; unfortunately this needs to be 512 byte aligned
	db $200 - ($ and $1FF) dup $FF
fs_fs $
emergency_shell_fs:
	fs_sfentry emergency_shell_files, "emshell", "fs", (1 shl fd_subfile) or (1 shl fd_subdir)
	db $FF
fs_subfile emergency_shell_files, emergency_shell_fs
	fs_sfentry emergency_extractall, "extract", "all", 1 shl fd_subfile
	fs_sfentry emergency_extractos, "extract", "os", 1 shl fd_subfile
	fs_sfentry emergency_extractopt, "extract", "opt", 1 shl fd_subfile
	fs_sfentry emergency_extractroot, "extract", "rot", 1 shl fd_subfile
	; fs_sfentry emergency_flashlock, "flock", "", 1 shl fd_subfile
	; fs_sfentry emergency_flashunlock, "funlock", "", 1 shl fd_subfile
	; fs_sfentry emergency_eraseflashsector, "secclear", "", 1 shl fd_subfile
	db $FF
end fs_subfile

fs_subfile emergency_extractall, emergency_shell_fs
	jr emergency_extractall.main
	db "FEX",0
emergency_extractall.main:
	call fs_ExtractOSBinaries.silent
	call fs_ExtractRootDir
	jp fs_ExtractOSOptBinaries
end fs_subfile

fs_subfile emergency_extractos, emergency_shell_fs
	jp fs_ExtractOSBinaries.silent
	db "FEX",0
end fs_subfile

fs_subfile emergency_extractopt, emergency_shell_fs
	jp fs_ExtractOSOptBinaries
	db "FEX",0
end fs_subfile

fs_subfile emergency_extractroot, emergency_shell_fs
	jp fs_ExtractRootDir
	db "FEX",0
end fs_subfile

; fs_subfile emergency_flashunlock, emergency_shell_fs
	; db $18,$04,"FEX",0
	; jp sys_FlashUnlock
; end fs_subfile

; fs_subfile emergency_flashlock, emergency_shell_fs
	; db $18,$04,"FEX",0
	; jp sys_FlashLock
; end fs_subfile

; fs_subfile emergency_eraseflashsector, emergency_shell_fs
	; db $18,$04,"FEX",0
	; pop bc,de,hl
	; push hl,de,bc
	; dec e
	; dec e
	; ret nz
	; inc hl
	; inc hl
	; inc hl
	; ld de,(hl)
	; call str_HexToInt.entry
	; ld a,l
	; jq sys_EraseFlashSector
; end fs_subfile
end fs_fs
