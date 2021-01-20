#!/usr/bin/python3
import os, sys

default_dir_entry = [
	ord("."),0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,  0x10,  0x00, 0x00, 0x00, 0x00,
	ord("."),ord("."),0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,  0x10,  0x00, 0x00, 0x00, 0x00,
	0xF0,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,  0x10,  0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
]

def search_for_entry(rom, path):
#	print("searching for", path)
	while "//" in path:
		path = path.replace("//","/")
	path = path.rstrip("/").split("/")[1:]
	L = len(path)-1
#	print(L, path)

	ptr = 0x040200
	dnum = 0
	while rom[ptr]:
#		print("ptr:",hex(ptr),"entry:","".join([chr(c) if c in range(0x20,0x80) else "\\x"+hex(c) for c in rom[ptr:ptr+16]]))
		fn = copy_file_name(rom[ptr:ptr+16])
#		print("file name:",fn)
		if not rom[ptr]:
			return None
		elif path[dnum] == fn:
			if dnum >= L:
				return ptr
			elif rom[ptr+0xB] & 0x10:
				ptr = 0x040000 + 0x200 * (rom[ptr+0xC]+rom[ptr+0xD]*0x100)
				dnum+=1
		else:
			ptr+=16

def copy_file_name(entry):
	if entry[0] == 0xF0 or entry[0] == 0xF1:
		return None
	elif chr(entry[0]) == '.' and chr(entry[1]) == '.':
		return ".."
	elif chr(entry[0]) == '.':
		return "."
	if chr(entry[8]) == ' ':
		return "".join(chr(c) for c in entry[:8]).rstrip(" ")
	else:
		return "".join(chr(c) for c in entry[:8]).rstrip(" ") + "." + "".join(chr(c) for c in entry[8:11]).rstrip(" ")

def alloc_space_for_file(rom, length):
	cmap = search_for_entry(rom, "/dev/cmap.dat")
	if cmap is None:
		print("/dev/cmap.dat not found on rom!")
		exit(1)

	cmap_data = 0x040000+(rom[cmap+0xC]+rom[cmap+0xD]*0x100)*0x200
	cmap_len = rom[cmap+0xE]+rom[cmap+0xF]*0x100
	i = j = l = 0
	while l<length and i+j<cmap_len:
		i += j+1
		if i<cmap_len:
			while rom[cmap_data+i] == 0xFE: i+=1
			j = 0; l = 0x200
			while rom[cmap_data+i+j] == 0xFF and l<length: j+=1; l+=0x200
	if i+j<cmap_len:
		for k in range(i,j):
			rom[cmap_data+k] = 0xFE
		return i
	return None


def build_cluster_map(rom):
	cmap = search_for_entry(rom, "/dev/cmap.dat")
	if cmap is None:
		print("/dev/cmap.dat not found on rom!")
		exit(1)

	cmap_data = 0x040000+(rom[cmap+0xC]+rom[cmap+0xD]*0x100)*0x200
	build_cluster_map_dir(rom, cmap_data, 0x040000)


