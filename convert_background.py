
import os, sys, subprocess
from PIL import Image

def convert(fnamein, fnameout):
	tmp = os.path.join(os.path.dirname(__file__), "obj", "tmp")
	if not os.path.exists(tmp):
		os.mkdir(tmp)
	with Image.open(fnamein) as img:
		img = img.resize((320, (img.height*320)//img.width))
		if img.height > 200:
			img = img.crop((0, 100-img.height//2, 320, 100+img.height//2))
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
	subprocess.run(["convbin", "-i", imgbin, "-o", imgbin, "-j", "bin", "-k", "bin", "-c", "zx7"])
	with open(imgbin,'rb') as f:
		data = f.read()
	with open(fnameout,'wb') as f:
		f.write(b'IMG7')
		f.write(data)

if __name__=='__main__':
	if len(sys.argv) < 2:
		print("Usage: convert_background.py image.png [...]")
	else:
		if not os.path.exists("backgrounds"):
			os.mkdir("backgrounds")
		for arg in sys.argv[1:]:
			convert(arg, os.path.join("backgrounds", os.path.basename(arg).rsplit(".",maxsplit=1)[0]+".bin"))
