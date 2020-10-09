;@DOES create a file
;@INPUT bool fs_CreateFile(char *path);
;@DESTROYS All
fs_CreateFile:
.path_pointer := ix+6
.path_len := ix-3
.cwd_len := ix-6
.path_buffer := ix-9
.path_last_entry := ix-12
.path_last_entry_offset := ix-15
.saved_fd := ix-18
.drive_letter := ix-19
.cluser_map := ix-22
.end_of_cluster_map := ix-25
.temp_area := ix-41
.file_dest_ptr := ix-44
.file_src_ptr := ix-47
.cluster_size := ix-50
.flags := ix-51
	ld hl,-51
	call ti._frameset
	xor a,a
	ld (.flags),a
	ld hl,(ix+6)
	inc hl
	ld a,(hl)
	dec hl
	cp a,':'
	jq z,.absolute_path
	push hl,hl
	call ti._strlen
	ld (.path_len),hl
	ex (sp),hl
	ld hl,current_working_dir
	push hl
	call ti._strlen
	ld (.cwd_len),hl
	ex (sp),hl
	pop bc
	pop hl
	add hl,bc
	push hl
	call sys_Malloc
	pop bc
	ex hl,de
	pop hl
	jq c,.fail
	ld (.path_buffer),de
	push hl
	ld hl,current_working_dir
	ld bc,(.cwd_len)
	ldir
	pop hl
	ld bc,(.path_len)
	ldir
	ld hl,(.path_buffer)
.absolute_path:
	push hl
	call fs_OpenFile
	pop hl
	jq nc,.fail ;if file exists, don't create new one
	push hl
	call ti._strlen
	ex (sp),hl
	pop bc
	push hl
	ld a,'/'
	cpir
	pop de
	jq z,.fail
.create:
	ld (.path_last_entry),hl ;&path[ last path entry ]
	xor a,a
	sbc hl,de
	ld (.path_last_entry_offset),hl ;last path entry offset from path
	dec hl
	ld (hl),a
	ex hl,de
	push hl
	call fs_OpenFile ;open directory
	pop bc
	jq c,.fail
	ld (.saved_fd),hl ;void *fd
	call fs_DriveLetterFromPtr
	jq c,.fail
	ld (.drive_letter),a
	call sys_EraseSwapSector
	ld a,(.drive_letter)
	call fs_DataSection
	ld (.file_src_ptr),hl
	ex.s hl,de
	ld (.file_dest_ptr),de
	ld a,(current_sectors_per_cluster)
	or a,a
	sbc hl,hl
	ld l,a
	ld b,9
.mult_loop:
	add hl,hl
	djnz .mult_loop
	ld (.cluster_size),hl
	ld a,(.drive_letter)
	call fs_DrivePtr
	push hl
	ld bc,$24
	add hl,bc
	ld hl,(hl)
	add hl,hl
	add hl,hl
	dec hl
	dec hl
	dec hl
	dec hl
;hl = end of cluster map
	ld (.end_of_cluster_map),hl
	pop hl
	push hl
	ex.s hl,de ;de = cluster_map&0xFFFF
	ld hl,12 ;minimum number of clusters to copy
	add hl,de
	;hl = minimum number of clusters in cluster map to copy + offset of cluster map
	ex (sp),hl ;data source
	push hl
	ex.s hl,de ;de = data source & 0xFFFF
	pop hl
	or a,a
	sbc hl,de
	ex hl,de   ;de = data source & 0xFF0000
	pop hl ;number of clusters to copy
	ld bc,0 ;offset to write inside swap sector
	push bc,hl,de
	call sys_ToSwapSector
	ex hl,de
	res 0,(.flags)
	pop hl,bc,af
.copy_clusters_loop:
	bit 0,(.flags) ;check if we are writing trailing clusters
	jq nz,.write_file_cluster
	ld a,(hl)
	cp a,$FF
	jq nz,.write_file_cluster
	push hl
	inc hl
	ld hl,(hl)
	ld bc,$FFFFFF
	or a,a
	sbc hl,bc
	pop hl
	jq z,.write_file_cluster
	ld bc,(.end_of_cluster_map) ;if the last cluster is not free, there's no free clusters.
	or a,a
	sbc hl,bc
	add hl,bc
	jq nz,.next
	bit 0,(.flags) ;check if we are trying to find free space
	jq z,.fail ;we are, and there is none
	ld a,(.drive_letter)
	call fs_DataSection
	ld (.file_src_ptr),hl
	pea .file_src_ptr+2
	call sys_FromSwapSector
	pop bc
.success:
	xor a,a
	db $01 ;dummify next 3 bytes
.fail:
	scf
	sbc hl,hl
.exit:
	pop ix
	ret
.next:
	ld bc,4
	push bc,hl,de
	call sys_ToSwapSector
	ld de,(.file_dest_ptr)
	ld hl,(.file_src_ptr)
	ld bc,(.cluster_size)
	push de,hl,bc
	ex hl,de
	ld bc,$010000
	sbc hl,bc
	call c,sys_ToSwapSector ;only write if in range
	pop bc,de,hl
	add hl,bc
	ex hl,de
	add hl,bc
	ld (.file_dest_ptr),de
	ld (.file_src_ptr),hl
	ld (.cluster_size),bc
	pop bc,hl,de
	add hl,bc
	ex hl,de
	add hl,bc
	jq .copy_clusters_loop
.write_file_cluster:
	lea hl,.temp_area
	push hl,de
	ld b,4
.write_temp_cluster_loop:
	ld (hl),$FF
	inc hl
	djnz .write_temp_cluster_loop
	ld bc,4
	push bc
	call sys_ToSwapSector
	pop bc,hl,de
	add hl,bc
	ex hl,de
	set 0,(.flags)
	jq .copy_clusters_loop
