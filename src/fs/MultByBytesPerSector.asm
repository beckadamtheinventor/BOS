;@DOES multiply by the number of bytes per sector
;@INPUT HL = number
;@OUTPUT HL*=256
;@DESTROYS BC,DE,AF
fs_MultByBytesPerSector:
	ld b,8
.loop:
	add hl,hl
	djnz .loop
	ret
