.PHONY: all test clean

test: FORCE
	docker-compose up --build
FORCE:
