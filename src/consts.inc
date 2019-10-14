BIOS_CS equ	0xF000
BIOS_DS equ	0x0040

post_reg equ 80h ; POST status output port


; serial information
serial_timeout   equ	0x00 ; byte[4] - serial port timeout values
equip_serial     equ  0x40 ; word[4] - addresses of serial ports


%macro m_putc 1
	extern putc
	push si
	mov si, %1
	call putc
	pop si
%endmacro


%macro shift_left 2
	%rep %2
		;; shift the first argument left by one
		shl %1, 1
	%endrep
%endmacro

%macro shift_right 2
	%rep %2
		;; shift the first argument right by one
		shr %1, 1
	%endrep
%endmacro


%macro rotate_left 2
	%rep %2
		rol %1, 1
	%endrep
%endmacro

%macro rotate_right 2
	%rep %2
		ror %1, 1
	%endrep
%endmacro



%macro prologue 1
	push bp
	mov bp, sp
	sub sp, %1
%endmacro

%macro return 0
	mov sp, bp
	pop	bp
	ret
%endmacro
