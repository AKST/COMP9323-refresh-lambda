TEMPDIR := $(shell mktemp -d)
PWD := $(shell pwd)

default: build

config/secret.json:
	[ ! -f config/secret.json ] && cp config/secret.template.json config/secret.json

node_modules:
	yarn

flow-typed: node_modules
	./node_modules/.bin/flow-typed install

dev: build lint type test

run: node_modules config/secret.json
	./node_modules/.bin/nodemon ./dist/src/app.js --watch dist -e js \
	| ./node_modules/.bin/bunyan

type: node_modules
	./node_modules/.bin/flow status

test: node_modules
	./node_modules/.bin/jest

lint: node_modules
	./node_modules/.bin/eslint src test

clean:
	rm -rf dist

lambda_build: build
	[ ! -d build ] && mkdir build || true
	-cp -r dist/. $(TEMPDIR)/.
	-cp yarn.lock $(TEMPDIR)/.
	-cd $(TEMPDIR) && yarn install --production
	-cd $(TEMPDIR) && zip -r $(PWD)/build/$$(date +%y-%m-%d-%s).zip .
	-rm -rf $(TEMPDIR)


watch:
	@which watchman-make > /dev/null || ( echo 'install watchman' && exit 1 )
	watchman-make \
		-p 'src/**/*.js' 'src/*.js' 'test/**/*.js' 'test/*.js' -t dev

build: node_modules
	./node_modules/.bin/babel src --out-dir dist/src --source-maps inline
	cp ./package.json ./dist/.

.PHONY: clean default run lint build test watch ci lambda_build
