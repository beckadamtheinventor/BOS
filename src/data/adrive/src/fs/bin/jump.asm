
	jr jump_main
	db "FEX",0
jump_main:
    call ti._frameset0
    call osrt.argv_1
    push hl
    call osrt.hexstr_to_int
    pop bc
    jp (hl)
