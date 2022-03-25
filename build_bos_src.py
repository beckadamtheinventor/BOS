
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
	local prgm, prgmdata, prgmlen, prgmend
	virtual at $01000000
		prgm:
		db $18,$04,"FEX",$00

		macro call? addr
			if addr >= prgm & addr < prgmend
				rst $28
			end if
			call addr and $FFFFFF
		end macro
		macro jp? addr
			if addr >= prgm & addr < prgmend
				rst $28
			end if
			jp addr and $FFFFFF
		end macro
		macro ld? lhs, rhs
			match (addr), lhs
				if addr >= prgm & addr < prgmend
					rst $28
				end if
				ld (addr and $FFFFFF), rhs
			else match (addr), rhs
				if addr >= prgm & addr < prgmend
					rst $28
				end if
				ld lhs, (addr and $FFFFFF)
			else
				if rhs >= prgm & rhs < prgmend
					rst $28
				end if
				ld lhs, rhs and $FFFFFF
			end match
		end macro
	postpone
		prgmend:
		prgmlen := $-$$
		load prgmdata: $-$$ from $$
		end virtual
		db prgmdata
	end postpone
end macro
""")



if __name__=='__main__':
	build_bos_src()
