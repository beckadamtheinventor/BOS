
import os, sys

try:
    import serial, serial.tools.list_ports
except ImportError:
    print("Dependency not found: please install pyserial")
    exit(1)

ce_id = (0x0451, 0xe008)
max_packet_size = 513

serial_device = None

def WaitForAck():
	global serial_device
	try:
		size = int.from_bytes(serial_device.read(3), 'little')
		data = serial_device.read(size)
	except:
		return False
	if data[0] != 4:
		return False
	return True


def SendFile(path):
	global serial_device
	if serial_device is None:
		if not ConnectCalcSerial():
			return False
	try:
		with open(path, 'rb') as f:
			fdata = f.read()
	except FileNotFoundError:
		return False
	name, ext = os.path.splitext(os.path.basename(path))
	# fname = name[:min(len(name),8)] + "." + ext[:min(len(ext),3)]
	while len(ext) > 3 or len(name) > 8:
		print("File name must fit in 8.3 characters. Example: abcdefgh.jkl")
		name, ext = os.path.splitext(os.path.basename(input("File name on calc?")))
	fname = name + "." + ext
	serial_device.write(bytes([1] + list(len(fdata).to_bytes(3, 'little')) + [ord(c) for c in fname] + [0]))
	if not WaitForAck():
		return False

	try:
		i = 0
		while i < len(fdata):
			serial_device.write(bytes([2] + list(fdata[i:i+max_packet_size-1])))
			i += max_packet_size-1
			if not WaitForAck():
				return False
	except:
		return False

	return True

def RequestFile(path):
	global serial_device
	# if serial_device is None:
	return False

def DirList(path):
	global serial_device
	# if serial_device is None:
	return False

def ConnectCalcSerial():
	global serial_device
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
		ser = serial.Serial(serial_name, timeout=None)
	except Exception as e:
		print(e)
		return False
	# ser.port = serial_name
	# ser.baudrate = 115200
	ser_in = ser
	ser_out = ser
	# try:
		# ser.open()
	# except:
		# return False
	serial_device = ser
	return True

def DisconnectCalcSerial():
	try:
		serial_device.close()
	except:
		return False
	serial_device = None
	return True

print("""
BOS Serial File Transfer Program
--------------------------------
connect      | attempt to connect a calc
send file    | sends a file to the connected calc
request file | request a file from the connected calc
list [dir]   | list files in a directory on the connected calc
quit         | disconnect and exit the program
--------------------------------
""")
devpath = ""
connected = False
try:
	while True:
		line = input(f"{devpath}> ")
		if len(line):
			w = line.split()[0].lower()
			if w == "quit":
				break
			elif w == "connect":
				if connected:
					DisconnectCalcSerial()
					connected = False
				if ConnectCalcSerial():
					print("Connected successfuly.")
					connected = True
				else:
					print("Failed to connect.")
			elif connected:
				if w == "send":
					if SendFile(line.split(maxsplit=1)[1]):
						print("Sent file successfuly.")
					else:
						print("Failed to send file.")
				# elif w == "request":
					# if RequestFile(line.split(maxsplit=1)[1]):
						# print("Recieved file successfuly.")
					# else:
						# print("Failed to recieve file.")
except KeyboardInterrupt:
	if connected:
		DisconnectCalcSerial()

