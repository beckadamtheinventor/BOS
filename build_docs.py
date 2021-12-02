#!/usr/bin/python3
import os
def error(e):
	print("Something went wrong building!\nError:",e)
	quit()

def myhex(n):
	h="0123456789ABCDEF"
	l=[]
	for x in range(6):
		l.insert(0,h[n%16])
		n//=16
	return "".join(l)

def fwalk(d):
	for root, dirs, files in os.walk(d):
		for file in files:
			yield root.replace("\\","/")+"/"+file

def FindTextInFiles(dirlist, df):
	for fname in dirlist:
		if fname.endswith(".asm"):
			try:
				with open(fname) as fp:
					dt=fp.read().split("\n")
			except FileNotFoundError:
				print("failed to read file",fname)
				continue
			for ix in range(len(dt)):
				if dt[ix].startswith(df):
					return dt,ix
	return [],0

def build_docs():
	try:
		with open("src/table.asm") as f:
			data=f.read().split("\n")
	except Exception as e:
		error(e)
	try:
		with open("src/include/defines.inc") as f:
			defines=f.read().split("\n")
	except Exception as e:
		error(e)

	SrcDirListing = [fname for fname in fwalk("src")]
	# for fname in SrcDirListing:
		# print(fname)

	counter=0x020108

	try:
		os.makedirs("docs")
	except:
		pass

	with open("docs/style.css","w") as f:
		f.write("""
	html{
		background-color: #000500;
	}
	body{
		margin: 0 auto;
		width: 960px;
		font-size: 100%;
		line-height: 1.5;
		color: white;
		background-color: #121;
		text-align: center;
	}
	ul{
		text-align: left;
	}
	th,tr,td{
		border-left: 1px solid #eef;
		border-top: 1px solid #dde;
	}
	th,td{
		width: 20%;
	}
	table{
		border-right: 1px solid white;
		border-bottom: 1px solid white;
		position: relative;
		left: 2%;
		width: 96%;
	}
	a {
		color: #aaa;
	}
	a:visited {
		color: #aae;
	}
	a:hover {
		color: #22e;
	}
	.no_op{
		color: #C02020;
	}
	.assembly{
		color: #4F1;
		background-color: #111;
		border: 1px dotted black;
		padding-left: 45%;
		text-align: left;
	}
	.stupid_tabs{
		color: #111;
		font-size: 2.5;
	}
	""")



	print("Generating syscalls.html")
	with open("docs/syscalls.html","w") as f:
		f.write("<html><head><title>bos.inc docs</title>\
	<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head>\
	<body>\
	<h1>\"bos.inc\" documentation</h1>\
	<b>\"bos.DONOTHING\" is a no-op and does nothing,</b><br>As the name implies.\
	<table><th>syscall name</th><th>syscall adress</th>\
	")
		with open("docs/tmp.html","w") as f2:
			for lx in range(len(data)):
				line = data[lx]
				# print(line)
				if "jp " in line:
					e=[]
					line=line[line.find("jp ")+3:]
					if ";" in line:
						line=line[:line.find(";")]
					if "DONOTHING" in line:
						f.write("<tr class=\"no_op\"></tr>")
					else:
						f.write("<tr>")
						f2.write("<div id=\""+line+"\"><h1>"+line+"</h1>\
	<h3>syscall Adress "+myhex(counter)+"</h3>\n")
						f2.write("<table><th>What it does</th><th>Inputs</th><th>Outputs</th><th>Destroys</th><th>Notes</th>\n")
						a=[]; b=[]; c=[]; d=[]
						dt,ix=FindTextInFiles(SrcDirListing,line+":")
						if ix>0:
							while not dt[ix].startswith(";@DOES"):
								ix-=1
								if not ix: break
							while not dt[ix].startswith(line):
								if len(dt[ix])>1:
									t=dt[ix][1:]
									if t.startswith("@DOES "):
										a.append(t.replace("@DOES ","").replace("\\n","<br>\n"))
									elif t.startswith("@INPUT "):
										b.append(t.replace("@INPUT ","").replace("\\n","<br>\n"))
									elif t.startswith("@OUTPUT "):
										c.append(t.replace("@OUTPUT ","").replace("\\n","<br>\n"))
									# elif t.startswith("@DESTROYS "):
										# d.append(t.replace("@DESTROYS ","").replace("\\n","<br>\n"))
									elif t.startswith("@NOTE "):
										e.append(t.replace("@NOTE ","").replace("\\n","<br>\n"))
								ix+=1
							f2.write("<tr><td>"+("<br>\n".join(a))+"</td><td>"+("<br>\n".join(b))+"</td><td>"+("<br>\n".join(c))+\
								"</td><td>"+("<br>\n".join(d))+"</td><td>\n"+("<br>\n".join(e))+"</td></tr>\n")
						f2.write("</table></div>")
						# if ix and ":" not in dt[ix]:
							# f2.write("<div class=\"assembly\">\n")
							# while len(dt[ix]):
								# f2.write(dt[ix].replace("\t","<a class=\"stupid_tabs\">am I a tab to you?</a>",1)+"<br>\n")
								# ix+=1
								# if ix>=len(dt):
									# break
							# f2.write("</div>")

					f.write("<td><a href=\"#"+line+"\">bos."+line+"</a></td><td><a href=\"#"+line+"\">"+myhex(counter)+"</a></td></tr>\n")
					counter+=4
			
		f.write("</table>")
		print("Writing to syscalls.html")
		with open("docs/tmp.html") as f2:
			f.write(f2.read())
		os.remove("docs/tmp.html")
		f.write("</body></html>")

#	print("Archiving \"src\" directory")
#	with zipfile.ZipFile("./docs/sources.zip",'w') as zf:
#		for fname in fwalk("./src"):
#			zf.write(fname)
#		for fname in ["build.py","bos.inc","build_bos_inc.py","build_docs.py","LICENSE","README.md"]:
#			zf.write(fname)
#
#	print("Done.")

if __name__=='__main__':
    build_docs()
