;@DOES convert the lower 4 bits of the accumulator to a hex character.
;@INPUT A nibble. (upper 4 bits are ignored)
;@OUTPUT A hex character.
str_Nibble:
	and a,$F
	add a,'0'
	cp a,'0'+10
	ret c
	add a,'A'-'0'-10
	ret
