
import os, sys, subprocess
from PIL import Image, ImagePalette

xlibc_palette = ImagePalette.ImagePalette("RGB", [0, 0, 0, 0, 32, 8, 0, 65, 16, 0, 97, 24, 0, 130, 32, 0, 162, 40, 0, 195, 48, 0, 227, 56, 8, 0, 65, 8, 32, 73, 8, 65, 81, 8, 97, 89, 8, 130, 97, 8, 162, 105, 8, 195, 113, 8, 227, 121, 16, 0, 134, 16, 32, 142, 16, 65, 150, 16, 97, 158, 16, 130, 166, 16, 162, 174, 16, 195, 182, 16, 227, 190, 24, 0, 199, 24, 32, 207, 24, 65, 215, 24, 97, 223, 24, 130, 231, 24, 162, 239, 24, 195, 247, 24, 227, 255, 32, 4, 0, 32, 36, 8, 32, 69, 16, 32, 101, 24, 32, 134, 32, 32, 166, 40, 32, 199, 48, 32, 231, 56, 40, 4, 65, 40, 36, 73, 40, 69, 81, 40, 101, 89, 40, 134, 97, 40, 166, 105, 40, 199, 113, 40, 231, 121, 48, 4, 134, 48, 36, 142, 48, 69, 150, 48, 101, 158, 48, 134, 166, 48, 166, 174, 48, 199, 182, 48, 231, 190, 56, 4, 199, 56, 36, 207, 56, 69, 215, 56, 101, 223, 56, 134, 231, 56, 166, 239, 56, 199, 247, 56, 231, 255, 65, 8, 0, 65, 40, 8, 65, 73, 16, 65, 105, 24, 65, 138, 32, 65, 170, 40, 65, 203, 48, 65, 235, 56, 73, 8, 65, 73, 40, 73, 73, 73, 81, 73, 105, 89, 73, 138, 97, 73, 170, 105, 73, 203, 113, 73, 235, 121, 81, 8, 134, 81, 40, 142, 81, 73, 150, 81, 105, 158, 81, 138, 166, 81, 170, 174, 81, 203, 182, 81, 235, 190, 89, 8, 199, 89, 40, 207, 89, 73, 215, 89, 105, 223, 89, 138, 231, 89, 170, 239, 89, 203, 247, 89, 235, 255, 97, 12, 0, 97, 44, 8, 97, 77, 16, 97, 109, 24, 97, 142, 32, 97, 174, 40, 97, 207, 48, 97, 239, 56, 105, 12, 65, 105, 44, 73, 105, 77, 81, 105, 109, 89, 105, 142, 97, 105, 174, 105, 105, 207, 113, 105, 239, 121, 113, 12, 134, 113, 44, 142, 113, 77, 150, 113, 109, 158, 113, 142, 166, 113, 174, 174, 113, 207, 182, 113, 239, 190, 121, 12, 199, 121, 44, 207, 121, 77, 215, 121, 109, 223, 121, 142, 231, 121, 174, 239, 121, 207, 247, 121, 239, 255, 134, 16, 0, 134, 48, 8, 134, 81, 16, 134, 113, 24, 134, 146, 32, 134, 178, 40, 134, 211, 48, 134, 243, 56, 142, 16, 65, 142, 48, 73, 142, 81, 81, 142, 113, 89, 142, 146, 97, 142, 178, 105, 142, 211, 113, 142, 243, 121, 150, 16, 134, 150, 48, 142, 150, 81, 150, 150, 113, 158, 150, 146, 166, 150, 178, 174, 150, 211, 182, 150, 243, 190, 158, 16, 199, 158, 48, 207, 158, 81, 215, 158, 113, 223, 158, 146, 231, 158, 178, 239, 158, 211, 247, 158, 243, 255, 166, 20, 0, 166, 52, 8, 166, 85, 16, 166, 117, 24, 166, 150, 32, 166, 182, 40, 166, 215, 48, 166, 247, 56, 174, 20, 65, 174, 52, 73, 174, 85, 81, 174, 117, 89, 174, 150, 97, 174, 182, 105, 174, 215, 113, 174, 247, 121, 182, 20, 134, 182, 52, 142, 182, 85, 150, 182, 117, 158, 182, 150, 166, 182, 182, 174, 182, 215, 182, 182, 247, 190, 190, 20, 199, 190, 52, 207, 190, 85, 215, 190, 117, 223, 190, 150, 231, 190, 182, 239, 190, 215, 247, 190, 247, 255, 199, 24, 0, 199, 56, 8, 199, 89, 16, 199, 121, 24, 199, 154, 32, 199, 186, 40, 199, 219, 48, 199, 251, 56, 207, 24, 65, 207, 56, 73, 207, 89, 81, 207, 121, 89, 207, 154, 97, 207, 186, 105, 207, 219, 113, 207, 251, 121, 215, 24, 134, 215, 56, 142, 215, 89, 150, 215, 121, 158, 215, 154, 166, 215, 186, 174, 215, 219, 182, 215, 251, 190, 223, 24, 199, 223, 56, 207, 223, 89, 215, 223, 121, 223, 223, 154, 231, 223, 186, 239, 223, 219, 247, 223, 251, 255, 231, 28, 0, 231, 60, 8, 231, 93, 16, 231, 125, 24, 231, 158, 32, 231, 190, 40, 231, 223, 48, 231, 255, 56, 239, 28, 65, 239, 60, 73, 239, 93, 81, 239, 125, 89, 239, 158, 97, 239, 190, 105, 239, 223, 113, 239, 255, 121, 247, 28, 134, 247, 60, 142, 247, 93, 150, 247, 125, 158, 247, 158, 166, 247, 190, 174, 247, 223, 182, 247, 255, 190, 255, 28, 199, 255, 60, 207, 255, 93, 215, 255, 125, 223, 255, 158, 231, 255, 190, 239, 255, 223, 247, 255, 255, 255])


def convert(fnamein, fnameout, mode=None):
	if mode not in [None, "zx0", "zx7"]:
		raise ValueError(f"Unsupported compression mode {mode}.")
	tmp = os.path.join(os.path.dirname(__file__), "obj", "tmp")
	if not os.path.exists(tmp):
		os.mkdir(tmp)
	with Image.open(fnamein) as img:
		img = img.resize((320, (img.height*320)//img.width))
		if img.height > 220:
			img = img.crop((0, 0, 320, 220))
		# img = img.convert("RGB").quantize(palette=Image.open(os.path.join(os.path.dirname(__file__), "xlibc_palette.png")).convert("P"))
		img = img.convert("RGB").convert("P", palette=xlibc_palette)
		img.save(os.path.join(tmp, "image.png"))
	yaml = os.path.join(tmp, "convimg.yaml")
	with open(yaml, "w") as f:
		f.write(f"""
converts:
  - name: image
    palette: xlibc
    transparent-color-index: 0
    width-and-height: false
    images:
      - image.png

outputs:
  - type: bin
    converts:
      - image
""")
	subprocess.run(["convimg"],cwd=tmp)
	imgbin = os.path.join(tmp, "image.bin")
	with open(imgbin,'rb') as f:
		f.seek(2, 0)
		data = f.read()
	with open(imgbin,'wb') as f:
		f.write(data)
	if mode is not None:
		subprocess.run(["convbin", "-i", imgbin, "-o", imgbin, "-j", "bin", "-k", "bin", "-c", mode])
		with open(imgbin,'rb') as f:
			data = f.read()
	with open(fnameout, 'wb') as f:
		if mode is None:
			f.write(b'IMG\0')
		elif mode == "zx7":
			f.write(b'IMG7')
		elif mode == "zx0":
			f.write(b'IMG0')
		f.write(data)
		size = f.tell()
	print(f"Finished. Output size: {size} bytes")

if __name__=='__main__':
	if len(sys.argv) < 2:
		print("Usage: convert_background.py [-c zx0|zx7] image.png [...]\n-c specifies compression mode.")
	else:
		if not os.path.exists("backgrounds"):
			os.mkdir("backgrounds")
		
		compressionmode = None
		processedargs = []
		for i in range(1, len(sys.argv)):
			if sys.argv[i] == "-c" and i+1 < len(sys.argv):
				compressionmode = sys.argv[i+1].lower()
				processedargs.append(i)
				processedargs.append(i+1)

		for i in range(1, len(sys.argv)):
			if i not in processedargs:
				arg = sys.argv[i]
				convert(arg, os.path.join("backgrounds", os.path.basename(arg).rsplit(".",maxsplit=1)[0]+".bin"), compressionmode)
