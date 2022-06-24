
; routines for accessing program arguments

_osrt_argv_so:
	dd 2
	jp osrt.argv_0
	jp osrt.argv_1
	jp osrt.argv_2
	jp osrt.argv_3
	jp osrt.argv_4
	jp osrt.argv_a
	jp osrt.argv_fail

virtual
	db "osrt.argv_0 rb 4", $A
	db "osrt.argv_1 rb 4", $A
	db "osrt.argv_2 rb 4", $A
	db "osrt.argv_3 rb 4", $A
	db "osrt.argv_4 rb 4", $A
	db "osrt.argv_a rb 4", $A
	db "osrt.argv_fail rb 4", $A
	load _routines_osrt_argv_so: $-$$ from $$
end virtual

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
	ld c,a
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
