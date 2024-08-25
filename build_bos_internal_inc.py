#!/usr/bin/python3
import os

def error(e):
	print("Something went wrong!")
	print("Error:",e)
	quit()

def fwalk(d, ext=None):
	for root, dirs, files in os.walk(d):
		for file in files:
			if ext is not None:
				if "." not in file:
					continue
				x = file.rsplit(".", maxsplit=1)[1]
				if x.lower() != ext.lower():
					continue
			yield root.replace("\\","/")+"/"+file

def build_internal_inc():
	print("Building bos_internal.inc")

	o = []
	sourcelist = list(fwalk("src", "asm"))
	# print("\n".join(sourcelist))
	for fname in sourcelist:
		with open(fname) as f:
			curglob = ""
			data = f.read().split("\n")
			for line in data:
				if ":" in line:
					if ";" in line:
						if line.find(":") > line.find(";"):
							continue
					if line.startswith("."):
						lbl, _ = line.split(":", maxsplit=1)
						lbl = curglob + lbl
					else:
						lbl, _ = line.split(":", maxsplit=1)
						curglob = lbl
				else:
					continue
				# print(lbl)
				if not all([c.isalnum() or c in '_.' for c in lbl]):
					continue
				o.append("if defined "+lbl)
				o.append("_n_"+lbl+" strcalc "+lbl)
				o.append("db '_"+lbl+" := ', _n_"+lbl+",$A")
				o.append("end if")
	
	with open("obj/gen_internal.inc", "w") as f:
		f.write("""
macro org? a
	virtual at a
end macro
include '../src/main.asm'
end virtual
calminstruction (var) strcalc? val
	compute val, val        ; compute expression
	arrange val, val        ; convert result to a decimal token
	stringify val           ; convert decimal token to string
	publish var, val
end calminstruction
"""+"\n".join(o))

	os.system("fasmg obj/gen_internal.inc bin/bos_internal.inc")


if __name__=='__main__':
	build_internal_inc()

