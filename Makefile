all:
	 rm -rf source/_posts/en/asymptote/* && hexo clean && bin/asy2hexo-md.sh
