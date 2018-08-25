BLOG=kiririmode.hatenablog.jp

init:
	npm install
	blogsync pull ${BLOG}
	touch -t $(shell date +%Y%m%d%H%M.%S) blogged-time

sync:
	blogsync pull ${BLOG}

draft:
	echo | blogsync post --draft kiririmode.hatenablog.jp 2>&1 \
	| grep store \
	| awk '{print $$3}' \
	| xargs -L1 emacsclient

search-draft:
	find entry -name \*.md \
	| xargs egrep '^Draft:[[:space:]]*true' -l \
	| xargs grep '^Title:' /dev/null \
	| peco \
	| cut -d: -f1 \
	| xargs -L1 emacsclient

lint:
	find entry -newer blogged-time -name \*.md -print0 \
	| xargs --no-run-if-empty -0 egrep -L '<!--[[:space:]]*ignore-lint[[:space:]]*-->'  \
	| xargs --no-run-if-empty npm run lint

release: lint
	find entry -newer blogged-time -name \*.md -print0 \
	| xargs --no-run-if-empty -0 -L 1 blogsync push
	touch -t $(shell date +%Y%m%d%H%M.%S) blogged-time


remove-draft:
	find entry -name \*.md \
	| xargs egrep '^Draft:[[:space:]]*true' -l \
	| xargs rm

.PHONY: init sync lint release search-draft remove-draft
