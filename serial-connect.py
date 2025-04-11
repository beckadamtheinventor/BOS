
import os, sys, math, time, ctypes

try:
    import serial, serial.tools.list_ports
except ImportError:
    print("Dependency not found: please install pyserial")
    exit(1)


# if sys.platform.startswith("win32"):
	# def is_admin():
		# try:
			# return ctypes.windll.shell32.IsUserAnAdmin()
		# except:
			# return False
	# if not is_admin():
		# Re-run the program with admin rights
		# exit(ctypes.windll.shell32.ShellExecuteW(None, "runas", sys.executable, " ".join(sys.argv), None, 1))


ce_id = [(0x0451, 0xe008), (0x16C0, 0x05E1)]
max_packet_size = 4096
incoming_data_buffer_len = max_packet_size - 1

def WriteSerial(serial_device, data):
	if serial_device is None:
		return
	serial_device.write(len(data).to_bytes(3, 'little'))
	serial_device.write(data)
	time.sleep(0.05)

def WaitForAck(serial_device):
	for _ in range(1000):
		l = serial_device.read(3)
		if l is None or len(l) != 3:
			return []
		size = int.from_bytes(bytes(l), 'little')
		data = serial_device.read(size)
		if len(data):
			if data[0] == 4:
				print("Got Acknowledge packet")
			elif data[0] == 5:
				print("Device errored while receiving.")
				return []
			elif data[0] == 0:
				print("".join([chr(c) for c in data[1:]]))
			return data
		else:
			return []

def SendPackage(pack, serial_device):
	with open(pack, "r") as f:
		package = json.load(f)

	manifest = []
	if "directories" in package.keys():
		for i in range(len(package["directories"])):
			dname = package["directories"][i]
			if type(dname) is str:
				SendDirectory(dname)
				manifest.append(dname)
			elif type(dname) is list:
				SendDirectory("/".join(dname))
				manifest.append("/".join(dname))
			elif type(dname) is dict:
				print(f"Warning: directory {i} listed in package json is not a string or list. It will be ignored.")

	if "files" in package.keys():
		for i in range(len(package["files"])):
			f = package["files"][i]
			if type(f) is dict:
				if "source" in f.keys():
					source = f["source"]
					if not os.path.exists(source):
						print(f"Warning: file {i} listed in package json requires file \"{f['source']}\", but it is missing! Ignoring this entry.")
						continue
				else:
					print(f"Warning: file {i} listed in package json is missing required key \"source\". It will be ignored.")
					continue
				if "dest" in f.keys():
					dest = f["dest"]
					if type(dest) is list:
						dest = "/".join(dest)
					elif type(dest) is not str:
						print(f"Warning: file {i} listed in package json key \"dest\" is not a string or list. It will be ignored.")
						continue
				else:
					print(f"Warning: file {i} listed in package json is missing required key \"dest\". It will be ignored.")
					continue
				dest = dest.rstrip("/").rsplit("/", maxsplit=1)
				SendFile(source, dest, serial_device)
				manifest.append(dest)
			else:
				print(f"Warning: file {i} listed in package json is not an object. It will be ignored.")

	return manifest

def SendFile(path, devpath, serial_device, send_file=True):
	if serial_device is None:
		return False
	if send_file:
		try:
			with open(path, 'rb') as f:
				fdata = f.read()
		except FileNotFoundError:
			return False
		fname = "/" + os.path.basename(path)
		if len(devpath):
			if devpath.endswith("/"):
				fname = devpath + fname
			else:
				fname = devpath + "/" + fname
	else:
		fdata = path
		fname = devpath
	if len(fdata) > 65536:
		m = math.ceil(len(fdata)/65536)
		WriteSerial(serial_device, bytes([7] + list(len(fdata).to_bytes(3, 'little'))))
		for j in range(0, len(fdata), 65536):
			fdatablock = fdata[j:min(len(fdata),j+65536)]
			WriteSerial(serial_device, bytes([1] + list(len(fdatablock).to_bytes(3, 'little')) + [ord(c) for c in fname] + [0]))
			fname = name[:-1]+chr(0x30+j)+ext
			print(f"Sending File Block {j} of {m} file {fname}.")
			i = 0
			while i < len(fdatablock):
				# print("Writing to device...")
				WriteSerial(serial_device, bytes([0] + list(bytes(f"block {j}: {int(100*i/len(fdatablock))}%", 'UTF-8')) + [0]))
				WriteSerial(serial_device, bytes([2] + list(fdatablock[i:min(len(fdatablock),i+incoming_data_buffer_len)])))
				i += incoming_data_buffer_len
				print(f"{int(100*i/len(fdatablock))}%")
				# WaitForAck(serial_device)
				# return False
	else:
		WriteSerial(serial_device, bytes([1] + list(len(fdata).to_bytes(3, 'little')) + [ord(c) for c in fname] + [0]))
		i = 0
		print(f"Sending file {fname}")
		while i < len(fdata):
			# print("Writing to device...")
			WriteSerial(serial_device, bytes([0] + list(bytes(f"{int(100*i/len(fdata))}%", 'UTF-8')) + [0]))
			WriteSerial(serial_device, bytes([2] + list(fdata[i:min(len(fdata),i+incoming_data_buffer_len)])))
			i += incoming_data_buffer_len
			print(f"{int(100*i/len(fdata))}%", end=" ")
			# WaitForAck(serial_device)
			# return False
	print("\nDone.")
	return True

