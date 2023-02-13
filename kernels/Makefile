CXX = g++
CXXFLAGS = -O3 -Wall -fopenmp -g -march=native -ffast-math -std=c++17
all: bb frb
bb: bb.o
	$(CXX) $(CXXFLAGS) -o $@ $^
frb: frb.o
	$(CXX) $(CXXFLAGS) -o $@ $^
%.o: %.cxx
	$(CXX) $(CXXFLAGS) -c $*.cxx
format:
	clang-format -i bb.cxx frb.cxx
clean:
	$(RM) bb bb.o
	$(RM) frb frb.o
.PHONY: all format clean
