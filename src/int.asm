;; Interrupt table and handler

%include "src/consts.inc"


global interrupt_table
interrupt_table:
 dw int_NA    ; INT 00 - Divide by zero
 dw int_NA    ; INT 01 - Single step
 dw int_NA    ; INT 02 - Non-maskable interrupt
 dw int_NA    ; INT 03 - Debugger breakpoint
 dw int_NA    ; INT 04 - Integer overlow (into)
 dw int_NA    ; INT 05 - BIOS Print Screen
 dw int_NA    ; INT 06
 dw int_NA    ; INT 07
 dw int_NA    ; INT 08 - IRQ0 - Timer Channel 0
 dw int_NA    ; INT 09 - IRQ1 - Keyboard
 dw int_IG    ; INT 0A - IRQ2
 dw int_IG    ; INT 0B - IRQ3
 dw int_IG    ; INT 0C - IRQ4
 dw int_IG    ; INT 0D - IRQ5
 dw int_NA    ; INT 0E - IRQ6 - Floppy
 dw int_IG    ; INT 0F - IRQ7
 dw int_NA    ; INT 10 - BIOS Video Services
 dw int_NA    ; INT 11 - BIOS Get Equipment List
 dw int_NA    ; INT 12 - BIOS Get Memory Size
 dw int_NA    ; INT 13 - BIOS Floppy Disk Services
 dw int_14    ; INT 14 - BIOS Serial Communications
 dw int_NA    ; INT 15 - BIOS Misc. System Services
 dw int_NA    ; INT 16 - BIOS Keyboard Services
 dw int_NA    ; INT 17 - BIOS Parallel Printer svc.
 dw int_NA    ; INT 18 - BIOS Start ROM BASIC
 dw int_NA    ; INT 19 - BIOS Boot the OS
 dw int_NA    ; INT 1A - BIOS Time Services
 dw int_NA
 dw int_NA
 dw int_NA    ; INT 1D - Video Parameters Table
 dw int_NA    ; INT 1E - Floppy Paameters Table
 dw int_NA    ; INT 1F - Font For Graphics Mode


int_NA:
int_IG:
 iret





int_14_fn00:
int_14_fn02:
int_14_fn03:
int_14_fn04:
int_14_fn05:
	jmp int_14_exit



int_14_fn01:
	push ax


	xor ax, ax
	mov al, cl
	out 0xFF, al ;; TODO: replace with real serial logic

	pop ax
	jmp int_14_exit

;; dumb "serial" printer
;; TODO: use real serial interface instead of just the EMU putc
int_14:
	sti
	push cx
	push dx
	push si
	push ds
	push bx

	;; set the bios data segment
	mov bx, BIOS_CS
	mov ds, bx

	cmp ah,.max/2 ;; check if the function is valid
	jae int_14_error  ; invalid function number specified

	cmp dx, 1
	jae int_14_error  ; invalid port number specified

	mov si, serial_timeout ; serial port timeout setting in BDA
	add si, dx   ; [SI] = timeout for the selected port
	mov bx, dx
	shl bx, 1

	;; mov dx, word [equip_serial+bx] ; DX = serial port address
	;; or dx,dx
	;; jz int_14_error  ; specified port is not installed

	mov bh,0
	mov bl,ah
	shl bx,1
	cs jmp near [.dispatch+bx]
.dispatch:
	dw int_14_fn00
	dw int_14_fn01
	dw int_14_fn02
	dw int_14_fn03
	dw int_14_fn04
	dw int_14_fn05
.max equ $-.dispatch

int_14_error:
	 mov ax, 0xFFFF

int_14_exit:
	pop bx
	pop ds
	pop si
	pop dx
	pop cx

	;; return from the interrupt and restore the old state
	iret
