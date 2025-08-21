
	jr jump_main
	db "FEX",0
jump_main:
	call ti._frameset0
	syscall _argv_1
	ld a,(hl)
	inc hl
	cp a,'$'
	jr z,.address
	cp a,'_'
	jr z,.namedaddress
	and a, not $20
	cp a,'A'
	jr c,.notnamedaddress
	cp a,'Z'+1
	jr c,.namedaddress
.notnamedaddress:
	dec hl
.address:
	push hl
	call bos.str_IntStrToInt
.jump:
	ld sp,ix
	pop ix
	jp (hl)

.namedaddress:
	ld hl,$F8
	jr .jump
