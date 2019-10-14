cpu 8086
bits 16

%include "src/consts.inc"

extern start

;; When the CPU starts, cs=0xFFFF, so the code here is expected
;; to be loaded at FFFF:0000. The ROM chip is set to enable when
;; the top bits of the address are F. So the purpose of this function
;; is to call start with code segment 0xF000 so the rom chip is selected
section .cpu_entry
.boot:
	call BIOS_CS:start

