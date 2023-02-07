
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
max_packet_size = 1024
incoming_data_buffer_len = max_packet_size - 1

def WriteSerial(serial_device, data):
	serial_device.write(len(data).to_bytes(3, 'little'))
	serial_device.write(data)
	time.sleep(0.1)

# def WaitForAck(serial_device):
	# for _ in range(1000):
		# l = serial_device.read(3)
		# if l is None or len(l) != 3:
			# return False
		# size = int.from_bytes(bytes(l), 'little')
		# data = serial_device.read(size)
		# if len(data):
			# if data[0] == 4:
				# print("Got Acknowledge packet")
				# return True
			# elif data[0] == 5:
				# print("Device errored while receiving.")
				# return False
			# elif data[0] == 0:
				# print("".join([chr(c) for c in data[1:]]))
		# else:
			# return False

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
				SendFile(source, dest.rstrip("/").rsplit("/", maxsplit=1), serial_device)
			else:
				print(f"Warning: file {i} listed in package json is not an object. It will be ignored.")

def SendFile(path, devpath, serial_device):
	if serial_device is None:
		serial_device = ConnectCalcSerial()
		if serial_device is None:
			return False
	try:
		with open(path, 'rb') as f:
			fdata = f.read()
	except FileNotFoundError:
		return False
	if '.' in path:
		name, ext = os.path.splitext(os.path.basename(path))
	else:
		name = path
		ext = ""
	# fname = name[:min(len(name),8)] + "." + ext[:min(len(ext),3)]
	while len(ext) > 4 or len(name) > 8:
		print("File name must fit in 8.3 characters. Example: abcdefgh.jkl")
		name, ext = os.path.splitext(os.path.basename(input("File name on calc?")))
	fname = name + ext
	if len(devpath):
		if devpath.endswith("/"):
			fname = devpath + fname
		else:
			fname = devpath + "/" + fname
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
		print()
		return True

def SendDirectory(path, serial_device):
	WriteSerial(serial_device, bytes([6] + [ord(c) for c in path]))

def RequestFile(path, serial_device):
	if serial_device is None:
		serial_device = ConnectCalcSerial()
		if serial_device is None:
			return False
	return False

def DirList(path, serial_device):
	if serial_device is None:
		serial_device = ConnectCalcSerial()
		if serial_device is None:
			return False

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

	try:
		ser = serial.Serial(serial_name, timeout=5)
	except Exception as e:
		print(e)
		return None
	return ser

def DisconnectCalcSerial(serial_device):
	try:
		serial_device.close()
	except:
		return False
	return True

print("""
BOS Serial File Transfer Program
--------------------------------
connect      | attempt to connect a calc
send file    | sends a file to the connected calc
request file | request a file from the connected calc
list [dir]   | list files in a directory on the connected calc
message      | send a message to the connected calc (useful for debugging)
quit         | disconnect and exit the program
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
				if w == "send":
					if SendFile(line.split(maxsplit=1)[1], devpath, serial_device):
						print("Sent file successfuly.")
					else:
						print("Failed to send file.")
				elif w == "dirlist":
					DirList(devpath, serial_device)
				# elif w == "request":
					# if RequestFile(line.split(maxsplit=1)[1]):
						# print("Recieved file successfuly.")
					# else:
						# print("Failed to recieve file.")
				elif w == "message" or w == "msg":
					WriteSerial(serial_device, bytes([0] + [ord(c) for c in line.split(maxsplit=1)[1]] + [0]))
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
