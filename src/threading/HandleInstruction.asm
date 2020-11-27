
threading_HandleInstruction:
	ex (sp),hl
	ld a,(hl)
	push hl
	or a,a
	jq z,DisableThreading
	cp a,$76
	jq z,StopAllThreads
	cp a,$F7
	jq z,EnableThreading
	pop hl
	ex (sp),hl
	ret

EnableThreading:
	ld hl,mpTmrCtrl      ;enable thread timer
	set bTmr1IntOverflow,(hl)
	set bTmr1Enable,(hl)
	ld hl,threads_all_flags
	res bthreads_perm_disabled,(hl)
	pop hl
	ex (sp),hl
	ret

DisableThreading:
	ld hl,mpTmrCtrl      ;disable thread timer
	res bTmr1Enable,(hl)
	res bTmr1IntOverflow,(hl)
	ld hl,threads_all_flags
	set bthreads_perm_disabled,(hl)
	pop hl
	ex (sp),hl
	ret

StopAllThreads:
	ld hl,thread_signal_handlers
	ld b,0
.loop:
	ld de,(hl)
	inc hl
	inc hl
	inc hl
	ld a,sig_stop
	call .callde
	or a,a
	ld a,sig_kill
	call nz,.callde
	djnz .loop

	pop hl
	ex (sp),hl
	ret
.callde:
	push bc,hl,de
	ex hl,de
	call .jphl
	pop de,hl,bc
	ret
.jphl:
	jp (hl)


