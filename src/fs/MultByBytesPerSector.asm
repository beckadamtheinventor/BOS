;@DOES multiply by the number of bytes per sector
;@INPUT HL = number
;@OUTPUT HL*=fs_sector_size
;@DESTROYS BC,DE,AF
fs_MultByBytesPerSector:
	ld b,fs_sector_size_bits
.loop:
	add hl,hl
	djnz .loop
	ret
