# build smatool executable when user executes "make"
smatool: smatool.o
	$(CC) $(LDFLAGS) -g -ggdb3 -lm -lbluetooth smatool.o -o smatool
smatool.o: smatool.c
	$(CC) $(CFLAGS) -g -ggdb3 -c -Wall smatool.c

# remove object files and executable when user executes "make clean"
clean:
	rm *.o smatool

