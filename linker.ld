ENTRY(bootloader_start)
OUTPUT_ARCH(i386)
OUTPUT_FORMAT("binary")

SECTIONS {
	. = 0x7C00;
	.mbr.text : AT(0x00) {
		*(.mbr.text)
	}
	
	.mbr.data : AT( 0x00 + SIZEOF(.mbr.text) ) {
		*(.mbr.data)
	}

	.mbr.sig : AT(0x200 - 2) {
		*(.mbr.sig)
	}

	. = 0x8000;
	.text : AT (0x200) {
		*(.text)
	}

	.data : AT (0x200+SIZEOF(.text)+1) {
		*(.data)
	}

	. = 0x9000;
	.bss : {
		*(.bss)
	}

	. = 0xA000;
	.framebuf : {
		*(.framebuf)
	}

}
