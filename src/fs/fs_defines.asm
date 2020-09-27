
fs_drive_a := $040000 ; filesystem boot partition. 256kb area.
fs_drive_a_sector := $04

fs_drive_b := $080000 ; used as a scrap sector. 128kb area.
fs_drive_b_sector := $08

fs_drive_c := $0A0000 ; user filesystem. Variable size area. Default is ~4Mib
fs_drive_c_sector := $0A


fs_partition_1 := $1BE
fs_partition_2 := $1CE
fs_partition_3 := $1DE
fs_partition_4 := $1EE

fs_boot_magic_1 := $1FE
fs_boot_magic_2 := $1FF


fsbit_readonly       := 0
fsbit_hidden         := 1
fsbit_system         := 2
fsbit_volumeid       := 3 ;file name is volume ID
fsbit_subdirectory   := 4
fsbit_archive        := 5 ;has been changed since last backup

fsentry_avalible     := $00
fsentry_E5           := $05
fsentry_dot          := $2E
fsentry_deleted      := $E5

fsentry_filename         := $00
fsentry_filename.len     := 8
fsentry_fileext          := $08
fsentry_fileext.len      := 3
fsentry_fileattr         := $0B
fsentry_fileattr.len     := 1
fsentry_creationtime     := $0E
fsentry_creationtime.len := 2
fsentry_creationdate     := $10
fsentry_creationdate.len := 2
fsentry_highcluster      := $14
fsentry_highcluster.len  := 2
fsentry_lowcluster       := $1A
fsentry_lowcluster.len   := 2
fsentry_filesize         := $1C
fsentry_filesize.len     := 4
