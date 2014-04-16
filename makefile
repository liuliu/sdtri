CC := clang++
LDFLAGS := `llvm-config --ldflags --libs` -lpthread -ldl -lcurses
CXXFLAGS := -std=c++11 -O3 -Wall `llvm-config --cppflags`

TARGETS := sdtri

all: $(TARGETS)

clean:
	rm -f *.o $(TARGETS)

$(TARGETS): %: %.o
	$(CC) -o $@ $< $(LDFLAGS)

%.o: %.cc
	$(CC) $< -o $@ -c $(CXXFLAGS)
