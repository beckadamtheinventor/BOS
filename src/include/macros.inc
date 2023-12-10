;-------------------------------------------------------------------------------
; Call/jump to currently running program at offset
;-------------------------------------------------------------------------------
macro OffsetInstruction? instruction*
	rst $28
	instruction
end macro

;-------------------------------------------------------------------------------
; Software threading instructions
;-------------------------------------------------------------------------------
macro EnableThreading?
	rst $10
	nop
end macro

macro EnableOSThreading?
	rst $10
	rst $28
end macro

macro DisableThreading?
	rst $10
	rst $38
end macro

macro SleepThread?
	rst $10
	halt
end macro

macro WakeThread?
	rst $10
	rst $20
end macro

macro EndThread?
	rst $10
	ret
end macro

macro SpawnThread? start_pc, start_sp
	rst $10
	push bc
	dl start_sp
	dl start_pc
end macro

macro HandleNextThread?
	rst $10
	pop bc
end macro

macro HandleNextThread_IfOSThreading?
	rst $10
	rst $30
end macro

; TBD: not implemented yet
; config loading and data structure macros/defines
macro bosconfig? name
	tByte?    := 1
	tWord?    := 2
	tInt?     := 3
	tLong?    := 4
	tString?  := 5
	tFloat?   := 6
	tArray?   := 64
	tSigned?  := 128
	tSInt?    := tSigned or tInt
	tByteArray?    := tArray or tByte
	tWordArray?    := tArray or tWord
	tIntArray?     := tArray or tInt
	tLongArray?    := tArray or tLong
	tStringArray?  := tArray or tString
	tFloatArray?   := tArray or tFloat
	tSIntArray?    := tArray or tSigned or tInt
	macro entry? type, name, ptr
		db type, `name, 0
		dl ptr
	end macro
	macro end?.bosconfig?
		purge entry?
		purge tByte?
		purge tWord?
		purge tLong?
		purge tString?
		purge tFloat?
		purge tArray?
		purge tByteArray?
		purge tWordArray?
		purge tIntArray?
		purge tLongArray?
		purge tStringArray?
		purge tFloatArray?
	end macro
end macro
macro loadbosconfig? name, fname
	local _str
	local _jumploc
	ld hl,_str
	ld de,cmd_config_data_struct
	push de,hl
	syscall _loadConfigFile
	pop bc,bc
	jq _jumploc
	db fname, 0
_jumploc:
end macro
