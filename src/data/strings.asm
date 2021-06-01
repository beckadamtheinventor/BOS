
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
str_CmdExecutable:
	db "/bin/cmd",0
str_StartupProgram:
	db "/bin/boot",0
fs_cluster_map_file:
	db "/dev/cmap.dat",0
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
	db $9,"Press del to uninstall BOS",$A,0
string_press_enter_confirm:
	db "Press enter to confirm.",$A,0
string_program_requested_flash:
	db "Error: Unauthorized flash unlock!",$A
	db "Program requested flash unlock without elevation.",$A
	db "Aborting program execution.",$A
	db "Press any key to continue.",$A,0

string_os_elevation_file:
	db "/",$F2,"OS/ELEVATED",0
string_path_variable:
	db "/var/PATH",0

