SOURCE_FILES = $(sort $(shell find src -name \*.elm | grep -v examples))
OBJECT_FILES = $(patsubst %.elm,%.js,$(SOURCE_FILES))

GENERATED_FILES = \
	elm-d3.js \
	elm-d3.library.js \
	elm-d3.runtime.js

.PHONY:	all clean

all: $(GENERATED_FILES)

build/%.js: %.elm
	./node_modules/.bin/elm-make -o $?

elm-d3.js: elm-d3.runtime.js elm-d3.library.js
	@rm -f $@
	./node_modules/.bin/smash elm-d3.runtime.js elm-d3.library.js > $@

elm-d3.runtime.js: $(shell node_modules/.bin/smash --list src/Native/runtime.js)
	@rm -f $@
	./node_modules/.bin/smash src/Native/runtime.js > $@

elm-d3.library.js: $(addprefix build/,$(OBJECT_FILES))
	@rm -f $@
	./node_modules/.bin/smash $(addprefix build/,$(OBJECT_FILES)) > $@

clean:
	rm -rf -- build/ cache/ $(GENERATED_FILES)
