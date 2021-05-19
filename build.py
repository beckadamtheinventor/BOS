#!/usr/bin/python3

import sys,os,json,hashlib


class Build:
	def __init__(self,ver):
		self.hash_file = "obj/build_hashes.json"
		self.os_build_files = [
			"src/lib/libload/bos_libload.asm obj/bos_libload.bin",
			"src/lib/fatdrvce/fatdrvce.asm obj/fatdrvce.bin",
			"src/lib/fileioc/fileioc.asm obj/fileioc.bin",
			"src/lib/fontlibc/fontlibc.asm obj/fontlibc.bin",
			"src/lib/graphx/graphx.asm obj/graphx.bin",
			"src/lib/keypadc/keypadc.asm obj/keypadc.bin",
			"src/lib/srldrvce/srldrvce.asm obj/srldrvce.bin",
			"src/lib/usbdrvce/usbdrvce.asm obj/usbdrvce.bin",

			"-c src/fs/bin/bpkload.asm obj/bpkload.bin",
			"-c src/fs/bin/bpm.asm obj/bpm.bin",
			"-c src/fs/bin/explorer.asm obj/explorer.bin",
			"-c src/fs/bin/fexplore.asm obj/fexplore.bin",
			"-c src/fs/bin/memedit.asm obj/memedit.bin",
#			"-c src/fs/bin/edit.asm obj/edit.bin",
			"-c src/fs/bin/usbrun.asm obj/usbrun.bin",
			"-c src/fs/bin/usbsend.asm obj/usbsend.bin",
			"-c src/fs/bin/usbrecv.asm obj/usbrecv.bin",

			"src/dev_mnt/init.asm obj/dev_mnt/init.bin",
			"src/dev_mnt/deinit.asm obj/dev_mnt/deinit.bin",
			"src/dev_mnt/read.asm obj/dev_mnt/read.bin",
			"src/dev_mnt/write.asm obj/dev_mnt/write.bin"

		]
		try:
			with open(self.hash_file,"r") as f:
				j = json.load(f)
				self.hash_table = j["hashes"]
				self.len_table = j["lengths"]
		except IOError:
			self.hash_table = {}
			self.len_table = {}
		self.path = ""
		self.ver = ver

	def build(self,copyincludes=False):
		print("building",self.ver)
		try:
			os.mkdir("bin")
		except FileExistsError:
			pass
		try:
			os.mkdir("obj")
		except FileExistsError:
			pass
		self.build_include(copyincludes)
		try:
			with open("noti-ez80/bin/NOTI.rom","rb") as f:
				pass
		except IOError:
			self.build_noti()
		self.build_filesystem()
		self.build_os()
		self.build_rom()
		self.build_installer()
		self.build_updater()
		self.write_hashes()

	def build_include(self, copyincludes=False):
		from build_bos_inc import build_bos_inc
		build_bos_inc()
		if copyincludes:
			if sys.platform.startswith("win"):
				os.system("copy bos.inc src\\include\\ /Y")
				os.system("xcopy src\\include\\ src\\data\\adrive\\src\\include\\ /Y /C /E ")
				os.system("xcopy src\\include\\ src\\data\\adrive\\src\\lib\\include\\ /Y /C /E ")
				os.system("xcopy src\\include\\ src\\data\\adrive\\src\\fs\\bin\\include\\ /Y /C /E ")
			else:
				os.system("""cp -f bos.inc src/include/bos.inc
cp -rf src/include src/data/adrive/src/
cp -rf src/include src/data/adrive/src/lib/
cp -rf src/include src/data/adrive/src/fs/bin/""")

	def build_noti(self):
		print("Building noti-ez80")
		if sys.platform.startswith("win"):
			os.system("mkdir noti-ez80\\bin")
		else:
			os.system("mkdir noti-ez80/bin")
		# os.system("fasmg noti-ez80/src/BareOS/usbrun.asm noti-ez80/src/BareOS/usbrun.bin")
		# os.system("fasmg noti-ez80/src/lib/fatdrvce/fatdrvce.asm noti-ez80/src/lib/fatdrvce/fatdrvce.bin")
		# os.system("fasmg noti-ez80/src/lib/srldrvce/srldrvce.asm noti-ez80/src/lib/srldrvce/srldrvce.bin")
		# os.system("fasmg noti-ez80/src/lib/usbdrvce/usbdrvce.asm noti-ez80/src/lib/usbdrvce/usbdrvce.bin")
		# os.system("fasmg noti-ez80/src/lib/libload/libload.asm noti-ez80/src/lib/libload/libload.bin")
		os.system("fasmg noti-ez80/src/main.asm noti-ez80/bin/NOTI.rom")

	def build_filesystem(self):
		try:
			os.mkdir("src/data/adrive/obj")
		except FileExistsError:
			pass
		try:
			os.mkdir("src/data/adrive/obj/dev_mnt")
		except FileExistsError:
			pass
		self.path = "src/data/adrive/"
		for cmd in self.os_build_files:
			self.build_one(cmd)
		os.system(f"fasmg {self.path}src/main.asm {self.path}obj/main.bin")
		print("Compressing filesystem...")
		os.system(f"convbin -i {self.path}obj/main.bin -o {self.path}data.bin -j bin -k bin -c zx7")
		self.path = ""

	def build_os(self):
		os.system(f"fasmg {self.path}src/main.asm obj/bosos.bin")

	def build_rom(self):
		os.system(f"fasmg {self.path}src/rom.asm bin/BOSOS.rom")

	def build_installer(self):
		os.system(f"fasmg {self.path}src/installer8xp.asm bin/BOSOS.8xp")

	def build_updater(self):
		os.system(f"fasmg {self.path}src/updater.asm bin/BOSUPDTR.bin")

	def build_one(self, file):
		a = file.split(" ")
		if a[0].startswith("-c"):
			src_file, bin_file = a[1:]
			compressed = True
		else:
			src_file, bin_file = a
			compressed = False
		src_file = self.path+src_file
		bin_file = self.path+bin_file
		try:
			with open(src_file,"rb") as f:
				data = bytes(f.read())
				h = self.xsum(data)
				l = len(data)
		except IOError:
			h = None
		try:
			with open(bin_file,"rb") as f:
				pass
		except IOError:
			h = None
		print("Building:",src_file,end="  ")
		if src_file not in self.hash_table.keys():
			print("building binary:",bin_file)
			self.build_commands(src_file, bin_file, compressed)
		elif self.hash_table[src_file] != h or self.len_table[src_file] != l:
			print("updating existing binary:",bin_file)
			self.build_commands(src_file, bin_file, compressed)
		else:
			print("skipping already built file:",file)
		try:
			with open(src_file,"rb") as f:
				data = list(f.read())
				self.hash_table[src_file] = self.xsum(data)
				self.len_table[src_file] = len(data)
		except IOError:
			print("\tFailed to build!",src_file)
			self.exit()
		print()

	def build_commands(self, src_file, bin_file, compressed):
		os.system(f"fasmg {src_file} {bin_file}")
		if compressed:
			with open(bin_file,"rb") as f:
				f.seek(0,2)
				olen = f.tell()
			os.system(f"convbin -i {bin_file} -o {bin_file} -j bin -k bin -c zx7")
			with open(bin_file,"rb") as f:
				fin_data = [0x18,0x0C,0x43,0x52,0x58,0x00,0x7A,0x78,0x37,0x00]+\
					list(olen.to_bytes(3, 'little'))+list(f.read())
			with open(bin_file,"wb") as f:
				f.write(bytes(fin_data))


	def exit(self):
		if self.write_hashes(): exit(0)
		else: exit(1)

	def write_hashes(self):
		try:
			with open(self.hash_file,'w') as f:
				json.dump({"hashes":self.hash_table,"lengths":self.len_table}, f)
			return True
		except IOError:
			print("Failed to dump source hashes!")
			return False

	def xsum(self, data):
		m = hashlib.sha256()
		m.update(bytes(data))
		return m.hexdigest()

