;@DOES compare two memory pointers
;@INPUT HL,DE pointers to compare
;@INPUT BC number of bytes to compare
;@OUTPUT Z flag set if success
sys_MemCmp:
memcmp:
	ld a,(de)
	inc de
	cpi
	ret nz
	jp pe,memcmp
	xor a,a
	dec a
	ret

