# Generate smaller (uncommented and/or tokenized) versions from the
# original BASIC source code (MIAM.DO).

generated+=MIAM.BA

# Tokenizing and uncommenting requires hackerb9's m100-tokenize program.
# See https://github.com/hackerb9/m100-tokenize
# If it is not installed, use 'make tokenize' to compile a
# (possibly old) version of m100-tokenize in the tokenize/ dir.
TOKENIZE:=$(shell command -v m100-tokenize 2>/dev/null)
ifndef TOKENIZE
    TOKENIZE := $(shell command -v tokenize/m100-tokenize 2>/dev/null)
    ifndef TOKENIZE
        $(warning "Compiling m100-tokenize in tokenize directory");
        generated:=tokenize ${generated}
    endif
    TOKENIZE	:=tokenize/m100-tokenize
endif


### FAKE TARGETS (not actual files)
.PHONY: all clean tar

# By default, generate every file using the implicit rules
all:  ${generated}

# 'make clean' to delete all generated files
clean:
	rm ${generated} 2>/dev/null || true
	rm MIAM.tar.gz MIAM.zip 2>/dev/null || true
	$(MAKE) -C tokenize clean

### Compile hackerb9's tokenizer program
tokenize:
	$(MAKE) -C tokenize tokenize


# GNU tar lets us easily put the files into a subdirectory in the archive.
# Unfortunately, MacOS is recalcitrant.
UNAME := $(shell uname)
ifeq ($(UNAME), Darwin)
	export PATH := /usr/local/opt/gawk/libexec/gnubin:$(PATH)
	export PATH := /usr/local/opt/gnu-tar/libexec/gnubin:$(PATH)
endif
gnuxform := --xform 's%^%MIAM/%'

### Create an archive of the final product for distribution.
archivefiles := MIAM.BA MIAM.DO MazeGen300.cpp MouseInAMaze_Documentation.pdf README.md ReadMe.txt 
archive: tar zip
tar: all
	tar -acf MIAM.tar.gz ${gnuxform} ${archivefiles}
zip: all
	zip -q MIAM.zip ${archivefiles}

### IMPLICIT RULES

# Convert MIAM+comments.DO -> MIAM+comments.BA, keeping comments.
%.BA: %.DO
	tokenize/tokenize $< $@

# Automatically convert MIAM+comments.DO -> MIAM.BA, removing comments & crunching.
%.BA: %+comments.DO
	tokenize/tokenize --crunch MIAM+comments.DO MIAM.BA

