
.PHONY: build
build: samples

.PHONY: samples/*
samples/*:
	@echo
	@echo Building $@;
	haxelib run openfl build $@/project.xml html5
	haxelib run openfl build $@/project.xml linux

.PHONY: samples
samples: $(wildcard samples/*)

watch:
	react $(shell git ls) -- make ${WATCH}

