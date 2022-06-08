#!/usr/bin/python3
from os import path

def error(e):
	print("Something went wrong!")
	print("Error:",e)
	quit()

def myhex(n):
	return hex(n).replace("0x","").upper()

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

macro flash_executable?
	virtual at $01000000
		db $18,$04,"FEX",$00
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
			if `opcode = "call" | `opcode = "jp" | `opcode = "jq" | `opcode = "ld"
				match lhs=,rhs, args
					match (val), lhs
						if val relativeto $$ & val >= $$
							rst $28
							opcode (0), rhs
							store val - $ : 3 at $ - 3
						else
							opcode (val), rhs
						end if
					else match (val), rhs
						if val relativeto $$ & val >= $$
							rst $28
							opcode lhs, (0)
							store val - $ : 3 at $ - 3
						else
							opcode lhs, (val)
						end if
					else if rhs relativeto $$ & rhs >= $$
						rst $28
						opcode lhs, 0
						store rhs - $ : 3 at $ - 3
					else
						opcode lhs, rhs
					end if
				else match opcode= lhs, line
					match (val), lhs
						opcode lhs
					else if lhs relativeto $$ & lhs >= $$
						rst $28
						opcode 0
						store lhs - $ : 3 at $ - 3
					else
						opcode lhs
					end if
				else
					opcode lhs,rhs
				end match
			else
				opcode args
			end if
		else
			line
		end match
	end macro
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
