DC=dmd
DCFLAGS=-I~/include/d -d -O -inline -release
#DCFLAGS=-I~/include/d -d -g

CC=gcc-4.7
CFLAGS=-std=c11

LDFLAGS=-L-L$(HOME)/lib -L-L`pwd`/lib \
		-L-lDerelictUtil -L-lDerelictSDL -L-lDerelictGL \
		-L-lgl3n-dmd -L-lsylvan

LIB_SOURCES=$(wildcard sylvan/**/*.d)
LIB_OBJECTS=$(patsubst sylvan/%.d,obj/%.o,$(LIB_SOURCES)) obj/graphics/stb_image_c.o
LIB=lib/libsylvan.a

TEST_SOURCES=$(wildcard tests/*.d)
TEST_OBJECTS=$(patsubst tests/%.d,obj/tests/%.o,$(TEST_SOURCES))
TEST_BINARIES=$(patsubst tests/%.d,bin/%,$(TEST_SOURCES))

TERRAIN_SOURCES=$(wildcard terrain/*.d)
TERRAIN_OBJECTS=$(patsubst terrain/%.d,obj/terrain/%.o,$(TERRAIN_SOURCES))
TERRAIN_BINARY=bin/terrain

.PHONY: all
all: $(LIB) $(TEST_BINARIES) $(TERRAIN_BINARY)

obj/%.o: sylvan/%.d
	$(DC) $(DCFLAGS) -of$@ -c $^

obj/graphics/stb_image_c.o: sylvan/graphics/stb_image_c.c
	$(CC) $(CFLAGS) -o $@ -c $^

obj/tests/%.o: tests/%.d
	$(DC) $(DCFLAGS) -of$@ -c $^

obj/terrain/%.o: terrain/%.d
	$(DC) $(DCFLAGS) -of$@ -c $^

$(LIB): $(LIB_OBJECTS)
	libtool -static -o $@ $^

bin/%: obj/tests/%.o $(LIB)
	$(DC) $(DCFLAGS) $(LDFLAGS) -of$@ $<

$(TERRAIN_BINARY): $(TERRAIN_OBJECTS) $(LIB)
	$(DC) $(DCFLAGS) $(LDFLAGS) -of$@ $(TERRAIN_OBJECTS)

.PHONY: clean
clean:
	-rm -f $(LIB_OBJECTS)
	-rm -f $(LIB)
	-rm -f $(TEST_BINARIES)
	-rm -f $(TERRAIN_OBJECTS)
	-rm -f $(TERRAIN_BINARY)
