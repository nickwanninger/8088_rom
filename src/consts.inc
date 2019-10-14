BIOS_CS equ	0xF000
BIOS_DS equ	0x0040

post_reg equ 80h ; POST status output port


; serial information
serial_timeout   equ	0x00 ; byte[4] - serial port timeout values
equip_serial     equ  0x40 ; word[4] - addresses of serial ports


