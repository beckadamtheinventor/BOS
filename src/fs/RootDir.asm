
;@DOES return root directory descriptor for a given drive letter
;@INPUT A = Partition label / drive letter
;@OUTPUT hl = root directory descriptor
;@OUTPUT Cf is set if label/letter is invalid, or if drive is broken or invalid.
fs_RootDir:
	call fs_ClusterMap
	ret c
	ld bc,$2000 ; add two 8-sector FATs
	add hl,bc   ; cluster map address + FAT sectors size
	ex hl,de
	ld b,5     ; root dir first cluster *= 32
.multloop2:
	add hl,hl
	djnz .multloop2
	add hl,de   ; get data section cluster from root dir cluster
	ret
