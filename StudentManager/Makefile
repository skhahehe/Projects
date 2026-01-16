# Compiler
CXX = g++

# Flags (C++17 is required for SFML 3)
CXXFLAGS = -std=c++17 -Wall -O2

# SFML Paths for Intel Macs (/usr/local)
INCLUDES = -I/usr/local/include
LDFLAGS = -L/usr/local/lib

# Libraries to link
LIBS = -lsfml-graphics -lsfml-window -lsfml-system

# Build Target
student_manager: main.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(LDFLAGS) main.cpp -o student_manager $(LIBS)

# Clean command
clean:
	rm -f student_manager