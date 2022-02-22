
;@DOES execute a file given a file path, passing arguments via argc/argv, starting it in 16 bit mode.
;@INPUT int sys_ExecuteFile16bpp(const char *path, int argc, char *argv[]);
;@DESTROYS All, OP6.
sys_ExecuteFile16bpp:
	jq sys_ExecuteFile

