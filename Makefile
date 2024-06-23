EXE = bin/eseguibile
AS = as --32
LD = ld -m elf_i386
DEBUG = -gstabs
OBJ = obj/main.o obj/menu.o obj/order.o obj/file.o obj/error.o obj/print.o


start: clean_obj $(OBJ)
	$(LD) -o start $(OBJ)
	mv start $(EXE)

obj/main.o: src/main.s
	$(AS) $(DEBUG) -o obj/main.o src/main.s

obj/menu.o: src/menu.s
	$(AS) $(DEBUG) -o obj/menu.o src/menu.s

obj/order.o: src/order.s
	$(AS) $(DEBUG) -o obj/order.o src/order.s

obj/file.o: src/file.s
	$(AS) $(DEBUG) -o obj/file.o src/file.s

obj/error.o: src/error.s
	$(AS) $(DEBUG) -o obj/error.o src/error.s

obj/print.o: src/print.s
	$(AS) $(DEBUG) -o obj/print.o src/print.s


clean_obj:
	rm -f $(OBJ)