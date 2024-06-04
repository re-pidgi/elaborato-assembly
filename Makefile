
AS_FLAGS=--32 -gstabs
LD_FLAGS= -m elf_i386


all: bin/*


obj/*: src/*
	as $(AS_FLAGS) src/* -o obj/*


bin/*: obj/*
	ld $(LD_FLAGS) obj/* -o bin/*


clean:
	rm -f obj/* bin/*
