
;@DOES return a pointer to the data section of a given drive letter
;@INPUT a = drive letter
;@OUTPUT hl = drive data section. hl = -1 if failed.
;@OUTPUT Cf is set if failed.
fs_DataSection:
	call fs_ClusterMap
	jq c,.fail
	ld bc,$2000
	add hl,bc      ; add cluster tables
	xor a,a
	ret
.fail:
	scf
	sbc hl,hl
	ret

