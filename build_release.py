#!/usr/bin/python3

if __name__=='__main__':
	import sys,os
	d = os.path.dirname(__file__)
	with open(d+"src/data/buildno.txt") as f:
		data = f.read().split(" ")
	if len(sys.argv) >= 2:
		if sys.argv[1] == "?":
			print(" ".join(data))
			exit(0)

	if len(sys.argv) < 2:
		ver = data[1].split(".")
		ver[2] = str(int(ver[2])+1).rjust(4,"0")
		data[1] = ".".join(ver)
	elif len(sys.argv) > 2:
		data[2] = sys.argv[2]
	if len(sys.argv) >= 2:
		data[1] = sys.argv[1]

	with open(d+"src/data/buildno.txt","w") as f:
		f.write(" ".join(data))

	print("building "," ".join(data))

	if sys.platform.startswith('linux'):
		os.system("./build.sh")
	elif sys.platform.startswith('win') or sys.platform.startswith("cygwin"):
		os.system("call build.bat")

