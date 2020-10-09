;@DOES find a free cluster in a given drive letter
;@OUTPUT hl points to cluster. Cf set and hl = -1 if failed.
sys_FindFreeCluster:
	push af
	call fs_ClusterMap
	pop af
	ret c
	push ix
	push af
	push hl
	pop ix
	xor a,a
	jr .loop
.next:
	lea ix,ix+4
.loop:
	cp a,(ix+3)
	jr nz,.next
	ld hl,(ix)
	or a,a
	add hl,bc
	sbc hl,bc
	jr nz,.next
.return:
	lea hl,ix
	ld b,8
.mult_loop:
	add hl,hl
	djnz .mult_loop
	pop af
	pop ix
	push hl
	call fs_DataSection
	pop bc
	add hl,bc
	ret
