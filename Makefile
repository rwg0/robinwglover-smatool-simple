# build smatool executable when user executes "make"
smatool: smatool.o
	$(CC) $(LDFLAGS) -lm -lbluetooth smatool.o -o smatool
smatool.o: smatool.c
	$(CC) $(CFLAGS) -c smatool.c

# remove object files and executable when user executes "make clean"
clean:
	rm *.o smatool

