cpu 8086
bits 16


global start

%include "src/consts.inc"

;; external symbols
extern interrupt_table


msg_hello db 'hello, world', 0x0A, 0x00


start:

	;; zero out various segments
	mov ax, 0x0000
	mov es, ax
	mov ds, ax
	mov ss, ax

	mov sp, 0xFFFF
	mov bp, sp

	; Initialize interrupt table

	push cs
	pop ds
	xor di,di
	mov es,di
	mov si,interrupt_table
	mov cx,0020h ; 32 Interrupt vectors
	mov ax,BIOS_CS
.1:
	movsw ; copy ISR address (offset part)
	stosw ; store segment part
	loop .1
	mov al,0x05
	out post_reg,al



	mov si, msg_hello
	call print


	;; shutdown (EMU specific)
	jmp 0x0:0


;; print a string stored at the address in DS:SI
print:
	pushf ;; store the flags
	push ax
	push bx
	push si
	push ds
	push cs
	pop ds ;; ds = cs (so the string can be read from ROM)
	       ;;          we reset this later, where we pop ds
	cld ;; clear the direction flag for the lodsb instruction
	;; use load string byte to walk the string
.1:
	lodsb
	or al,al
	jz .exit
	out 0xFF, al ;; print to the special 0xFF port that is in the Emulator
	jmp .1
.exit:
	pop	ds
	pop	si
	pop	bx
	pop	ax
	popf ;; pop the flags
	ret
