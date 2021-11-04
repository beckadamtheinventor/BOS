
fs_filesystem_root_address := $040000
fs_filesystem_address := fs_filesystem_root_address

fsbit_readonly       := 0
fsbit_hidden         := 1
fsbit_system         := 2
fsbit_subfile        := 3 ;file is a sub-file. Contents are at (fsentry&0x1FF) + *fsentry_filesector
fsbit_subdirectory   := 4
fsbit_device         := 5
fsbit_elevated       := 7

;fsentry_endofdir     := $00
;fsentry_dot          := $2E
;fsentry_deleted      := $F0
;fsentry_longfilename := $F1
;fsentry_endofdir2    := $FF

;fsentry_filename            := $00
;fsentry_filename.len        := 8
;fsentry_fileext             := $08
;fsentry_fileext.len         := 3
;fsentry_fileattr            := $0B
;fsentry_fileattr.len        := 1
;fsentry_filesector          := $0C
;fsentry_filesector.len      := 2
;fsentry_filelen             := $0E
;fsentry_filelen.len         := 2


f_readonly      := 1
f_hidden        := 2
f_system        := 4
f_subfile       := 8
f_subdir        := $10
f_device        := $20
f_elevated      := $80
