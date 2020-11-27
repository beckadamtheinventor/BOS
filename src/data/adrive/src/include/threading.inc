;-------------------------------------------------------------------------------
; Software-level multithreading commands
;-------------------------------------------------------------------------------

macro DisableMultithreading?
	rst $10
	db $00
end macro

macro EnableMultiThreading?
	rst $10
	db $F7
end macro

macro StopAllThreads?
	rst $10
	db $76
end macro

macro StartThread? resource_flags:0
	rst $10
	db $3E
	db resource_flags
end macro


macro PauseThread
	rst $10
	db $FF
end macro

macro ResumeThread
	rst $10
	db $F7
end macro

macro SysCall? routine
	if routine >= $020108
		rst $18
		dl routine
	end if
end macro




