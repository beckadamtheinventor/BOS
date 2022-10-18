# !/usr/bin/python3
import os, sys

default_dir_entry = [0xFF]*0xF0 + [0xFE] + [0xFF]*0xF

partition_default_entry = [
	"bosfs040fs ", 0x14, 0x80, 0x00, 0x80, 0x1B
]

root_dir_data = [
	"bin        ", 0x10, 0x03, 0x00, 0x00, 0x02,
	"lib        ", 0x10, 0x02, 0x00, 0x00, 0x02,
	"sbin       ", 0x10, 0x01, 0x00, 0x00, 0x02,
] + [0xFF]*0xC0 + [0xFE] + [0xFF]*0xF


def copy_data(rom, data, addr=None):
	if addr is None:
		addr = len(rom)
	i = j = 0
	while i<len(data):
		if type(data[i]) is int:
			rom[addr+j] = data[i]
			j+=1
		else:
			for c in data[i]:
				rom[addr+j] = ord(c)
				j+=1
		i+=1
	return j

def get_file_data(rom, path):
	ent = search_for_entry(rom, path)
	if ent is not None:
		ptr = 0x040000 + 0x40 * (rom[ent+0xC]+rom[ent+0xD]*0x100)
		L = rom[ent+0xE]+rom[ent+0xF]*0x100
		return rom[ptr:ptr+L]

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

	ptr = 0x050000
	dnum = 0
	while rom[ptr] != 0x00 and rom[ptr] != 0xFF:
		fn = copy_file_name(rom[ptr:ptr+16])
		# print("ptr:",hex(ptr),"entry:","".join([chr(c) if c in range(0x20,0x80) else "\\x"+hex(c) for c in rom[ptr:ptr+16]]),"file name",fn)
		if fn == path[dnum]:
			if dnum >= L:
				return ptr
			elif rom[ptr+0xB] & 0x10:
				ptr = 0x040000 + 0x40 * (rom[ptr+0xC]+rom[ptr+0xD]*0x100)
				dnum+=1
		else:
			ptr+=16

def copy_file_name(entry):
	# print("entry:","".join([chr(c) if c in range(0x20,0x80) else "\\x"+hex(c) for c in entry]))
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
	cmap_data = 0x3B2400
	cmap_len = 7040
	j = l = 0
	i = 0x010000//0x40
	while l<length and i<cmap_len:
		while rom[cmap_data+i] != 0xFF and i<cmap_len:
			i+=1
		j = i
		i += 1
		l = 0
		while rom[cmap_data+i] == 0xFF and i<cmap_len and l<length:
			i+=1
			l+=0x40
	# print(f"allocated sectors {hex(j)} to {hex(i)} ({hex(0x040000+j*0x40)} to {hex(0x040000+i*0x40)})")
	for k in range(j, i+1):
		rom[cmap_data+k] = 0xFE
		if 0x040000 + k * 0x40 >= len(rom):
			rom.extend([0xff]*0x40)
	return j

def free_file_descriptor(rom, ptr):
	cmap_data = 0x3B2400
	cmap_len = 7040
	i = cmap_data+rom[ptr+0xC]+rom[ptr+0xD]*0x100
	data = 0x040000+(rom[ptr+0xC]+rom[ptr+0xD]*0x100)*0x40
	data_len = rom[ptr+0xE]+rom[ptr+0xF]*0x100
	j = 0
	while j<data_len:
		rom[i] = 0xFF
		for k in range(0x40):
			rom[data+j+k]=0xFF
		j += 0x40
		i += 1

	while rom[ptr] != 0x00 and rom[ptr] != 0xFF:
		for k in range(0x10):
			rom[ptr+k] = rom[ptr+0x10+k]
		ptr+=0x10

	for k in range(0x10):
		rom[ptr+k] = 0xFF


def build_cluster_map(rom):
	if len(rom)<0x3C0000:
		rom.extend([0xFF]*(0x3C0000-len(rom)))
	cmap_data = 0x3B2400
	rom[cmap_data] = 0xFE
	rom[cmap_data+1] = 0xFE
	build_cluster_map_dir(rom, 0x040000)


