
import os,sys

def build_bos_src():
	d = os.path.dirname(__file__)
	with open(os.path.join(d, "bos.inc")) as f:
		data = f.read().splitlines()
	publics = []
	defines = []
	for line in data:
		if line.startswith("?"):
			publics.append(line[1:line.find(" ")])
			defines.append(line[1:])
		elif line.startswith("; defines"):
			break
	with open(os.path.join(d, "bos.src"),"w") as f:
		f.write("\n; BOS jump table functions\n")
		for line in publics:
			f.write(f"\tpublic {line}\n")
		for line in defines:
			f.write(f"{line}\n")

if __name__=='__main__':
	build_bos_src()
