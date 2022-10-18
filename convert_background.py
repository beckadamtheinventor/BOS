
import os, sys, subprocess
from PIL import Image

def convert(fnamein, fnameout, mode=None):
	if mode not in [None, "zx0", "zx7"]:
		raise ValueError(f"Unsupported compression mode {mode}.")
	tmp = os.path.join(os.path.dirname(__file__), "obj", "tmp")
	if not os.path.exists(tmp):
		os.mkdir(tmp)
	with Image.open(fnamein) as img:
		img = img.resize((320, (img.height*320)//img.width))
		if img.height > 220:
			img = img.crop((0, 110-img.height//2, 320, 110+img.height//2))
		img.save(os.path.join(tmp, "image.png"))
	yaml = os.path.join(tmp, "convimg.yaml")
	with open(yaml, "w") as f:
		f.write(f"""
converts:
  - name: image
    palette: xlibc
    transparent-color-index: 0
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
	with open(fnameout,'wb') as f:
		if mode is None:
			f.write(b'IMG\0')
		elif mode == "zx7":
			f.write(b'IMG7')
		elif mode == "zx0":
			f.write(b'IMG0')
		f.write(data)

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
