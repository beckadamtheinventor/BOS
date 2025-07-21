#!/usr/bin/python3
from os import path

def error(e):
	print("Something went wrong!")
	print("Error:",e)
	quit()

def myhex(n):
	return hex(n)[2:].upper()

try:
	with open(path.join(path.dirname(__file__), "src", "table.asm")) as f:
		data=f.read().splitlines()
except Exception as e:
	error(e)
try:
	with open(path.join(path.dirname(__file__), "src", "include", "defines.inc")) as f:
		defines=f.read().splitlines()
except Exception as e:
	error(e)
try:
	with open(path.join(path.dirname(__file__), "src", "include", "boot_calls.inc")) as f:
		bootcalls=f.read()
except Exception as e:
	error(e)

def build_bos_inc():
	counter=0x020108

	with open(path.join(path.dirname(__file__), "bos.inc"),"w") as f:
		f.write("""

;-------------------------------------------------------------------------------
; Executable formats
;-------------------------------------------------------------------------------
macro ram_executable?
	ram_executable_at ti.userMem
end macro

macro ram_executable_at? addr
	org addr
	db $18,$04,"REX",$00
end macro

macro flash_executable? header:1
	local flashexecbase
	element flashexecbase
	virtual at flashexecbase
		if header = 1
			db $18,$04,"FEX",$00
		end if
	macro end?.flash_executable?
		purge ?
		purge end?.flash_executable?
		local prgmdata, prgmlen
		prgmlen := $-$$
		load prgmdata: $-$$ from $$
		end virtual
		db prgmdata
	end macro
	macro ? line&
		match opcode= args, line
			if `opcode = "call" | `opcode = "jp" | `opcode = "jq" | `opcode = "ld" | `opcode = "syscall"
				match lhs=,rhs, args
					match (val), lhs
						if val relativeto flashexecbase
							rst $28
							opcode (0), rhs
							store val - $ : 3 at $ - 3
						else
							opcode (val), rhs
						end if
					else match (val), rhs
						if val relativeto flashexecbase
							rst $28
							opcode lhs, (0)
							store val - $ : 3 at $ - 3
						else
							opcode lhs, (val)
						end if
					else if rhs relativeto flashexecbase
						rst $28
						opcode lhs, 0
						store rhs - $ : 3 at $ - 3
					else
						opcode lhs, rhs
					end if
				else match opcode= lhs, line
					match (val), lhs
						opcode lhs
					else if lhs relativeto flashexecbase
						rst $28
						opcode 0
						store lhs - $ : 3 at $ - 3
					else
						opcode lhs
					end if
				else
					opcode lhs,rhs
				end match
			else if args relativeto flashexecbase
				opcode args - flashexecbase
			else
				opcode args
			end if
		else
			line
		end match
	end macro
end macro

;-------------------------------------------------------------------------------
; Syscall instruction macro
;-------------------------------------------------------------------------------
; lbl should point to a string containing the syscall path
; example:
;	syscall gfx_PrintString
;	...
;	gfx_PrintString:
;		db "gfx/PrintString",0
macro syscall? lbl
	rst $18
	dl lbl - 3 - $
end macro

;-------------------------------------------------------------------------------
; Syscall library macro
;-------------------------------------------------------------------------------
macro syscalllib? sclname, relocations:1
	local exports, header, symbols
	local flashexecbase, file_base
	file_base = $
	if relocations = 1
		element flashexecbase
	else
		flashexecbase = 0
	end if
	db "SCL",0
	virtual at $
		exports.area::
	end virtual
	if ~defined NO_SYSCALL_HEADERS
		virtual as "h"
			header.area::
		end virtual
		virtual as "src"
			symbols.area::
		end virtual
	end if
	virtual at flashexecbase + exports.end
	macro export_data? data, name, hname:0, hdef&
		virtual exports.area
			db 3
			dw data - file_base - flashexecbase
			db name, 0
		end virtual
		if ~defined NO_SYSCALL_HEADERS & ~hname eq 0
			virtual header.area
				db hdef
				db $A
			end virtual
		end if
	end macro
	macro export_ptr? routine, name, hname:0, hdef&
		virtual exports.area
			db 7
			dl routine
			db name, 0
		end virtual
		if ~defined NO_SYSCALL_HEADERS & ~hname eq 0
			virtual header.area
				db hdef
				db $A
			end virtual
			virtual symbols.area
				db "public _", hname,$A
				db '_',hname,' := syscall "',sclname,'/',name,'"',$A
			end virtual
		end if
	end macro
	macro export? routine, name, hname:0, hdef&
		virtual exports.area
			db 9
			dw routine - file_base - flashexecbase
			db name, 0
		end virtual
		if ~defined NO_SYSCALL_HEADERS & ~hname eq 0
			virtual header.area
				db hdef
				db $A
			end virtual
			virtual symbols.area
				db "public _", hname,$A
				db '_',hname,' := syscall "',sclname,'/',name,'"',$A
			end virtual
		end if
	end macro
	macro ram_routine? routine, ramloc
		routine.ramroutine:
		routine.dataloc:
		virtual at ramloc
		macro end?.ram_routine?
			routine.len := $-$$
			load routine.data: $-$$ from $$
			end virtual
			dw routine.len
			dl ramloc
			db routine.data
			purge end?.ram_routine?
		end macro
	end macro
	macro data_block?
		local data
		virtual
		macro end?.data_block?
			data.len := $-$$
			load data.data: $-$$ from $$
			end virtual
			dw data.len
			db data.data
			purge end?.data_block?
		end macro
	end macro
	macro end?.syscalllib?
		load exports.code: $-$$ from $$
		end virtual
		virtual exports.area
			db 0
			exports.end = $
			load exports.data: $-$$ from $$
		end virtual
		db exports.data
		db exports.code
		restore call?
		restore jp?
		restore jq?
		restore ld?
		restore syscall?
		restore end?.syscalllib?
	end macro
	if relocations = 1
		iterate opcode, call,jp,jq,ld,syscall
			macro opcode? args&
				match lhs=,rhs, args
					match (val), lhs
						if val relativeto flashexecbase
							rst $28
							opcode (0), rhs
							store val - $ : 3 at $ - 3
						else
							opcode (val), rhs
						end if
					else match (val), rhs
						if val relativeto flashexecbase
							rst $28
							opcode lhs, (0)
							store val - $ : 3 at $ - 3
						else
							opcode lhs, (val)
						end if
					else if rhs relativeto flashexecbase
						rst $28
						opcode lhs, 0
						store rhs - $ : 3 at $ - 3
					else
						opcode lhs, rhs
					end if
				else match opcode= lhs, line
					match (val), lhs
						opcode lhs
					else if lhs relativeto flashexecbase
						rst $28
						opcode 0
						store lhs - $ : 3 at $ - 3
					else
						opcode lhs
					end if
				else if args relativeto flashexecbase
					opcode args - flashexecbase
				else
					opcode args
				end if
			end macro
		end iterate
	end if
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

;-------------------------------------------------------------------------------
; Device macros
;-------------------------------------------------------------------------------

macro device_file? flags, type, version, intsource
	virtual
	db $C9, flags, type, version, intsource, 0, 0, 0
	repeat 11
		or a,a
		sbc hl,hl
		ret
	end repeat
	macro export? jumpno, function
		if function > 0
			store $C3: byte at $$+jumpno
			store function: 3 at $$+jumpno+1
		end if
	end macro
	macro end?.device_file?
		local data
		load data: $-$$ from $$
		end virtual
		db data
		purge export?
	end macro
end macro

;-------------------------------------------------------------------------------
; OS call defines
;-------------------------------------------------------------------------------
define bos? bos
namespace bos
; jump table
	""")
		for line in data:
			if line.startswith(";$=$"):
				counter = int(line[4:], 16)
			elif "jp " in line:
				line=line[line.find("jp ")+3:]
				if ";" in line:
					line=line.split(';')[0].strip("\t ")
				if line=="DONOTHING":
					f.write(";DONOTHING                       := $"+myhex(counter)+"\n")
				else:
					f.write("?"+line.ljust(32," ")+(":= $"+myhex(counter))+"\n")
				counter+=4
			elif "call " in line:
				line=line[line.find("call ")+5:]
				if ";" in line:
					line=line.split(';')[0].strip("\t ")
				if line=="DONOTHING":
					f.write(";DONOTHING                       := $"+myhex(counter)+"\n")
				else:
					f.write("?"+line.ljust(32," ")+(":= $"+myhex(counter))+"\n")
				counter+=4
			else:
				if not line.startswith(";"):
					f.write(";")
				f.write(line+"\n")
		f.write(""";-------------------------------------------------------------------------------
; OS memory areas and misc defines
;-------------------------------------------------------------------------------
""")
		for line in defines:
			if len(line):
				o=ord(line[0])
				if o in range(0x41,0x5B) or o in range(0x61,0x7B):
					f.write("?"+line+"\n")
		f.write("\nend namespace")

if __name__=='__main__':
	build_bos_inc()
