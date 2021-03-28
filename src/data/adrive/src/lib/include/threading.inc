;-------------------------------------------------------------------------------
; Software-level multithreading commands
;-------------------------------------------------------------------------------

macro DisableMultithreading?
	rst $10
	db $00
end macro

;disabled for now
macro EnableMultiThreading?
;	rst $10
;	db $F7
end macro

macro StopAllThreads?
	rst $10
	db $76
end macro

macro EndThread?
	rst $10
	ret
end macro

macro SpawnThread? start_pc, start_sp
	rst $18
	dl start_sp
	dl start_pc
end macro






