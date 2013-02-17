DC=dmd
DCFLAGS=-I~/include/d -O -inline -release

CC=gcc-4.7
CFLAGS=-std=c11

LDFLAGS=-L-L$(HOME)/lib -L-L`pwd`/lib \
		-L-lDerelictUtil -L-lDerelictSDL -L-lDerelictGL \
		-L-lgl3n-dmd -L-lsylvan

LIB_SOURCES=$(wildcard sylvan/**/*.d)
LIB_OBJECTS=$(patsubst sylvan/%.d,obj/%.o,$(LIB_SOURCES)) obj/graphics/stb_image_c.o
LIB=lib/libsylvan.a

TEST_SOURCES=$(wildcard tests/*.d)
TEST_BINARIES=$(patsubst tests/%.d,bin/%,$(TEST_SOURCES))

.PHONY: all
all: $(LIB) $(TEST_BINARIES)

obj/%.o: sylvan/%.d
	$(DC) $(DCFLAGS) -of$@ -c $^

obj/graphics/stb_image_c.o: sylvan/graphics/stb_image_c.c
	$(CC) $(CFLAGS) -o $@ -c $^

$(LIB): $(LIB_OBJECTS)
	libtool -static -o $@ $^

bin/%: tests/%.d $(LIB)
	$(DC) $(DCFLAGS) $(LDFLAGS) -of$@ $^

.PHONY: clean
clean:
	-rm -f $(LIB_OBJECTS)
	-rm -f $(LIB)
	-rm -f $(TEST_BINARIES)

