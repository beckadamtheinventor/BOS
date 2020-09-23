#!/usr/bin/python3
import os
import zipfile
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
			yield root+"/"+file

def myfinder(d,df):
	for fname in fwalk(d):
		with open(fname) as fp:
			dt=fp.read().splitlines()
		for ix in range(len(dt)):
			if dt[ix].startswith(df):
				return dt,ix
	return [],0


try:
	with open("src/table.asm") as f:
		data=f.read().splitlines()
except Exception as e:
	error(e)
try:
	with open("src/include/defines.inc") as f:
		defines=f.read().splitlines()
except Exception as e:
	error(e)

counter=0x020108

try:
	os.remove("docs")
except:
	pass
try:
	os.makedirs("docs")
except:
	pass

with open("docs/style.css","w") as f:
	f.write("""
body{
	color: white;
	background-color: black;
	text-align: center;
}
th,tr,td{
	border-left: 1px solid white;
	border-top: 1px solid white;
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



print("Generating index.html")
with open("docs/index.html","w") as f:
	f.write("<html><head><title>bos.inc docs</title>\
<link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\"></head>\
<body>\
<h1>\"bos.inc\" documentation</h1>\
<h3>syscalls marked in <a class=\"no_op\">red</a> are no-ops and do nothing.</h3>\
<h3>Download <a href=\"sources.zip\">this archive</a> to view the source code</h3>\
<table><th>syscall name</th><th>syscall adress</th><th>links</th>\
")
	with open("docs/tmp","w") as f2:
		for line in data:
			if "jp " in line:
				e=[]
				line=line[line.find("jp ")+3:]
				if ";" in line:
					line=line[:line.find(";")]
				if line=="DONOTHING":
					f.write("<tr class=\"no_op\">")
				else:
					f.write("<tr>")
					f2.write("<div id=\""+line+"\"><h1>"+line+"</h1>\
<h3>syscall Adress "+myhex(counter)+"</h3>\n")
					f2.write("<table><th>Inputs</th><th>What it does</th><th>Outputs</th><th>Destroys</th><th>Notes</th>\n")
					a=[]; b=[]; c=[]; d=[]
					dt,ix=myfinder("src",line+":")
					if ix:
						try:
							while not dt[ix].startswith(";@DOES"):
								ix-=1
								if not ix: break
							while not dt[ix].startswith(line):
								if len(dt[ix])>1:
									t=dt[ix][1:]
									if t.startswith("@INPUT"):
										a.append(t.replace("@INPUT","").replace("\\n","<br>\n"))
									elif t.startswith("@DOES"):
										b.append(t.replace("@DOES","").replace("\\n","<br>\n"))
									elif t.startswith("@OUTPUT"):
										c.append(t.replace("@OUTPUT","").replace("\\n","<br>\n"))
									elif t.startswith("@DESTROYS"):
										d.append(t.replace("@DESTROYS","").replace("\\n","<br>\n"))
									elif t.startswith("@NOTE"):
										e.append(t.replace("@NOTE","").replace("\\n","<br>\n"))
									elif dt[ix][0]==";":
										pass
									else:
										break
								ix+=1
							f2.write("<tr><td>"+("<br>\n".join(a))+"</td><td>"+("<br>\n".join(b))+"</td><td>"+("<br>\n".join(c))+\
								"</td><td>"+("<br>\n".join(d))+"</td><td>\n"+("<br>\n".join(e))+"</td></tr>\n")
							a.clear(); b.clear(); c.clear(); d.clear(); e.clear()
						except:
							pass
					f2.write("</table></div>")
					# if ix and ":" not in dt[ix]:
						# f2.write("<div class=\"assembly\">\n")
						# while len(dt[ix]):
							# f2.write(dt[ix].replace("\t","<a class=\"stupid_tabs\">am I a tab to you?</a>",1)+"<br>\n")
							# ix+=1
							# if ix>=len(dt):
								# break
						# f2.write("</div>")

				f.write("<td>bos."+line+"</td><td>"+myhex(counter)+"</td><td><a href=\"#"+line+"\">doc</a></tr>\n")
				counter+=4
		
	f.write("</table>")
	print("Writing to index.html")
	with open("docs/tmp") as f2:
		f.write(f2.read())
	os.remove("docs/tmp")
	f.write("</body></html>")

print("Archiving \"src\" directory")
with zipfile.ZipFile("./docs/sources.zip",'w') as zf:
	for fname in fwalk("./src"):
		zf.write(fname)
	for fname in ["./build.bat","./build.sh","bos.inc","build_bos.inc.py","build_docs.py","LICENSE","README.md"]:
		zf.write(fname)

print("Done.")
