run:
	love .

clean:
	rm -f SpaceTramp.love

build: clean
	zip -9 -r "SpaceTramp.love" .
	du -h "SpaceTramp.love"

# build_small: clean
# 	zip -9 -r "SpaceTramp.love" *.*
# 	du -h "SpaceTramp.love"
