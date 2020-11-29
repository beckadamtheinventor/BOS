
str_CheckingFilesystem:
	db "Checking Filesystem for errors.",$A,0
str_Filesystem_Corrupt:
	db "Filesystem is corrupted!",$A,0
str_Formatting:
	db "Formatting...",$A,0
str_ErasingSector:
	db "Erasing Sector ",0
str_ErasedUserMemory:
	db "Erased user memory.",$A,0
str_WritingFilesystem:
	db "Writing filesystem...",$A,0
str_PressAnyKey:
	db "Press any key to continue...",$A,0
str_Prompt:
	db ">",$A,0
str_CmdExecutable:
	db "/bin/cmd"
str_dotEXE:
	db ".exe",0
str_StartupProgram:
	db "/bin/boot.exe",0
fs_cluster_map_file:
	db "/dev/cmap.dat",0
string_FilesystemCorrupt:
	db "Filesystem corrupted!",$A,"Filesystem will now be formatted.",$A,"Press enter to continue.",$A,0
string_FilesystemReformatted:
	db "Format complete.",$A,"Press enter to continue to BOS.",$A,0


