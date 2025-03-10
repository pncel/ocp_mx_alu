# Makefile for dot product reference module testing
# make run

CXX := g++
CXXFLAGS := -Wall -Wextra -std=c++17
# targets
SCOREBOARD = scoreboard
TESTGEN = testgen
#sources
SCOREBOARD_SRC = dot_scoreboard.cpp
TESTGEN_SRC  = dot_test_drv.cpp
MODEL_SRC  = dot_mxint8_reference.cpp

RESULT_FILE = dot_test_result.txt
TESTCASE_FILE = dot_testcases.txt

# HEADERS := mxint8_dot.h, parameter.h
# OBJS := $(SRCS:.cpp=.o)
# all: $(TARGET)

$(SCOREBOARD) : $(SCOREBOARD_SRC) $(MODEL_SRC)
	$(CXX) $(CXXFLAGS) -o $@ $^

$(TESTGEN) : $(TESTGEN_SRC)
	$(CXX) $(CXXFLAGS) -o $@ $^

.PHONY: clean run

clean:
	rm -f $(SCOREBOARD) $(TESTGEN) $(RESULT_FILE) $(TESTCASE_FILE)

# g++ -o test dot_test_drv.cpp
# ./test > dot_testcases.txt
# g++ -o scoreboard dot_scoreboard.cpp dot_mxint8_reference.cpp
# ./scoreboard > test_result.txt
run: $(TESTGEN) $(SCOREBOARD)
	./$(TESTGEN) > $(TESTCASE_FILE)
	./$(SCOREBOARD) > $(RESULT_FILE)

