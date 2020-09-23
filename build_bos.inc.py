#!/usr/bin/python3
def error(e):
	print("Something went wrong!")
	print("Error:",e)
	quit()

def myhex(n):
	return hex(n).replace("0x","").upper()

try:
	with open("src/table.asm") as f:
		data=f.read().splitlines()
except Exception as e:
	error(e)
try:
	with open("src/include/defines.inc") as f:
		defines=f.read().splitlines()
except Exception as e:
	error(e)
try:
	with open("src/include/boot_calls.inc") as f:
		bootcalls=f.read()
except Exception as e:
	error(e)


counter=0x020108

with open("bos.inc","w") as f:
	f.write("""define ti? ti
namespace ti
""")
	f.write(bootcalls)
	f.write("""
end namespace

define bos? bos
namespace bos
""")
	for line in data:
		if "jp " in line:
			line=line[line.find("jp ")+3:]
			if ";" in line:
				line=line.split(';')[0].strip("\t ")
			if line=="DONOTHING":
				f.write(";DONOTHING                       := $"+myhex(counter)+"\n")
			else:
				f.write("?"+line.ljust(32," ")+(":= $"+myhex(counter))+"\n")
			counter+=4
		else:
			f.write(";"+line+"\n")
	for line in defines:
		if len(line):
			o=ord(line[0])
			if o in range(0x41,0x5B) or o in range(0x61,0x7B):
				f.write("?"+line+"\n")
	f.write("\nend namespace")
