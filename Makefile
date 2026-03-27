ELM=elm
JS_OUT=dist/app.js
STYLEGUIDE_OUT=dist/index.html
SRC=src/Framework.elm

all: build

install: 
	npm install

start:
	utils/start_2

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

.PHONY: all install start format build docs clean setup keep