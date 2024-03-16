;@DOES Begin execution from begPC to endPC.
;@INPUT int32_t sys_ExecBegin(void);
;@OUTPUT process exit code. Returns Cf set if begPC >= endPC.
;@OUTPUT exit code also stored in bos.LastCommandResult
;@NOTE exit code is undefined if begPC >= endPC.
sys_ExecBegin:
	ld hl,(ti.begPC)
	ld (ti.curPC),hl
	ld de,(ti.endPC)
	or a,a
	sbc hl,de
	ccf
	ret c
	jq sys_ExecContinue
