;@DOES Convert a 32-bit unsigned integer to a string
;@INPUT char* str_LongToHexStr(char* dest, uint32_t num);
;@OUTPUT pointer to dest
str_LongToHexStr:
	call ti._frameset0
	lea hl,ix+9
	ld de,(ix+6)
	ld b,4
    jq str_IntToHexStr.entry_b
