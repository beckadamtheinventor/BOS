
import os, sys
from os.path import join, basename, dirname, abspath, isabs

def valstr(v):
	if v.startswith("$"):
		return int(v[1:], 16)
	elif v.startswith("0x"):
		return int(v[2:], 16)
	elif v.startswith("%"):
		return int(v[1:], 2)
	elif v.startswith("0b"):
		return int(v[2:], 2)
	elif v.startswith("'"):
		if v.endswith("'"):
			return ord(v[1:-1])
		else:
			raise RuntimeError("Char value in single-quotes requires ending quote")
	elif v.startswith('"'):
		if '"' in v[1:]:
			return v[1:v.find('"', start=1)]
		else:
			raise RuntimeError("String value in quotes requires ending quote")
	elif v.startswith('['):
		start = i = 1
		o = []
		while i < len(v) and v[i] != ']':
			if v[i] == '"':
				raise RuntimeError("String value within list not yet supported by valstr")
			elif v[i] == "'":
				if v[i+1] == "'":
					o.append(0)
				elif v[i+2] != "'":
					raise RuntimeError("Char value within list must be a single character")
				else:
					o.append(ord(v[i+1]))
			elif v[i] == ',':
				o.append(valstr(v[start:i]))
				start = i+1
			i += 1
		return o
	return int(v)

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

	with open(join(path, "src", "include", "ti84pceg.inc"), "r") as f:
		data = f.read().split("\n")
	
	ns = None
	for line in data:
		if "RAM Equates" in line:
			break
		if line.startswith("namespace "):
			ns = line.split(" ", maxsplit=1)[1].strip("?")
			if ns not in o.keys():
				o[ns] = []
		elif len(line) > 2:
			start = 0
			while start < len(line) and not (line[start].isalnum() or line[start] in '_.'):
				start += 1
			end = start
			while end < len(line) and (line[end].isalnum() or line[end] in '_.'):
				end += 1
			name = line[start:end]
			if line.startswith("?"):
				if ns is not None:
					o[ns].append(f"export_ptr {ns}.{name}, \"{name}\"")
				else:
					o["_"].append(f"export_ptr {ns}.{name}, \"{name}\"")

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