if __name__=='__main__':
	d = os.path.dirname(os.path.abspath(__file__))
	if len(d):
		os.system("cd "+d)

	with open("src/data/buildno.txt") as f:
		verdata = f.read().split(" ",maxsplit=3)

	if len(sys.argv)<2:
		Build(" ".join(verdata)).build()
		exit(0)

	fullBuild = doBuild = buildNoti = dobuilddocs = newVersion = copyIncludes = False
	i = 1
	while i<len(sys.argv):
		if sys.argv[i].startswith("-b") or sys.argv[i].startswith("--build"):
			doBuild = True
		elif sys.argv[i].startswith("-v") or sys.argv[i].startswith("--version"):
			newVersion = True
			if i+1<len(sys.argv):
				if not sys.argv[i+1].startswith("-"):
					verdata[1] = sys.argv[i+1]
					i+=2
					continue
			ver = verdata[1].split(".")
			ver[2] = str(int(ver[2])+1).rjust(4,"0")
			verdata[1] = ".".join(ver)
		elif sys.argv[i].startswith("-t") or sys.argv[i].startswith("--releasetype"):
			if i+1<len(sys.argv):
				data[2] = sys.argv[i+1]
				i+=2
			else:
				print("release type:",data[2])
		elif sys.argv[i].startswith("-?") or sys.argv[i].startswith("--getversion"):
			print(" ".join(data))
		elif sys.argv[i].startswith("-r") or sys.argv[i].startswith("--rebuild"):
			fullBuild = buildNoti = doBuild = True
		elif sys.argv[i].startswith("-d") or sys.argv[i].startswith("--builddocs"):
			dobuilddocs = True
		elif sys.argv[i].startswith("-n") or sys.argv[i].startswith("--buildnoti"):
			buildNoti = True
		elif sys.argv[i].startswith("-i") or sys.argv[i].startswith("--copyincludes"):
			copyIncludes = True
		elif sys.argv[i].startswith("-h") or sys.argv[i].startswith("--help"):
			print("""
Becks build script v3.2 build options
-b  --build                build unbuilt sources
-v  --version [num]        increment or set version number
-t  --releasetype          show or modify release type
-?  --getversion           show current version number
-r  --rebuild              rebuild all sources
-d  --builddocs            build documentation
-n  --buildnoti            build noti-ez80
-i  --copyincludes         copy include file directories (not usually needed)
-h  --help                 display help info
""")
		i+=1

	if newVersion:
		with open("src/data/buildno.txt",'w') as f:
			f.write(" ".join(verdata))

	if fullBuild:
		try:
			os.remove("obj/build_hashes.json")
		except OSError:
			pass

	b = Build(" ".join(verdata))
	if buildNoti:
		b.build_noti()
	if doBuild:
		b.build(copyIncludes)

	if dobuilddocs:
		from build_docs import build_docs
		build_docs()


