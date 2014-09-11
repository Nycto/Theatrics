
.PHONY: build
build: test samples

.PHONY: samples/*
samples/*:
	@echo
	@echo Building $@;
	haxelib run openfl build $@/project.xml html5
	haxelib run openfl build $@/project.xml linux

.PHONY: samples
samples: $(wildcard samples/*)

.PHONY: test
test:
	haxelib run munit test

watch:
	react $(shell git ls) -- make ${WATCH}
