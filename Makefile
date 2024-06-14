AS_FLAGS = --32 
DEBUG = -gstabs
LD_FLAGS = -m elf_i386

all: bin/menu

bin/menu: obj/main.o obj/menu.o
	ld $(LD_FLAGS) obj/main.o obj/menu.o -o bin/menu

obj/main.o: src/main.s
	as $(AS_FLAGS) $(DEBUG) src/main.s -o obj/main.o

obj/menu.o: src/menu.s
	as $(AS_FLAGS) $(DEBUG) src/menu.s -o obj/menu.o


clean:
	rm -f obj/*.o bin/menu