def build_cluster_map_dir(rom, cmap, entry):
	i = 0x040000+(rom[entry+0xC]+rom[entry+0xD]*0x100)*0x200
	while rom[i]:
		for j in range(rom[i+0xF]//2 if not rom[i+0xE]|rom[i+0xF]&1 else rom[i+0xF]//2+1):
			rom[cmap + rom[i+0xC]+rom[i+0xD]*256 + j] = 0xFE
		if rom[i+0xB] & 0x10 and rom[i]!=ord('.'): #check if a directory and not '.' or '..'
			build_cluster_map_dir(rom, cmap, 0x040000+(rom[i+0xC]+rom[i+0xD]*0x100)*0x200)
		i+=16

def add_file_to_rom(rom, fout, flags, fin_data):
	dptr = search_for_entry(rom, os.path.dirname(fout))
	if dptr is None:
		add_file_to_rom(rom, os.path.dirname(fout), 0x10, default_dir_entry)
		try:
			dptr_parent = search_for_entry(rom, os.path.dirname(os.path.dirname(fout)))
		except:
			print(f"Failed to add file to rom: {fout}")
			exit(1)
		dptr = search_for_entry(rom, os.path.dirname(fout))
		rom[dptr+0xC] = ((dptr-0x040000)//0x200)&0xFF
		rom[dptr+0xD] = (dptr-0x040000)//0x20000
		rom[dptr+0x1C] = ((dptr_parent-0x040000)//0x200)&0xFF
		rom[dptr+0x1D] = (dptr_parent-0x040000)//0x20000

	ptr = dptr_content = 0x040000 + 0x200 * (rom[dptr+0xC]+rom[dptr+0xD]*0x200)
	dptr_len = rom[dptr+0xE]+rom[dptr+0xF]*0x200

	while rom[ptr]: ptr+=16
	fn = fout.rsplit("/",maxsplit=1)[1]
	if "." in fn:
		name, ext = fn.rsplit(".",maxsplit=1)
	else:
		name = fn
		ext = ""
	sector = alloc_space_for_file(rom, len(fin_data))
	if sector is None:
		print(f"Failed to allocate space for file on rom: {fout}")
		exit(1)
	for i in range(8):
		if i<len(name): rom[ptr+i] = ord(name[i])
		else: rom[ptr+i] = 0x20
	for i in range(3):
		if i<len(ext): rom[ptr+8+i] = ord(ext[i])
		else: rom[ptr+8+i] = 0x20
	for i in range(16,32):
		rom[ptr+i] = 0
	rom[ptr+0xC] = sector&0xFF
	rom[ptr+0xD] = sector//0x100
	rom[ptr+0xE] = len(fin_data)&0xFF
	rom[ptr+0xF] = len(fin_data)//0x100
	sptr = 0x040000+sector*0x200
	for i in range(len(fin_data)):
		rom[sptr+i] = fin_data[i]


if __name__=='__main__':
	fnamein = []
	fnameout = []
	if len(sys.argv)>1:
		if len(sys.argv) & 1:
			fname__out = fname__in = "BOSOS_appended.rom"
			try:
				with open(fname__in, "rb") as f:
					pass
			except IOError:
				fname__in = "bin/BOSOS.rom"
			i=1
		else:
			fname__out = fname__in = sys.argv[1]
		while i<len(sys.argv):
			fnamein.append(sys.argv[i])
			i+=1
			fnameout.append(sys.argv[i])
			i+=1

	if not len(fnamein) or not len(fnameout):
		fname__in = "bin/BOSOS.rom"
		fname__out = "BOSOS_appended.rom"
		while True:
			i = input("File/Dir to add?")
			if i != "\n" and len(i):
				fnamein.append(i)
			else:
				break
			i = input("Path on calc?")
			if i != "\n" and len(i):
				fnameout.append(i)
			else:
				break

	if not len(fnamein) or not len(fnameout):
		print("No files/directories to add. Exiting.")
		exit(0)
	elif len(fnamein)!=len(fnameout):
		print("Mismatched length for input files vs. output files.")
		exit(1)

	try:
		with open(fname__in, 'rb') as f:
			rom = list(f.read())
	except IOError:
		print('Could not locate rom image "{fname__in}". Did you build BOS yet?')
		exit(1)

	if len(rom) < 0x400000:
		rom.extend([0xFF]*(0x400000-len(rom)))

	build_cluster_map(rom)
	for i in range(len(fnamein)):
		fin = fnamein[i]
		fout = fnameout[i]
		print(f"writing file to rom image: {fin} --> {fout}")
		try:
			with open(fin, "rb") as f:
				fin_data = list(f.read())
			if len(fin_data) > 65535:
				print(f"One or more files is too large to write to filesystem: {fin}")
				exit(1)
			else:
				add_file_to_rom(rom, fout, 0x00, fin_data)
		except IOError:
			print(f"Could not open file: {fin}")
			exit(1)

	with open(fname__out, 'wb') as f:
		f.write(bytes(rom))


