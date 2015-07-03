CC := clang
LDFLAGS := -lfoo -lbaz -L./lib
SO_FLAGS := -dynamiclib
LIBDIR := lib/plugin

all : main

%.o : %.c $(LIBDIR)
	$(CC) $(CFLAGS) -fPIC -c $< -o $@

lib/libbaz.dylib : baz.o
	$(CC) $(SO_FLAGS) $< -o $@ -install_name @executable_path/$@

lib/libfoo.dylib : foo.o lib/plugin/libbar.dylib
	$(CC) $(SO_FLAGS) $< -o $@ -install_name @rpath/$@ -lbar -L./lib/plugin

lib/plugin/libbar.dylib : bar.o
	# loader_path is the path for libfoo (the one who loads libbar)
	$(CC) $(SO_FLAGS) $^ -o $@ -install_name @loader_path/plugin/libbar.dylib

main : main.o lib/libfoo.dylib lib/libbaz.dylib
	$(CC) $< $(LDFLAGS) -o $@ -Xlinker -rpath -Xlinker $(shell pwd)

$(LIBDIR) :
	mkdir -p $(LIBDIR)

clean :
	rm *.o
	rm lib -r
	rm main
