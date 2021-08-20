;@DOES grab variable name from string
;@INPUT char *sys_GrabVarName(const char *str);
;@OUTPUT hl pointer to character following var name, a = character following var name
sys_GrabVarName:
	ld a,(hl)
	jq .entry
.next:
	inc hl
.loop:
	ld a,(hl)
	or a,a
	ret z
	cp a,'0'
	ret c
	cp a,'9'+1
	jq c,.next
.entry:
	cp a,'_'
	jq z,.next
	res 4,a
	cp a,'A'
	ret c
	cp a,'Z'+1
	jq c,.next
	ret
