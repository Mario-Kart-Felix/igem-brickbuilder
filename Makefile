# Add local node executables to the PATH for this makefile
export PATH := ./node_modules/.bin:$(PATH)

go:
	supervisor app.coffee
