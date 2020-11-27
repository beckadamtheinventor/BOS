;@DOES write a given data pointer to the swap sector at a given offset
;@INPUT void *sys_ToSwapSector(int dest_offset, void *data, int len);
;@OUTPUT pointer to swap sector
sys_ToSwapSector:
	ret

