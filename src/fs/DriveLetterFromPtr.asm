;@DOES return the drive letter a given pointer lies within
;@INPUT hl = pointer
;@OUTPUT A = drive letter. A = 0 if failed.
fs_DriveLetterFromPtr:
	ld l,0
	res 0,h
	push hl
	ld a,'A'
	call fs_PartitionDescriptor
	pop de
	push ix
	push hl
	pop ix
	ld c,4
.loop:
	ld hl,(ix+8) ;partition start LBA
	ld b,9 ;multiply by 512
.multloop1:
	add hl,hl
	djnz .multloop1
	or a,a
	sbc hl,de
	jr nc,.next
	ld hl,(ix+12) ;partition end LBA
	ld b,9 ;multiply by 512
.multloop2:
	add hl,hl
	djnz .multloop2
	or a,a
	sbc hl,de
	jr c,.next
.found:
	ld a,'E' ;return 0x45 - X where X is the remaining number of drive letters in the partition table
	sub a,c
	or a,a
	pop ix
	ret
.next:
	lea ix,ix+16 ;next partition entry
	dec c
	jr nz,.loop
	xor a,a  ;no drive letter found
	pop ix
	scf
	ret

