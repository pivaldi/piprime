.PHONY: all
all: clean
	hexo build

.PHONY: serve
serve: clean
	hexo serve

.PHONY: asy
asy: clean
	bin/asy2hexo-md.sh

.PHONY: clean
clean:
	hexo clean
