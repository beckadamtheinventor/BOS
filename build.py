#!/usr/bin/python3

import sys,os,json


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

			"src/bpkload.asm obj/bpkload.bin",
			"src/explorer.asm obj/explorer.bin",
			"src/files.asm obj/files.bin",
			"src/fexplore.asm obj/fexplore.bin",
			"src/memedit.asm obj/memedit.bin",
			"src/usbrun.asm obj/usbrun.bin",
			"src/usbsend.asm obj/usbsend.bin",
			"src/usbrecv.asm obj/usbrecv.bin",

			"src/dev_mnt/init.asm src/dev_mnt/init.bin",
			"src/dev_mnt/deinit.asm src/dev_mnt/deinit.bin",
			"src/dev_mnt/read.asm src/dev_mnt/read.bin",
			"src/dev_mnt/write.asm src/dev_mnt/write.bin"

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

	def build(self):
		print("building",self.ver)
		try:
			os.mkdir("bin")
		except FileExistsError:
			pass
		try:
			os.mkdir("obj")
		except FileExistsError:
			pass
		self.build_include()
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
		from build_docs import build_docs
		build_docs()

	def build_include(self):
		from build_bos_inc import build_bos_inc
		build_bos_inc()
		if sys.platform.startswith('win') or sys.platform.startswith("cygwin"):
			os.system("""xcopy /Y bos.inc src\\include\\
xcopy /Y src\\include src\\data\adrive\\src\\include\\
xcopy /Y src\\data\\adrive\\src\\include src\\data\\adrive\\src\\lib\\include\\""")
		else:
			os.system("""cp -f bos.inc src/include/bos.inc
cp -rf src/include src/data/adrive/src/
cp -rf src/data/adrive/src/include src/data/adrive/src/lib/""")

	def build_noti(self):
		print("Building noti-ez80")
		if sys.platform.startswith('win') or sys.platform.startswith("cygwin"):
			os.system("cd noti-ez80\ncall build.bat\ncd ..")
		else:
			os.system("cd noti-ez80\nbash build.sh\ncd ..")

	def build_filesystem(self):
		self.path = "src/data/adrive/"
		if sys.platform.startswith('win') or sys.platform.startswith("cygwin"):
			os.system("cd src\\data\\adrive\\")
		else:
			os.system("cd src/data/adrive/")
		for cmd in self.os_build_files:
			self.build_one(cmd)
		os.system(f"fasmg {self.path}src/main.asm {self.path}obj/main.bin\nconvbin -i {self.path}obj/main.bin -o {self.path}data.bin -j bin -k bin -c zx7")
		if sys.platform.startswith('win') or sys.platform.startswith("cygwin"):
			os.system("cd ..\\..\\..\\")
		else:
			os.system("cd ../../../")
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
		src_file, bin_file = file.split(" ")
		src_file = self.path+src_file
		bin_file = self.path+bin_file
		try:
			with open(src_file,"rb") as f:
				data = list(f.read())
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
			os.system(f"fasmg {src_file} {bin_file}")
		elif self.hash_table[src_file] != h or self.len_table[src_file] != l:
			print("updating existing binary:",bin_file)
			os.system(f"fasmg {src_file} {bin_file}")
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


	def exit(self):
		if self.write_hashes(): exit(0)
		else: exit(1)

	def write_hashes(self):
		try:
			with open(self.hash_file,"w") as f:
				json.dump({"hashes":self.hash_table,"lengths":self.len_table}, f)
			return True
		except IOError:
			print("Failed to dump source hashes!")
			return False

	def xsum(self,data):
		i = 0xFFFFFFFF
		for c in data:
			i = i^(c*(0x100**(i&3))) + c
		return i

if __name__=='__main__':
	d = os.path.dirname(__file__)
	if len(d):
		os.system("cd "+d)

	with open("src/data/buildno.txt") as f:
		verdata = f.read().split(" ",maxsplit=3)

	if len(sys.argv)<2:
		Build(" ".join(verdata)).build()
		exit(0)

	fullBuild = doBuild = buildNoti = False
	i = 1
	while i<len(sys.argv):
		if sys.argv[i].startswith("-b") or sys.argv[i].startswith("--build"):
			doBuild = True
		elif sys.argv[i].startswith("-v") or sys.argv[i].startswith("--version"):
			if i+1<len(sys.argv):
				if not sys.argv[i+1].startswith("-"):
					ver = verdata[1].split(".")
					ver[2] = sys.argv[i+1]
					verdata[1] = ".".join(ver)
					i+=1
					continue
			ver = verdata[1].split(".")
			ver[2] = str(int(ver[2])+1).rjust(4,"0")
			verdata[1] = ".".join(ver)
		elif sys.argv[i].startswith("-t") or sys.argv[i].startswith("--release-type"):
			if i+1<len(sys.argv):
				data[2] = sys.argv[i+1]
				i+=1
			else:
				print("release type:",data[2])
		elif sys.argv[1].startswith("-?") or sys.argv[i].startswith("--get-version"):
			print(" ".join(data))
		elif sys.argv[1].startswith("-r") or sys.argv[1].startswith("--rebuild"):
			fullBuild = buildNoti = doBuild = True
		elif sys.argv[1].startswith("-h") or sys.argv[1].startswith("--help"):
			print("""
Becks build script v3.1 build options
-b  --build                build unbuilt sources
-v  --version [num]        increment or set version number
-t  --release-type         show or modify release type
-?  --get-version          show current version number
-r  --rebuild              rebuild all sources
-h  --help                 display help info
""")
		i+=1

	with open("src/data/buildno.txt","w") as f:
		f.write(" ".join(verdata))

	if fullBuild:
		try:
			os.remove("obj/build_hashes.json")
		except OSError:
			pass

	if doBuild:
		b = Build(" ".join(verdata))
		if buildNoti:
			b.build_noti()
		b.build()


