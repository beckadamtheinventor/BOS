
str_CheckingFilesystem:
	db "Checking Filesystem for errors.",$A,0
str_Filesystem_Corrupt:
	db "Filesystem is corrupted!",$A,0
str_Formatting:
	db "Formatting...",$A,0
str_ErasingSector:
	db "Erasing Sector: $",0
str_ErasedUserMemory:
	db "Erased user memory.",$A,0
str_WritingFilesystem:
	db "Writing filesystem...",$A,0
str_PressAnyKey:
	db "Press any key to continue...",$A,0
str_Prompt:
	db ">",0
string_FilesystemCorrupt:
	db "Filesystem corrupted!",$A,"Filesystem will now be formatted.",$A,"Press enter to continue.",$A,0
string_FilesystemReformatted:
	db "Format complete.",$A,"Press enter to continue to BOS.",$A,0
str_tivars_dir:
	db "/usr/tivars/"
.len:=$-.
str_HexChars:
	db "0123456789ABCDEF"
string_os_info:
	file 'buildno.txt'
	db 0
string_os_recovery_menu:
	db "--OS Recovery/Reset--",$A
	db $9,"Press clear to reboot",$A
	db $9,"Press 2nd to turn off calculator",$A
	db $9,"Press enter to attempt recovery",$A
	db $9,"Press mode to reset filesystem",$A
	db $9,"Press del to uninstall BOS",$A
	db $9,"Press apps to reinstall TIOS",$A,0
string_press_enter_confirm:
	db "Press enter to confirm.",$A,0
string_program_requested_flash:
	db "Error: Unauthorized flash unlock!",$A
	db "Program requested flash unlock without elevation.",$A
	db "Aborting program execution.",$A
	db "Press any key to continue.",$A,0
string_failed_to_reinstall:
	db "Failed to reinstall TIOS, backup files are missing!",$A,0

; bosfs_filesystem_header:
	; db "bosfs512fs "
; .len:=$-.

string_os_elevation_file:
	db "/",$F2,"OS/ELEVATED",0
string_path_variable:
	db "/var/PATH",0
string_lib_var:
	db "/var/LIB",0
string_var_dir:
	db "/var/",0
str_var_index_name:
	db "/var/cache"
.num:
	db "000.dat",0
str_Booting:
	db "Starting up...",$A,0
str_BootFailed:
	db "Boot has encountered a critical error",$A
	db "and cannot complete boot process.",$A
	db "Missing system executable /bin/explorer",$A
	db "Press any key to open recovery options.",$A,0
str_CmdExecutable:
	db "/bin/cmd",0
str_ExplorerExecutable:
	db "/bin/explorer",0
; str_ClusterMapFile:
	; db "/dev/cmap.dat",0
str_EtcConfigDir:
	db "/etc/config",0
str_EtcConfigBootDir:
	db "/etc/config/boot",0
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
	db	'eck''s',0
str_perate:
	db	'perating',0
str_ystem:
	db	'ystem',0

str_Loading:
	db	'Loading...',0
