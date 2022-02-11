;@DOES Locks flash
sys_FlashLock:
flash_lock:
	push af
	xor	a,a
	out0	($28),a
	in0	a,($06)
	res	2,a
	out0	($06),a
	ld	a,$88
	out0	($24),a
	pop af
	ret
