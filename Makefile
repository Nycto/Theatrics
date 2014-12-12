
.PHONY: build
build: test samples

.PHONY: samples/*
samples/*:
	@echo
	@echo Building $@;
	haxelib run openfl build $@/project.xml html5
	haxelib run openfl build $@/project.xml linux | tail -n 20

.PHONY: samples
samples: $(wildcard samples/*)

.PHONY: test
test:
	haxelib run munit test -result-exit-code | tail -n 50

.PHONY: watch
watch:
	react $(shell git ls) -- make ${WATCH}

.PHONY: browser
browser: samples
	google-chrome samples/*/bin/html5/bin/index.html

.PHONY: clean
clean:
	rm -rf build samples/*/bin

