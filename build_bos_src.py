
import os,sys

def build_bos_src():
	d = os.path.dirname(__file__)
	with open(os.path.join(d, "bos.inc")) as f:
		data = f.read().splitlines()
	publics = []
	defines = []
	asm_routines = [
		"gui_DrawConsoleWindow",
		"gui_Print",
		"gui_PrintChar",
		"gui_PrintString",
		"gui_PrintLine",
		"gui_PrintInt",
		"gfx_PrintString",
		"gfx_SetTextPos",
	]
	for line in data:
		if line.startswith("?"):
			if any([line.startswith("?"+r) for r in asm_routines]):
				publics.append("asm_"+line[1:line.find(" ")])
				defines.append("asm_"+line[1:])
			else:
				publics.append(line[1:line.find(" ")])
				defines.append(line[1:])
		elif line.startswith("; end of jump table"):
			break
	with open(os.path.join(d, "bos.src"),"w") as f:
		f.write("\n; BOS jump table functions\n")
		for line in publics:
			line = line.replace("gfx_", "bosgfx_")
			f.write(f"\tpublic _{line}\n")
		for line in defines:
			line = line.replace("gfx_", "bosgfx_")
			f.write(f"_{line}\n")
		f.write("""
public ram_executable
public ram_executable_at
public flash_executable

macro ram_executable?
	ram_executable_at ti.userMem
end macro

macro ram_executable_at? addr
	org addr
	db $18,$04,"REX",$00
end macro

macro flash_executable?
	local fex_prog
	element fex_prog
	virtual at fex_prog+0
		fex_prog:
		db $18,$04,"FEX",$00

		macro call? addr
			if addr relativeto fex_prog
				rst $28
			end if
			call addr-fex_prog
		end macro
		macro jp? addr
			if addr relativeto fex_prog
				rst $28
			end if
			jp addr-fex_prog
		end macro
		macro ld? lhs, rhs
			match (addr), lhs
				if addr relativeto fex_prog
					rst $28
					ld (addr-fex_prog), rhs
				else
					ld (addr), rhs
				end if
			else match (addr), rhs
				if addr relativeto fex_prog
					rst $28
					ld lhs, (addr-fex_prog)
				else
					ld lhs, (addr)
				end if
			else
				if rhs relativeto fex_prog
					rst $28
					ld lhs, rhs-fex_prog
				else
					ld lhs, rhs
				end if
			end match
		end macro
	postpone
		load fex_prog.data: $-$$ from $$
		end virtual
		db fex_prog.data
	end postpone
end macro
""")



if __name__=='__main__':
	build_bos_src()
