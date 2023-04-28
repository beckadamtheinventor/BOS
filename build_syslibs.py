
import os, sys
from os.path import join, basename, dirname, abspath, isabs

def build_syscalls(path):
	with open(join(path, "src", "table.asm"), "r") as f:
		data = f.read().split("\n")

	o = {
		"str": [
			f"export_ptr bos.strupper, \"ToUpper\"",
			f"export_ptr bos.strlower, \"ToLower\"",
		]
	}
	for line in data:
		if "jp " in line and not line.startswith(";"):
			callname = line.split("jp ", maxsplit=1)[1].split(" ", maxsplit=1)[0]
			if callname.startswith("_"):
				lib = ""
				name = callname[1:]
			elif "_" in callname:
				lib, name = callname.split("_", maxsplit=1)
			else:
				continue
			if name[0].isupper():
				if lib not in o.keys():
					o[lib] = []
				o[lib].append(f"export_ptr bos.{lib}_{name}, \"{name}\"")

	for lib in o.keys():
		try:
			os.makedirs(join(path, "syslib"))
		except:
			pass
		if lib == "":
			ln = "_"
		else:
			ln = lib
		with open(join(path, "syslib", f"{ln}.asm"), "w") as f:
			f.write("include \"../src/include/ez80.inc\"\ninclude \"../src/include/ti84pceg.inc\"\ninclude \"../bos.inc\"\nsyscalllib\n" + "\n".join(o[lib]) + "\nend syscalllib")

if __name__=='__main__':
	build_syscalls(dirname(__file__))
