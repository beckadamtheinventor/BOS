;@DOES write data to a file
;@INPUT int fs_Write(void *data, int len, uint8_t count, void *fd);
;@OUTPUT new file size. Returns -1 if failed to write
;@DESTROYS All. Assume OP4, OP5, OP6
fs_Write:
.file_old_len    :=  iy + fsentry_filesize
.write_data      :=  ix + 6
.write_len       :=  ix + 9
.write_count     :=  ix + 12
.write_fd        :=  ix + 15
.file_new_len    :=  fsOP4 + 0
.fd_old_offset   :=  fsOP4 + 3
.fd_new_offset   :=  fsOP4 + 6
.fd_head_offset  :=  fsOP4 + 9
.sector_buffer   :=  fsOP4 + 12
.swap_write_offset    :=  fsOP4 + 15
.number_of_clusters   :=  fsOP4 + 18
.current_cluster      :=  fsOP4 + 21
.file_first_cluster   :=  fsOP4 + 24
	call ti._frameset0
	push iy
	ld iy,(ix+15)
	bit f_readonly, (iy+fsentry_fileattr)
	jr nz,.fail
	ld hl,(iy+fsentry_filesize)
	ld bc,1024
	call ti._idivu
	ld (.number_of_clusters),hl
	ld bc,(ix+9) ;int len
	ld a,(ix+12) ;uint8_t count
.count_loop:
	add hl,bc
	dec a
	jr nz,.count_loop
	ld (.file_new_len),hl
	ld bc,1024
	push bc
	call sys_Malloc
	pop bc
	jq c,.fail
	ld (.sector_buffer),hl
	or a,a
	sbc hl,hl
	ld (.current_cluster),hl

	call sys_EraseSwapSector

;copy cluster section into swap sector
	lea hl,iy
	call fs_DriveLetterFromPtr
	call fs_DataSection
	push hl
	ld de,0
	ld e,l
	ld d,h
	push de
	ld hl,$010000
	sbc hl,de
	ex (sp),hl
	push hl
	call sys_ToSwapSector
	pop bc,bc,bc

	

.copy_loop: ;copy file data to swap sector
	ld bc,(.current_cluster)
	push bc,iy
	call fs_GetClusterPtr
	pop bc,iy
	inc bc
	ld (.current_cluster),bc
	ld bc,1024
	ld de,(.sector_buffer)
	push de,bc
	ldir
	pop bc,hl
	ld de,(.swap_write_offset)
	push de,bc,hl
	call sys_ToSwapSector
	pop bc,bc,bc
	ld hl,(.current_cluster)
	ld bc,(.number_of_clusters)
	or a,a
	sbc hl,bc
	jr c,.copy_loop
	
	
	jr .exit
.fail:
	scf
	sbc hl,hl
.exit:
	pop iy
	pop ix
	ret


