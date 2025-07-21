
; routines for accessing program arguments

syscalllib "argv", 0
	export osrt.argv_0, "0"
	export osrt.argv_1, "1"
	export osrt.argv_2, "2"
	export osrt.argv_3, "3"
	export osrt.argv_4, "4"
	export osrt.argv_a, "a"
	export osrt.argv_fail, "fail"

osrt.argv_4:
	ld a,4
	jr osrt.argv_a
osrt.argv_3:
	ld a,3
osrt.argv_a:
	ld e,a
	call osrt.get_args
	cp a,e
	jr c,osrt.argv_fail
	push bc
	ld b,3
	ld c,e
	mlt bc
	ld hl,(ix+9)
	add hl,bc
	pop bc
	jr osrt.load_hl_ind_hl
osrt.argv_2:
	call osrt.get_args
	cp a,2
	jr c,osrt.argv_fail
	inc hl
	inc hl
	inc hl
	jr osrt._inc_hl_3
osrt.argv_1:
	call osrt.get_args
	or a,a
	jr z,osrt.argv_fail
osrt._inc_hl_3:
	inc hl
	inc hl
	inc hl
	jr osrt.load_hl_ind_hl
osrt.argv_0:
	ld hl,(ix+9)
osrt.load_hl_ind_hl:
	ld hl,(hl)
	ret

osrt.get_args:
	ld bc,(ix+6)
	ld hl,(ix+9)
	ld a,c
	ret

osrt.argv_fail:
	ld sp,ix
	pop ix
	ld hl,osrt.str_NotEnoughArguments
	call bos.gui_PrintLine
	ld a,20
	jp ti.DelayTenTimesAms

osrt.str_NotEnoughArguments:
	db "Not enough arguments.",0

end syscalllib