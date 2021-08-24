#!/usr/bin/python3
import os, sys

default_dir_entry = [
	ord("."),0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,  0x10,  0x00, 0x00, 0x00, 0x00,
	ord("."),ord("."),0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,0x20,  0x10,  0x00, 0x00, 0x00, 0x00,
	0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
]

def search_for_entry(rom, path):
	# print("searching for", path)
	if not path.startswith("/"):
		path = "/"+path
	while "//" in path:
		path = path.replace("//","/")
	path = path.rstrip("/").split("/")[1:]
	if not len(path):
		return 0x040000
	L = len(path)-1
	# print(L, path)

	ptr = 0x040200
	dnum = 0
	while rom[ptr] != 0x00 and rom[ptr] != 0xFF:
		fn = copy_file_name(rom[ptr:ptr+16])
		# print("ptr:",hex(ptr),"entry:","".join([chr(c) if c in range(0x20,0x80) else "\\x"+hex(c) for c in rom[ptr:ptr+16]]),"file name",fn)
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
		name = "".join(chr(c) for c in entry[:9])
		return name[:name.find(" ")]
	else:
		name = "".join(chr(c) for c in entry[:9])
		name = name[:name.find(" ")]
		return name + "." + "".join(chr(c) for c in entry[8:11]).rstrip(" ")

def alloc_space_for_file(rom, length):
	cmap = search_for_entry(rom, "/dev/cmap.dat")
	if cmap is None:
		print("/dev/cmap.dat not found on rom!\nAborting.")
		exit(1)

	cmap_data = 0x040000+(rom[cmap+0xC]+rom[cmap+0xD]*0x100)*0x200
	cmap_len = rom[cmap+0xE]+rom[cmap+0xF]*0x100
	i = j = 3
	l = 0
	while l<length and i<cmap_len:
		while rom[cmap_data+i] == 0xFE and i<cmap_len:
			i+=1
		j = i
		l = 0x200
		while rom[cmap_data+i] != 0xFE and i<cmap_len and l<length:
			i+=1
			l+=0x200
	# print(f"allocated sectors {hex(j)} to {hex(i)} ({hex(0x040000+j*0x200)} to {hex(0x040000+i*0x200)})")
	for k in range(j, i+1):
		rom[cmap_data+k] = 0xFE
		if 0x040000 + k * 0x200 >= len(rom):
			rom.extend([0xff]*0x200)
	return j

def free_file_descriptor(rom, ptr):
	cmap = search_for_entry(rom, "/dev/cmap.dat")
	if cmap is None:
		print("/dev/cmap.dat not found on rom!\nAborting.")
		exit(1)

	cmap_data = 0x040000+(rom[cmap+0xC]+rom[cmap+0xD]*0x100)*0x200
	cmap_len = rom[cmap+0xE]+rom[cmap+0xF]*0x100
	i = cmap_data+rom[ptr+0xC]+rom[ptr+0xD]*0x100
	data = 0x040000+(rom[ptr+0xC]+rom[ptr+0xD]*0x100)*0x200
	data_len = rom[ptr+0xE]+rom[ptr+0xF]*0x100
	j = 0
	while j<data_len:
		rom[i] = 0xFF
		for k in range(0x200):
			rom[data+j+k]=0xFF
		j += 0x200
		i += 1

	while rom[ptr] != 0x00 and rom[ptr] != 0xFF:
		for k in range(0x10):
			rom[ptr+k] = rom[ptr+0x10+k]
		ptr+=0x10

	for k in range(0x10):
		rom[ptr+k] = 0xFF


def build_cluster_map(rom):
	cmap = search_for_entry(rom, "/dev/cmap.dat")
	if cmap is None:
		print("/dev/cmap.dat not found in rom!\nAborting.")
		exit(1)

	cmap_data = 0x040000+(rom[cmap+0xC]+rom[cmap+0xD]*0x100)*0x200
	rom[cmap_data] = 0xFE
	rom[cmap_data+1] = 0xFE
	build_cluster_map_dir(rom, cmap_data, 0x040000)


