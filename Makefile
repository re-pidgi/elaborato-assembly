EXE = bin/eseguibile
AS = as --32
LD = ld -m elf_i386
DEBUG = -gstabs
OBJ = obj/main.o obj/menu.o obj/order.o obj/readfile.o


start: clean_obj $(OBJ)
	$(LD) -o start $(OBJ)
	mv start $(EXE)

obj/main.o: src/main.s
	$(AS) $(DEBUG) -o obj/main.o src/main.s

obj/menu.o: src/menu.s
	$(AS) $(DEBUG) -o obj/menu.o src/menu.s

obj/order.o: src/order.s
	$(AS) $(DEBUG) -o obj/order.o src/order.s

obj/readfile.o: src/readfile.s
	$(AS) $(DEBUG) -o obj/readfile.o src/readfile.s

clean_obj:
	rm -f $(OBJ)