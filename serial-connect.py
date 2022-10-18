
import os, sys, ctypes

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


ce_id = (0x0451, 0xe008)
max_packet_size = 513


def WriteSerial(serial_device, data):
	serial_device.write(len(data).to_bytes(3, 'little'))
	serial_device.write(data)

def WaitForAck(serial_device):
	for _ in range(1000):
		l = serial_device.read(3)
		if l is None or len(l) != 3:
			return False
		size = int.from_bytes(bytes(l), 'little')
		data = serial_device.read(size)
		if len(data):
			if data[0] == 4:
				print("Got Acknowledge packet")
				return True
			elif data[0] == 0:
				print("".join([chr(c) for c in data[1:]]))
		else:
			return False


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
	name, ext = os.path.splitext(os.path.basename(path))
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
	WriteSerial(serial_device, bytes([1] + list(len(fdata).to_bytes(3, 'little')) + [ord(c) for c in fname] + [0]))
	if not WaitForAck(serial_device):
		return False
	i = 0
	while i < len(fdata):
		WriteSerial(serial_device, bytes([2] + list(fdata[i:i+max_packet_size-1])))
		i += max_packet_size-1
		if not WaitForAck(serial_device):
			return False
	return True

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
	return WaitForAck(serial_device)

def ConnectCalcSerial():
	ports = [x for x in serial.tools.list_ports.comports() if (x.vid, x.pid) == ce_id]
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
except KeyboardInterrupt:
	pass
except Exception as e:
	print(e)
	input()

if connected:
	DisconnectCalcSerial(serial_device)
