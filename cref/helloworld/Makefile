#generated with perplexity
CXX := g++
CXXFLAGS := -Wall -Wextra -std=c++17
SRC := helloworld.cpp
OBJ := $(SRC:.cpp=.o)
EXEC := helloworld

all: $(OBJ)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: clean run

clean:
	rm -f $(OBJ) $(EXEC)

run: $(OBJ)
	$(CXX) $(CXXFLAGS) $(OBJ) -o $(EXEC)
	./$(EXEC)