def SendDirectory(path, serial_device):
	WriteSerial(serial_device, bytes([6] + [ord(c) for c in path]))

def SendMessage(msg, dev):
	print(msg)
	WriteSerial(dev, bytes([0] + [ord(c) for c in msg] + [0]))

def RequestFile(path, serial_device):
	if serial_device is None:
		return False
	WriteSerial(serial_device, bytes([3] + [ord(c) for c in path] + [0]))
	headerpacket = WaitForAck(serial_device)
	if len(headerpacket) and headerpacket[0] == 1:
		filelen = int.from_bytes(headerpacket, 'little')
		filedata = []
		curlen = 0
		while True:
			packet = WaitForAck(serial_device)
			if not len(packet):
				break
			if packet[0] != 2:
				break
			curlen += len(packet)
			filedata.extend(list(packet))
		if curlen < filelen:
			print(f"Warning: recieved only {curlen} bytes of reported {filelen}")
		return True
	return False

def DirList(path, serial_device):
	if serial_device is None:
		return False
	while "//" in path: path = path.replace("//", "/")
	WriteSerial(serial_device, bytes([5] + [ord(c) for c in path] + [0]))
	return True
	# return WaitForAck(serial_device)

def ConnectCalcSerial():
	ports = [x for x in serial.tools.list_ports.comports() if (x.vid, x.pid) in ce_id]
	if len(ports) == 0:
		ports_manual=serial.tools.list_ports.comports()
		ct=0
		for p in ports_manual:
			print(f"{ct} {p}")
			ct+=1
		print(f"{ct} device not listed")
		sel=input("Select Device: ")
		if int(sel)==len(ports_manual):
			exit(1)
		else:
			serial_name = ports_manual[int(sel)].device
	else:
		serial_name = ports[0].device

	if len(ports) > 1:
		print("Multiple devices detected - using {}".format(serial_name))

	ex = None
	for _ in range(50):
		try:
			ser = serial.Serial(serial_name, timeout=5)
			return ser
		except Exception as e:
			ex = e
	print(ex)
	return None

def DisconnectCalcSerial(serial_device):
	try:
		serial_device.close()
	except:
		return False
	return True

print("""
BOS Serial File Transfer Program
--------------------------------
connect        | attempt to connect a calc
send file      | sends a file to the connected calc
sendpackage pk | sends files from a json formatted package
update         | send update package to the connected calc
request file   | request a file from the connected calc
dump file      | request a rom dump from the connected calc
list [dir]     | list files in a directory on the connected calc
message [msg]  | send a message to the connected calc (useful for debugging)
clear [msg]    | clear the console on the connected calc
quit           | disconnect and exit the program
--------------------------------
Note: on Linux systems, this program needs to be run with sudo
(or given raw usb access)
--------------------------------
""")
devpath = "/"
connected = False
serial_device = None
try:
	while True:
		line = input(f"{devpath}> ")
		if len(line):
			w = line.split(maxsplit=1)[0].lower()
			if w == "quit" or w == "q":
				break
			elif w == "connect":
				if connected:
					DisconnectCalcSerial(serial_device)
					connected = False
				serial_device = ConnectCalcSerial()
				if serial_device is not None:
					print("Connected successfuly.")
					connected = True
				else:
					print("Failed to connect.")
			elif connected:
				if w == "cd":
					if " " in line:
						p = line.split(maxsplit=1)[1]
						if p.startswith("/"):
							devpath = p
						else:
							while p.startswith(".."):
								p = p[2:].rstrip("/")
								if devpath != "/":
									devpath = "/" + "/".join(devpath.split("/")[:-1])
							devpath = devpath + "/" + p
				elif w == "update":
					part_1 = "/bin/BOSUPDTR.BIN"
					part_2 = "/bin/BOSOSPT2.BIN"
					if os.path.exists(part_1) and os.path.exists(part_2):
						SendDirectory("/tmp", serial_device)
						SendFile(part_1, "/tmp", serial_device)
						SendFile(part_2, "/tmp", serial_device)
						SendMessage(f"Run {part_1} to update BOS.", serial_device)
				elif w == "send":
					if SendFile(line.split(maxsplit=1)[1], devpath, serial_device):
						print("Sent file successfuly.")
					else:
						print("Failed to send file.")
				elif w == "list":
					if " " in line:
						p = line.split(maxsplit=1)[1]
						if p.startswith("/"):
							DirList(p, serial_device)
						else:
							DirList(devpath + "/" + p)
					else:
						DirList(devpath, serial_device)
				elif w == "request":
					p = line.split(maxsplit=1)[1]
					if not p.startswith("/"):
						p = devpath + "/" + p
					if RequestFile(p, serial_device):
						print("Recieved file successfuly.")
					else:
						print("Failed to recieve file.")
				elif w == "message" or w == "msg":
					if " " in line:
						SendMessage(line.split(maxsplit=1)[1], serial_device)
					else:
						SendMessage("", serial_device)
				elif w == "clear" or w == "cls":
					if " " in line:
						WriteSerial(serial_device, bytes([0, 1] + [ord(c) for c in line.split(maxsplit=1)[1]] + [0]))
					else:
						WriteSerial(serial_device, bytes([0, 1, 0]))
				elif w == "sendpackage":
					if SendPackage(line.split(maxsplit=1)[1], serial_device):
						print("Sent package successfuly")
					else:
						print("Failed to send package")
except KeyboardInterrupt:
	pass
except Exception as e:
	print(e)
	input()

if connected:
	DisconnectCalcSerial(serial_device)
