#generated with perplexity
CXX := g++
CXXFLAGS := -Wall -Wextra -std=c++17
TARGET := dot
SRCS := main.cpp
HEADERS := mxint8_dot.h, parameter.h
OBJS := $(SRCS:.cpp=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $^

%.o: %.cpp $(HEADERS)
	$(CXX) $(CXXFLAGS) -c $< -o $@

.PHONY: clean run

clean:
	rm -f $(OBJS) $(TARGET)

run: $(TARGET)
	./$(TARGET)