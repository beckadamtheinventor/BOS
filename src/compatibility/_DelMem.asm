;@DOES Delete memory from a ram file
;@INPUT hl = address to start deleting from, de = number of bytes to delete
;@OUTPUT bc = number of bytes deleted
_DelMem:
	ld bc,ti.userMem
	or a,a
	sbc hl,bc
	add hl,bc ; compare start >= usermem
	ret c ; fail if start < usermem
	push hl,de,hl
	add hl,de
	ld bc,end_of_usermem
	or a,a  ; compare start + len < end_of_usermem
	sbc hl,bc
	add hl,bc
	jr c,.within_usermem
	ex hl,de
	push bc ; if start + len >= end_of_usermem: len = end_of_usermem - start
	pop hl
	pop bc
	or a,a
	sbc hl,de ; end_of_usermem - start
	ex hl,de
	db $3E ; dummify next pop instruction
.within_usermem:
	pop hl
	push de,hl ; push len, dest {argde, arghl}
	add hl,de  ; src {arghl + argde}
	ex (sp),hl ; push src / pop dest
	push hl    ; push dest {arghl}
	call ti._memmove
	pop hl,de,bc
	; ld hl,(remaining_free_RAM)
	; add hl,bc
	; ld (remaining_free_RAM),hl
	pop hl,de
	push hl
	pop bc
	push bc
	or a,a
	sbc hl,hl
	sbc hl,bc
	call _UpdateVAT
	pop bc
	ret


