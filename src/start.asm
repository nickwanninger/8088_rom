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

	;; print hello world
	mov si, msg_hello
	call print

	mov ax, 0xFF
	shift_left ax, 8 ;; macro!
	call print_hex


	m_putc 0x0a ;; macro!

	;; shutdown (EMU specific)
	;;    the emulator looks for instruction access at NULL (first byte)
	;;    to shutdown, so we jump to there with CS=0x0000 and IP=0x0000
	;;    so the next instruction is loaded from 0x00000
	jmp 0x0:0


;; ----------------------------------------------------
;; print
;; Inputs:
;;    cs:si - string pointer
;; Outputs:
;;    ax - number of bytes printed, -1 for error
;;
;; print the null terminated string pointed at by DS:SI
;; ----------------------------------------------------
print:
	pushf ;; store the flags
	push bx
	push cx
	push si
	push ds
	push cs
	pop ds ;; ds = cs (so the string can be read from ROM)
	       ;;          we reset this later, where we pop ds
	cld ;; clear the direction flag for the lodsb instruction
	mov bx, 0 ;; number of bytes written

.print_next:
	lodsb
	or al, al    ;; check if al is zero (null terminated)
	jz .exit


	m_putc ax
	inc cx       ;; increment counter
	jmp .print_next

.exit:
	;; return the number of bytes written
	mov ax, bx
	pop	ds
	pop	si
	pop	cx
	pop	bx
	popf ;; pop the flags
	ret


;; inputs:
;;   ax - word to print as hex (16 bits)
;; outputs:
;;   none
print_hex:
	xchg	al,ah
	call	print_byte		; print the upper byte
	xchg	al,ah
	call	print_byte		; print the lower byte
	ret

;=========================================================================
; print_byte - print a byte in hexadecimal
; Input:
;	AL - byte to print
; Output:
;	none
;-------------------------------------------------------------------------
print_byte:
	rotate_left al, 4 ;; macro!
	call print_digit
	rotate_left al, 4 ;; macro!
	call print_digit
	ret

	;=========================================================================
; print_digit - print hexadecimal digit
; Input:
;	AL - bits 3...0 - digit to print (0...F)
; Output:
;	none
;-------------------------------------------------------------------------
print_digit:
	push ax
	push bx
	push si
	and al, 0x0F    ; make sure its only the lower nibble
	add al,'0'			; convert to ASCII
	cmp al,'9'			; less or equal 9?
	jna .do_print
	add al,'A'-'9'-1		; a hex digit

.do_print:
	m_putc ax

	pop si
	pop bx
	pop ax
	ret

;; 
putc:
	push ax
	mov ax, si
	out 0xFF, al ;; print to the special 0xFF port that is in the Emulator
	pop ax
	ret
