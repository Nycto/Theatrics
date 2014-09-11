
build: $(wildcard samples/*)

.PHONY: samples/*
samples/*:
	@echo
	@echo Building $@;
	haxelib run openfl build $@/project.xml html5
	haxelib run openfl build $@/project.xml linux

watch:
	react $(shell git ls) -- make