def build_cluster_map_dir(rom, entry, dirprefix="/"):
	# print(f"building cluster map at {hex(entry)}")
	cmap = 0x3B2400
	k = rom[entry+0xC] + rom[entry+0xD]*0x100
	i = 0x040000 + k*0x40
	rom[cmap + k] = 0xFE
	
	# maxi = i+(rom[entry+0xE]+rom[entry+0xF]*0x100)-16
	while i<len(rom):
		# print(hex(rom[i]),hex(rom[i+0xB]))
		if rom[i] == 0xFF:
			return True
		if rom[i+0xB] & 8:
			l = rom[i+0xE]+rom[i+0xF]*0x100
			# print(copy_file_name(rom[i:i+16]), hex(l))
			ptr = (i&0xFFFE00) + rom[i+0xC] + rom[i+0xD]*0x100
			k = (ptr-0x040000)//0x40
			m = 0
			# print(f"processing subfile {copy_file_name(rom[i:i+16])} at {hex(ptr)}")
			# print(f"starting at cluster map address {hex(cmap+k)}")
			# print(f"sectors {k} to ",end="")
			while m<l:
				# print("allocated sector", hex(k))
				rom[cmap + k] = 0xFE
				k += 1
				m += 0x40
			# print(k)
		elif rom[i+0xB] & 0x10:
			# print(hex(i+0xB), bin(rom[i+0xB]))
			if copy_file_name(rom[i:i+16]) not in [".", ".."]: #check if a directory and not '.' or '..'
				# print(f"pathing into {dirprefix}{copy_file_name(rom[i:i+16])}")
				build_cluster_map_dir(rom, i, dirprefix+copy_file_name(rom[i:i+16])+"/")
		else:
			flen = rom[i+0xE]+rom[i+0xF]*0x100
			fptr = rom[i+0xC]+rom[i+0xD]*0x100
			if fptr < 0xDC00 and flen > 0:
				if flen % 0x40:
					flen += flen % 0x40
				# print(copy_file_name(rom[i:i+16]), hex(flen))
				for j in range(flen//0x40):
					# print("allocated sector", hex(rom[i+0xC]+rom[i+0xD]*0x100+j))
					rom[cmap + fptr + j] = 0xFE
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
		if dptr is None:
			print(f"Failed to add file to rom: {os.path.dirname(fout)}")
			exit(1)

	f = search_for_entry(rom, fout)
	if f is not None:
		free_file_descriptor(rom, f)

	ptr = 0x040000 + 0x40 * (rom[dptr+0xC]+rom[dptr+0xD]*0x100)
	# print("found parent directory. ptr:",hex(ptr),"len:",hex(dptr_len))
	while rom[ptr] != 0xFF:
		if rom[ptr] == 0xFE:
			if rom[ptr+0xC]+rom[ptr+0xD]*0x100 == 0xFFFF:
				nextptr = alloc_space_for_file(rom, 0x40)
				rom[ptr+0xB] = 0x10
				rom[ptr+0xC] = (nextptr//0x40) % 0x100
				rom[ptr+0xD] = nextptr//0x4000
				rom[ptr+0xE] = 0
				rom[ptr+0xF] = 2
			ptr = 0x040000 + (rom[ptr+0xC]+rom[ptr+0xD]*0x100)*0x40
		ptr += 16
	

	if ptr+16 < len(rom):
		while rom[ptr] != 0x00 and rom[ptr] != 0xFF: ptr+=16
	if ptr+16 >= len(rom):
		rom.extend([0xFF]*0x40)
	if '/' in fout:
		fn = fout.rsplit("/",maxsplit=1)[1]
	else:
		fn = fout
	if "." in fn:
		name, ext = fn.rsplit(".",maxsplit=1)
	else:
		name = fn
		ext = ""
	if flags & 0x10:
		sector = alloc_space_for_file(rom, 0x40)
	else:
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

	sptr = 0x040000+sector*0x40

	if flags & 0x10:
		rom[ptr+0xE] = 0x00
		rom[ptr+0xF] = 0x01
		rom[sptr+0x1F0] = 0xFE
	else:
		rom[ptr+0xE] = len(fin_data)&0xFF
		rom[ptr+0xF] = len(fin_data)//0x100

	while sptr+len(fin_data) > len(rom):
		rom.extend([0xFF]*0x40)

	for i in range(len(fin_data)):
		rom[sptr+i] = fin_data[i]


if __name__=='__main__':
	fdir = os.path.dirname(__file__)
	fnamein = []
	fnameout = []
	rom_out = os.path.join(fdir, "bin", "BOSOS_appended.rom")
	rom_in = os.path.join(fdir, "bin","BOSOS.rom")
	rom = None

	_argv = sys.argv[1:]
	if len(_argv)>1:
		written_rom = False
		while len(_argv):
			appending = compress_file = False
			fin = _argv.pop(0)
			if fin == "--rom":
				rom_in = _argv.pop(0)
				continue
			elif fin == "--append":
				fin = _argv.pop(0)
				appending = True
			elif fin == "--output":
				fin = _argv.pop(0)
				if not os.path.isabs(fin):
					fin = os.path.join(fdir, fin)
				with open(fin, "wb") as f2:
					if rom is None:
						try:
							with open(rom_in, "rb") as f:
								rom = list(f.read())
						except FileNotFoundError:
							print(f'Could not locate rom image "{rom_in}". Did you build BOS yet?\nAborting.')
							exit(1)
						if len(rom) <= 0x050000:
							with open(os.path.join(os.path.dirname(__file__), "src", "data", "adrive", "main.bin"), 'rb') as f:
								rom.extend(list(f.read()))
							rom.extend([0xFF] * (0x3C0000-len(rom)))
							copy_data(rom, partition_default_entry, 0x040000)
							copy_data(rom, root_dir_data, 0x050000)
						build_cluster_map(rom)
					f2.write(bytes(rom))
				print(f"[Success] {fin}, {len(rom)} bytes")
				written_rom = True
				continue
			elif fin.startswith("-c") or fin.startswith("--compressed-rex"):
				compress_file = True
				fin = _argv.pop(0)

			if rom is None:
				try:
					with open(rom_in, "rb") as f:
						rom = list(f.read())
				except FileNotFoundError:
						print(f'Could not locate rom image "{rom_in}".\nAborting.')
						exit(1)
			if len(rom) <= 0x050000:
				with open(os.path.join(os.path.dirname(__file__), "src", "data", "adrive", "main.bin"), 'rb') as f:
					rom.extend(list(f.read()))
				rom.extend([0xFF] * (0x3C0000-len(rom)))
				copy_data(rom, partition_default_entry, 0x040000)
				copy_data(rom, root_dir_data, 0x050000)
			build_cluster_map(rom)

			fout = _argv.pop(0)
			print(f"writing file to rom image: {fin} --> {fout}")
			if compress_file:
				print("\tCompressing file as zx7-compressed RAM Executable.")
			try:
				if compress_file:
					with open(fin, "rb") as f:
						f.seek(0, 2)
						original_len = f.tell()
					if appending:
						existingdata = get_file_data(rom, fout)
						if existingdata is None:
							appending = False
					if original_len >= 0xD2F800 - 0xD1A881:
						print(f"File to be compressed would overflow usermem if executed: {fin} ({len(original_len)} bytes)\nAborting.")
						exit(1)
					os.system(f"convbin -i {fin} -o {fin}.zx7 -j bin -k bin -c zx7")
					if appending:
						fin_data = list(existingdata)
					else:
						fin_data = []
					fin_data.extend([0x18,0x0C,0x43,0x52,0x58,0x00,0x7A,0x78,0x37,0x00]+\
						list(original_len.to_bytes(3, 'little')))
					with open(f"{fin}.zx7","rb") as f:
						fin_data.extend(list(f.read()))
					if len(fin_data) > 65535:
						print(f"Compressed file is too large to write to filesystem: {fin} ({len(fin_data)} bytes)\nAborting.")
						exit(1)
				else:
					if appending:
						existingdata = get_file_data(rom, fout)
						if existingdata is None:
							appending = False
					with open(fin, "rb") as f:
						fin_data = list(f.read())
					if appending:
						fin_data = existingdata + fin_data
					if len(fin_data) > 65535:
						print(f"File is too large to write to filesystem: {fin} ({len(fin_data)} bytes)\nAborting.")
						exit(1)
				add_file_to_rom(rom, fout, 0x00, fin_data)
				build_cluster_map(rom)
			except FileNotFoundError:
				print(f"Could not open file: {fin}\nAborting.")
				exit(1)
		if not written_rom:
			with open(rom_out, "wb") as f:
				f.write(bytes(rom))
			print(f"[Success] {rom_out}, {len(rom)} bytes")
	else:
		print("""Usage:
python add_file_to_rom.py file1source file1dest file2source +file2dest
raw binary data from file1source is written to file1dest on rom image
""")
