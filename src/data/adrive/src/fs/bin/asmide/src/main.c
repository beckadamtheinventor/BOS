
#include <stdint.h>
#include <string.h>
#include <stdbool.h>

#include <bos.h>

const char *ASM_DEF_FILE = "/opt/asmide/ASMIopc.dat";

/*
const char *ASM_DEF_FILE = "ASMIopc.dat";
const char *SHARED_VAR = "SHARE";
*/

typedef uint8_t argument_t;

#define ARG_OFFSET       3 << 0 // offset of argument byte (discounting first opcode byte)
#define ARG_BYTE         1 << 2
#define ARG_WORD         1 << 3
#define ARG_RELBYTE      1 << 4
#define ARG_IXY_OFFSET   1 << 5

typedef struct __AsmOpcodeData_t {
	argument_t argument; // opcode argument length and type
	uint8_t opcode[4]; // opcode bytes (4 bytes)
	char opcstring[]; // null-terminated opcode string
} AsmOpcodeData_t;


AsmOpcodeData_t *OpcodeData[256*5];


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

