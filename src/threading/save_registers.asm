
thread_save_registers:
	ld (threads_temp_save),iy
	push bc
	ld iy,thread_registersaves
	ld bc,(thread_current)
	add iy,bc
	ld bc,(threads_temp_save)
	ld (iy),bc
	pop bc
	ld (iy+3),ix
	ld (iy+6),bc
	ld (iy+9),de
	ld (iy+12),hl
	ld (iy+15),ix
	ld (iy+18),af
	ld (iy+21),sp
	ld hl,(threads_temp_save)
	ld (iy),hl
	push hl
	pop iy
	ret

