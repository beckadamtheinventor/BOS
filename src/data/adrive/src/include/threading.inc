;-------------------------------------------------------------------------------
; Software-level multithreading commands
;-------------------------------------------------------------------------------

; macro DisableMultithreading?
	; rst $10
	; db $00
; end macro

; macro EnableMultiThreading?
;	rst $10
;	db $F7
; end macro

macro StopAllThreads?
	rst $10
	db $76
end macro

macro EndThread?
	rst $10
	db $C9
end macro

macro SpawnThread? start_pc, start_sp
	rst $10
	db $C5
	dl start_sp
	dl start_pc
end macro

macro HandleNextThread?
	rst $10
	db $C1
end macro

macro SetExitThread? start_pc
	rst $10
	db $FF
	dl start_pc
end macro