def build_cluster_map_dir(rom, cmap, entry, dirprefix="/"):
	i = 0x040000+(rom[entry+0xC]+rom[entry+0xD]*0x100)*0x200
	# maxi = i+(rom[entry+0xE]+rom[entry+0xF]*0x100)-16
	while i<len(rom):
		if rom[i] in [0x00, 0xFF]:
			return True
		if rom[i+0xB] & 8:
			l = rom[i+0xE]+rom[i+0xF]*0x100
			ptr = (i&0xFFFE00) + rom[i+0xC] + rom[i+0xD]*0x100
			k = (ptr-0x040000)//0x200
			m = 0
			# print(f"processing subfile {copy_file_name(rom[i:i+16])} at {hex(ptr)}")
			# print(f"starting at cluster map address {hex(cmap+k)}")
			# print(f"sectors {k} to ",end="")
			while m<l:
				rom[cmap + k] = 0xFE
				k+=1
				m+=0x200
			# print(k)
		else:
			for j in range(rom[i+0xF]//2 if not rom[i+0xE]|(rom[i+0xF]&1) else rom[i+0xF]//2+1):
				rom[cmap + rom[i+0xC]+rom[i+0xD]*0x100 + j] = 0xFE
			if rom[i+0xB]&0x10 and rom[i]!=0x2E: #check if a directory and not '.' or '..'
				# print(f"pathing into {dirprefix}{copy_file_name(rom[i:i+16])}")
				build_cluster_map_dir(rom, cmap, 0x040000+(rom[i+0xC]+rom[i+0xD]*0x100)*0x200, dirprefix+copy_file_name(rom[i:i+16])+"/")
		i+=16
	return False

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
		dptr_ds = 0x040000 + (rom[dptr+0xC] + rom[dptr+0xD]*0x100)*0x200
		dptr_parent = 0x040000 + (rom[dptr_parent+0xC] + rom[dptr_parent+0xD]*0x100)*0x200
		rom[dptr_ds+0xC] = ((dptr_ds-0x040000)//0x200)&0xFF
		rom[dptr_ds+0xD] = (dptr_ds-0x040000)//0x20000
		rom[dptr_ds+0x1C] = ((dptr_parent-0x040000)//0x200)&0xFF
		rom[dptr_ds+0x1D] = (dptr_parent-0x040000)//0x20000

	f = search_for_entry(rom, fout)
	if f is not None:
		free_file_descriptor(rom, f)

	ptr = dptr_content = 0x040000 + 0x200 * (rom[dptr+0xC]+rom[dptr+0xD]*0x100)
	dptr_len = rom[dptr+0xE]+rom[dptr+0xF]*0x200
	# print("found parent directory. ptr:",hex(ptr),"len:",hex(dptr_len))
	dptr_len += 16
	rom[dptr+0xE],rom[dptr+0xF] = dptr_len&0xFF, dptr_len//0x100

	if ptr+16 < len(rom):
		while rom[ptr] != 0x00 and rom[ptr] != 0xFF: ptr+=16
	if ptr+16 >= len(rom):
		rom.extend([0xFF]*512)
	if '/' in fout:
		fn = fout.rsplit("/",maxsplit=1)[1]
	else:
		fn = fout
	if "." in fn:
		name, ext = fn.rsplit(".",maxsplit=1)
	else:
		name = fn
		ext = ""
	sector = alloc_space_for_file(rom, len(fin_data))
	if not sector:
		print(f"Failed to allocate space for file on rom: {fout}\nAborting.")
		exit(1)
	for i in range(8):
		if i<len(name): rom[ptr+i] = ord(name[i])
		else: rom[ptr+i] = 0x20
	for i in range(3):
		if i<len(ext): rom[ptr+8+i] = ord(ext[i])
		else: rom[ptr+8+i] = 0x20
	rom[ptr+0xB] = flags
	rom[ptr+0xC] = sector&0xFF
	rom[ptr+0xD] = sector//0x100
	rom[ptr+0xE] = len(fin_data)&0xFF
	rom[ptr+0xF] = len(fin_data)//0x100
	sptr = 0x040000+sector*0x200
	while sptr+len(fin_data) > len(rom):
		rom.extend([0xFF]*512)
	for i in range(len(fin_data)):
		rom[sptr+i] = fin_data[i]


if __name__=='__main__':
	fdir = os.path.dirname(__file__)
	if not fdir.endswith("/"):
		fdir+="/"
	fnamein = []
	fnameout = []
	rom_out = "bin/BOSOS_appended.rom"
	rom_in = "bin/BOSOS.rom"

	try:
		with open(rom_in, 'rb') as f:
			rom = list(f.read())
		fdir = ""
	except FileNotFoundError:
		try:
			with open(fdir+rom_in,'rb') as f:
				rom = list(f.read())
		except FileNotFoundError:
			print(f'Could not locate rom image "{rom_in}". Did you build BOS yet?\nAborting.')
			exit(1)
	build_cluster_map(rom)

	_argv = sys.argv[1:]
	if len(_argv)>1:
		compress_file = False
		while len(_argv):
			fin = _argv.pop(0)
			if fin.startswith("-c") or fin.startswith("--compressed-rex"):
				compress_file = True
				fin = _argv.pop(0)
			else:
				compress_file = False
			fout = _argv.pop(0)
			print(f"writing file to rom image: {fin} --> {fout}")
			if compress_file:
				print("\tCompressing file as zx7-compressed RAM Executable.")
			try:
				if compress_file:
					with open(fin, "rb") as f:
						f.seek(0, 2)
						original_len = f.tell()
					if original_len >= 0xD30000 - 0xD1A881:
						print(f"File to be compressed would overflow usermem if executed: {fin}\nAborting.")
						exit(1)
					os.system(f"convbin -i {fin} -o {fin}.zx7 -j bin -k bin -c zx7")
					fin_data = [0x18,0x0C,0x43,0x52,0x58,0x00,0x7A,0x78,0x37,0x00]+\
						list(original_len.to_bytes(3, 'little'))
					with open(f"{fin}.zx7","rb") as f:
						fin_data.extend(list(f.read()))
					if len(fin_data) > 65535:
						print(f"Compressed file is too large to write to filesystem: {fin}\nAborting.")
						exit(1)
				else:
					with open(fin, "rb") as f:
						fin_data = list(f.read())
					if len(fin_data) > 65535:
						print(f"File is too large to write to filesystem: {fin}\nAborting.")
						exit(1)
				add_file_to_rom(rom, fout, 0x00, fin_data)
				build_cluster_map(rom)
			except FileNotFoundError:
				print(f"Could not open file: {fin}\nAborting.")
				exit(1)

	with open(fdir+rom_out, 'wb') as f:
		f.write(bytes(rom))
