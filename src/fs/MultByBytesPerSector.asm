;@DOES multiply by the number of bytes per sector
;@INPUT HL = number
;@OUTPUT HL*=512
;@DESTROYS BC,DE,AF
fs_MultByBytesPerSector:
	ld b,9
.loop:
	add hl,hl
	djnz .loop
	ret
