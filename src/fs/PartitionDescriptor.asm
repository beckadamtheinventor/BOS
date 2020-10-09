

fs_PartitionDescriptor:
	cp a,'A'
	jq c,.notaletter
	sub a,'A'-1
.notaletter:
	or a,a
	jq z,.fail
	cp a,5
	jq nc,.fail
	add a,a
	add a,a
	add a,a
	add a,a
	ld hl,fs_drive_a + fs_partition_1 - 16
	jp sys_AddHLAndA
.fail:
	scf
	ret
