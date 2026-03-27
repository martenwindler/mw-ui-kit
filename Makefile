ELM=elm
JS_OUT=dist/app.js
STYLEGUIDE_OUT=dist/index.html
SRC=src/Framework.elm

all: build

start:
	npm start

format:
	$(ELM)-format src/ --yes

build: clean setup
	$(ELM) make $(SRC) --optimize --output=$(JS_OUT)

docs: setup
	$(ELM) make $(SRC) --output=$(STYLEGUIDE_OUT)

setup:
	mkdir -p dist
	mkdir -p utils

clean:
	rm -rf dist
	rm -rf elm-stuff

keep:
	find src -type d -exec touch {}/.gitkeep \;

.PHONY: all start format build docs clean setup keep