CODEFILES := $(shell find src -type f)
BINARY := rom.bin

ASOURCES:=$(filter %.asm,$(CODEFILES))
AOBJECTS:=$(ASOURCES:%.asm=build/%.asm.o)


LD := i386-elf-ld

default: build/rom.bin build/emu


build:
	@mkdir -p build

build/rom.elf: build $(AOBJECTS)
	@echo " LNK " $@
	@$(LD) $(LDFLAGS) $(AOBJECTS) -T rom.ld -o $@


build/rom.bin: build/rom.elf
	@echo " BIN " $<
	@i386-elf-objcopy -O binary --pad-to 0x7FFF build/rom.elf build/rom.bin


build/%.asm.o: %.asm
	@mkdir -p $(dir $@)
	@echo " ASM " $<
	@nasm -f elf $(AFLAGS) -o $@ $<

build/emu: emu/emu.c emu/decode.c
	$(CC) -DNO_GRAPHICS -O3 -fsigned-char -std=c99 ${OPTS_ALL} -o build/emu emu/emu.c emu/decode.c


clean:
	rm -rf build
