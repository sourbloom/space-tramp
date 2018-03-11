run:
	love .

build:
	zip -9 -r "SpaceTramp.love" .
	du -h "SpaceTramp.love"

build_small:
	zip -9 -r "SpaceTramp.love" *.*
	du -h "SpaceTramp.love"

