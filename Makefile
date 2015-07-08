# Content

AUTHOR_NAME = "Rafael G. Martins"
AUTHOR_EMAIL = "rafael@rafaelmartins.eng.br"
SITE_TITLE = "Rafael Martins"
SITE_TAGLINE = "Gentoo Linux, Engineering and random stuff."
LOCALE = "en_US.utf-8"

POSTS_PER_PAGE = 10
POSTS_PER_PAGE_ATOM = 10

POSTS = \
	post2 \
	post1 \
	$(NULL)

PAGES = \
	about \
	resume \
	$(NULL)

RESUME_LANGUAGES = \
	en \
	pt_br \
	$(NULL)

RESUME_FONTS = \
	assets/resume/fonts/DroidSans-Bold.ttf \
	assets/resume/fonts/DroidSans.ttf \
	$(NULL)

ASSETS = \
	assets/custom.css \
	assets/img/creative-commons-88x31.png \
	assets/resume/fonts/DroidSans-Bold.ttf \
	assets/resume/fonts/DroidSans.ttf \
	assets/resume/fonts/README.txt \
	assets/resume/html4css1.css \
	assets/resume/resume.css \
	assets/resume/resume.style \
	$(RESUME_FONTS)


# Arguments

BLOGC ?= $(shell which blogc)
RST2HTML ?= $(shell which rst2html.py)
RST2PDF ?= $(shell which rst2pdf)
INSTALL ?= $(shell which install)
SED ?= $(shell which sed)

OUTPUT_DIR ?= _build
BASE_DOMAIN ?= http://rafaelmartins.eng.br
BASE_URL ?=

DATE_FORMAT = "%b %d, %Y, %I:%M %p GMT"
DATE_FORMAT_ATOM = "%Y-%m-%dT%H:%M:%SZ"

BLOGC_COMMAND = \
	LC_ALL=$(LOCALE) \
	$(BLOGC) \
		-D AUTHOR_NAME=$(AUTHOR_NAME) \
		-D AUTHOR_EMAIL=$(AUTHOR_EMAIL) \
		-D SITE_TITLE=$(SITE_TITLE) \
		-D SITE_TAGLINE=$(SITE_TAGLINE) \
		-D BASE_DOMAIN=$(BASE_DOMAIN) \
		-D BASE_URL=$(BASE_URL) \
	$(NULL)


# Rules

LAST_PAGE = $(shell $(BLOGC_COMMAND) \
	-D FILTER_PAGE=1 \
	-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
	-p LAST_PAGE \
	-l \
	$(addprefix content/post/, $(addsuffix .txt, $(POSTS))))

IS_POST = 0

all: \
	$(OUTPUT_DIR)/index.html \
	$(OUTPUT_DIR)/posts/index.html \
	$(OUTPUT_DIR)/atom.xml \
	$(addprefix $(OUTPUT_DIR)/, $(ASSETS)) \
	$(addprefix $(OUTPUT_DIR)/post/, $(addsuffix /index.html, $(POSTS))) \
	$(addprefix $(OUTPUT_DIR)/, $(addsuffix /index.html, $(PAGES))) \
	$(addprefix $(OUTPUT_DIR)/page/, $(addsuffix /index.html, \
		$(shell for i in {1..$(LAST_PAGE)}; do echo $$i; done))) \
	$(addprefix $(OUTPUT_DIR)/resume/resume-, $(addsuffix .txt, $(RESUME_LANGUAGES))) \
	$(addprefix $(OUTPUT_DIR)/resume/resume-, $(addsuffix .html, $(RESUME_LANGUAGES))) \
	$(addprefix $(OUTPUT_DIR)/resume/resume-, $(addsuffix .pdf, $(RESUME_LANGUAGES))) \
	$(NULL)

$(OUTPUT_DIR)/posts/index.html: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=1 \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-D MENU=blog \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/page/%/index.html: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=$(shell echo $@ | sed -e 's,^$(OUTPUT_DIR)/page/,,' -e 's,/index\.html$$,,')\
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-D MENU=blog \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/atom.xml: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/atom.tmpl
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT_ATOM) \
		-D FILTER_PAGE=1 \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE_ATOM) \
		-l \
		-o $@ \
		-t templates/atom.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/about/index.html: MENU = about

$(OUTPUT_DIR)/post/%/index.html: MENU = blog
$(OUTPUT_DIR)/post/%/index.html: IS_POST = 1

$(OUTPUT_DIR)/%/index.html: content/%.txt templates/main.tmpl
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D MENU=$(MENU) \
		$(shell test "$(IS_POST)" -eq 1 && echo -D IS_POST=1) \
		-o $@ \
		-t templates/main.tmpl \
		$<

$(OUTPUT_DIR)/index.html: content/index.txt templates/main.tmpl
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-o $@ \
		-t templates/main.tmpl \
		$<

$(OUTPUT_DIR)/assets/%: assets/%
	$(INSTALL) -d -m 0755 $(dir $@) && \
		$(INSTALL) -m 0644 $< $@

$(OUTPUT_DIR)/resume/resume-%.txt: content/resume/resume-%.rst
	$(INSTALL) -d -m 0755 $(dir $@) && \
		$(INSTALL) -m 0644 $< $@

$(OUTPUT_DIR)/resume/resume-%.html: content/resume/resume-%.rst
	$(INSTALL) -d -m 0755 $(dir $@) && \
		$(RST2HTML) --generator --date --time --cloak-email-addresses --source-link \
			--link-stylesheet --initial-header-level=2 \
			--source-url=$(BASE_URL)$(shell echo $< | $(SED) -e 's,^content/,/,' -e 's,\.rst$$,.txt,') \
			--stylesheet=$(BASE_URL)/assets/resume/html4css1.css,$(BASE_URL)/assets/resume/resume.css \
			--language=$(shell echo $< | $(SED) -e 's,content/resume/resume-\([^.-]\+\)\.rst,\1,') \
			$< $@

$(OUTPUT_DIR)/resume/resume-%.pdf: content/resume/resume-%.rst $(RESUME_FONTS)
	$(INSTALL) -d -m 0755 $(dir $@) && \
		$(RST2PDF) --stylesheets=assets/resume/resume.style --font-path=assets/resume/fonts \
			--language=$(shell echo $< | $(SED) -e 's,content/resume/resume-\([^.-]\+\)\.rst,\1,') \
			--output=$@ $<

clean:
	rm -rf "$(OUTPUT_DIR)"

.PHONY: all clean
