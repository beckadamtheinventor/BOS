;@DOES flash the swap sector
;@INPUT void sys_EraseSwapSector(void);
sys_EraseSwapSector:
	ld a,'B'
	call fs_PartitionDescriptor
	ld bc,8
	add hl,bc
	ld hl,(hl)
	add hl,hl
	ld a,h
	jq sys_EraseFlashSector

