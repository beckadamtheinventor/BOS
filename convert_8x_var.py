
import os, sys, subprocess
from os.path import join, dirname, basename

# Convert an 8x var into a BOS v## file. This conversion will eventually be done automatically by the MSD program,
# but this should suffice for now.
def convert(fname):
	with open(fname, 'rb') as f:
		data = f.read()
	vartype = int(data[59])
	fnameout = fname.rsplit(".", maxsplit=1)[0] + ".v" + hex(vartype//16)[2:] + hex(vartype%16)[2:]
	subprocess.run(["convbin", "-i", fname, "-o", fnameout, "-j", "8x", "-k", "bin"],cwd=dirname(__file__))
	with open(fnameout, 'rb') as f:
		outdata = f.read()
	for i in range(60,68):
		nlen = i+1
		if data[i] == 0:
			break
	with open(fnameout, 'wb') as f:
		f.write(bytes([255,255,255]))
		f.write(bytes([vartype]))
		f.write(bytes([255,255,255,255,255]))
		f.write(bytes([nlen-60]))
		f.write(data[60:nlen])
		f.write(len(outdata).to_bytes(2, 'little'))
		f.write(outdata)
	

if __name__=='__main__':
	if len(sys.argv) < 2:
		print("Usage: convert_8x_var.py file.8x[?]")
	else:
		for v in sys.argv[1:]:
			try:
				convert(v)
			except FileNotFoundError:
				print(f"File {v} does not exist or could not be opened!")

