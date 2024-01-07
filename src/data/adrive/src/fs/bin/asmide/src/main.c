
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#include <bos.h>


int main(int argc, char *argv[]) {
	void *fd;
	AsmOpcodeData_t *opcdata;
	// check -h/--help argument
	if (argc > 1 && (!strcmp(argv[1], "-h") || !strcmp(argv[1], "--help"))) {
		gui_PrintLine("Usage: asmide [file]");
	}

	// locate opcode definitions file
/* 	if ((fd = sys_OpenFileInVar(ASM_DEF_FILE, SHARED_VAR)) == -1) { */
	if ((fd = fs_OpenFile(ASM_DEF_FILE)) == -1) {
		gui_PrintLine("Failed to locate "ASM_DEF_FILE);
		return -1;
	}
	// load opcodes
	opcdata = fs_GetFDPtr(fd);
	for (int i=0; i<256*5; i++) {
		OpcodeData[i] = opcdata;
		opcdata = opcdata->opcstring + strlen(opcdata->opcstring);
	}
	// argument parsing
	if (argc > 1) {
		
	}
	
	
	
	
	return 0;
}

