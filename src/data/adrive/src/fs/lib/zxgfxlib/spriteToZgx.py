
class ZGXSprite:
	def __init__(self, data=None):
		self.setData(data)

	def setData(self, data):
		self.data = data
		self.h = len(self.data)
		if self.h > 0:
			self.w = len(self.data[0])
		else:
			self.w = 0

	def convert(self, output=[]):
		self.pal = []
		for row in self.data:
			for val in row:
				if val not in self.pal:
					self.pal.append(val)
		if len(self.pal)<8:
			self.pal.extend([0]*(8-len(self.pal)))
		elif len(self.pal)>8:
			return None
		output.extend(self.pal)
		y = 0
		while y < self.h:
			x = 0
			while x < self.w:
				N = 0
				A = self.pal.index(self.data[y][x])
				B = self.pal.index(self.data[y][x+1])
				for J in range(4):
					if x+J*2 < self.w:
						if self.pal.index(self.data[y][x+J*2]) == A and self.pal.index(self.data[y][x+J*2+1]) == B:
							N += 1
							continue
					break
				C = A + B*8 + (N-1)*64
				#print(bin(A), bin(B), "x",bin(N), "=",bin(C))
				output.append(C)
				x += N*2
			y += 1
		return output

if __name__=='__main__':
	import sys, os
	if len(sys.argv)<3:
		print("Arguments:\n\tsprite_csv_file output_data_file")
		exit(1)
	try:
		with open(sys.argv[1]) as f:
			data = [line.split(",") for line in f.read().split("\n")]
	except IOError:
		print(f"Error: File {sys.argv[1]} does not exist or is not a valid csv file!")
		exit(1)
	intdata = []
	for row in data:
		intdata.append([int(c) for c in row])

	sprite = ZGXSprite(intdata)
	output_data = sprite.convert()
	if output_data is None:
		print("Error: Failed to convert sprite data. Check that there are only 8 unique pixels.")
		exit(1)
	print(f"Output length: {str(len(output_data))} bytes.")
	try:
		with open(sys.argv[2],"w") as f:
			f.write("\tdb $"+", $".join([hex(c)[2:] for c in output_data]))
	except IOError:
		print(f"Error: Failed to write output file {sys.argv[2]}\n")
		exit(1)


