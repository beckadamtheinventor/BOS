import sys, os, shutil
from os.path import dirname, join

VERSION_FILE = join(dirname(__file__), "src", "data", "buildno.txt")

def MakeArtifact():
	with open(VERSION_FILE) as f:
		ver = f.read()
	shutil.copytree(join(dirname(__file__), "bin"), join(dirname(__file__), "artifacts", ver))

def MakeVersion(add="0.0.1", no=None):
	with open(VERSION_FILE) as f:
		ver = f.read()	
	if " " in ver:
		ver, alp = ver.split(" ", maxsplit=1)
		alp = " " + alp
	else:
		alp = ""
	if no is None:
		ver = [int(s) for s in ver.split(".")]
		add = [int(s) for s in add.split(".")]
		for i in range(len(add)):
			ver[i] += add[i]
		shouldzero = False
		for i in range(len(add)):
			if shouldzero:
				ver[i] = 0
			if add[i] > 0:
				shouldzero = True
		ver = ".".join([str(s) for s in ver])
	else:
		ver = no
	with open(VERSION_FILE, "w") as f:
		f.write(ver + alp)

if __name__=='__main__':
	if len(sys.argv) >= 2:
		if sys.argv[1] == "version":
			if len(sys.argv) >= 3:
				if sys.argv[2] == "add" and len(sys.argv) >= 4:
					MakeVersion(add=sys.argv[3])
				else:
					MakeVersion(no=" ".join(sys.argv[2:]))
		elif sys.argv[1] == "artifact":
			MakeArtifact()
	else:
		print(f"Usage: python {sys.argv[0]} (args)\n\tversion add x.y.z\n\tversion x.y.z ...")
