# Content

AUTHOR_NAME = "Rafael G. Martins"
AUTHOR_EMAIL = "rafael@rafaelmartins.eng.br"
SITE_TITLE = "Rafael Martins"
SITE_TAGLINE = "Gentoo Linux, Engineering and random stuff."
LOCALE = "en_US.utf-8"

POSTS_PER_PAGE = 10
POSTS_PER_PAGE_ATOM = 10

TAGS = \
	gentoo \
	blogc \
	$(NULL)

POSTS = \
	blogc-helper-tools \
	blogc-a-blog-compiler \
	hello-world \
	$(NULL)

PAGES = \
	about \
	projects \
	resume \
	talks \
	talks/fisl15 \
	talks/goj2011 \
	talks/linuxcon2011 \
	talks/pybr9 \
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
	assets/fluid-width.js \
	assets/img/creative-commons-88x31.png \
	assets/img/rafael.jpg \
	assets/resume/fonts/DroidSans-Bold.ttf \
	assets/resume/fonts/DroidSans.ttf \
	assets/resume/fonts/README.txt \
	assets/resume/html4css1.css \
	assets/resume/resume.css \
	assets/resume/resume.style \
	$(RESUME_FONTS)


# Arguments

BLOGC ?= $(shell which blogc)
BLOGC_RUNSERVER ?= $(shell which blogc-runserver)
RST2HTML ?= $(shell which rst2html.py rst2html 2> /dev/null)
RST2PDF ?= $(shell which rst2pdf)
MKDIR ?= $(shell which mkdir)
CP ?= $(shell which cp)
SED ?= $(shell which sed)

BLOGC_RUNSERVER_HOST ?= 127.0.0.1
BLOGC_RUNSERVER_PORT ?= 8080

OUTPUT_DIR ?= _build
BASE_DOMAIN ?= https://rgm.io
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
		-D GLOBAL_TAGS="$(TAGS)" \
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
	$(OUTPUT_DIR)/atom/index.xml \
	$(addprefix $(OUTPUT_DIR)/atom/, $(addsuffix /index.xml, $(TAGS))) \
	$(addprefix $(OUTPUT_DIR)/tag/, $(addsuffix /index.html, $(TAGS))) \
	$(addprefix $(OUTPUT_DIR)/, $(ASSETS)) \
	$(addprefix $(OUTPUT_DIR)/post/, $(addsuffix /index.html, $(POSTS))) \
	$(addprefix $(OUTPUT_DIR)/, $(addsuffix /index.html, $(PAGES))) \
	$(addprefix $(OUTPUT_DIR)/page/, $(addsuffix /index.html, \
		$(shell for i in {1..$(LAST_PAGE)}; do echo $$i; done))) \
	$(addprefix $(OUTPUT_DIR)/resume/resume-, $(addsuffix .txt, $(RESUME_LANGUAGES))) \
	$(addprefix $(OUTPUT_DIR)/resume/resume-, $(addsuffix .html, $(RESUME_LANGUAGES))) \
	$(addprefix $(OUTPUT_DIR)/resume/resume-, $(addsuffix .pdf, $(RESUME_LANGUAGES))) \
	$(NULL)

$(OUTPUT_DIR)/posts/index.html: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=1 \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-D MENU=blog \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/page/%/index.html: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=$(shell echo $@ | sed -e 's,^$(OUTPUT_DIR)/page/,,' -e 's,/index\.html$$,,') \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-D MENU=blog \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/atom/index.xml: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/atom.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT_ATOM) \
		-D FILTER_PAGE=1 \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE_ATOM) \
		-l \
		-o $@ \
		-t templates/atom.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/atom/%/index.xml: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/atom.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT_ATOM) \
		-D FILTER_PAGE=1 \
		-D FILTER_TAG=$(shell echo $@ | sed -r "s,.*/atom/([^/]+)/index.xml$$,\1,") \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE_ATOM) \
		-l \
		-o $@ \
		-t templates/atom.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/tag/%/index.html: $(addprefix content/post/, $(addsuffix .txt, $(POSTS))) templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D FILTER_PAGE=1 \
		-D FILTER_TAG=$(shell echo $@ | sed -r "s,.*/tag/([^/]+)/index.html$$,\1,") \
		-D FILTER_PER_PAGE=$(POSTS_PER_PAGE) \
		-D MENU=blog \
		-l \
		-o $@ \
		-t templates/main.tmpl \
		$(addprefix content/post/, $(addsuffix .txt, $(POSTS)))

$(OUTPUT_DIR)/about/%: MENU = about
$(OUTPUT_DIR)/talks/%: MENU = talks
$(OUTPUT_DIR)/projects/%: MENU = projects
$(OUTPUT_DIR)/resume/%: MENU = resume

$(OUTPUT_DIR)/post/%/index.html: MENU = blog
$(OUTPUT_DIR)/post/%/index.html: IS_POST = 1

$(OUTPUT_DIR)/%/index.html: content/%.txt templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-D MENU=$(MENU) \
		$(shell test "$(IS_POST)" -eq 1 && echo -D IS_POST=1) \
		-o $@ \
		-t templates/main.tmpl \
		$<

$(OUTPUT_DIR)/index.html: content/index.txt templates/main.tmpl Makefile
	$(BLOGC_COMMAND) \
		-D DATE_FORMAT=$(DATE_FORMAT) \
		-o $@ \
		-t templates/main.tmpl \
		$<

$(OUTPUT_DIR)/assets/%: assets/% Makefile
	$(MKDIR) -p $(dir $@) && \
		$(CP) $< $@

$(OUTPUT_DIR)/resume/resume-%.txt: content/resume/resume-%.rst Makefile
	$(MKDIR) -p $(dir $@) && \
		$(CP) $< $@

$(OUTPUT_DIR)/resume/resume-%.html: content/resume/resume-%.rst Makefile
	$(MKDIR) -p $(dir $@) && \
		$(RST2HTML) --generator --date --time --cloak-email-addresses --source-link \
			--link-stylesheet --initial-header-level=2 \
			--source-url=$(BASE_URL)$(shell echo $< | $(SED) -e 's,^content/,/,' -e 's,\.rst$$,.txt,') \
			--stylesheet=$(BASE_URL)/assets/resume/html4css1.css,$(BASE_URL)/assets/resume/resume.css \
			--language=$(shell echo $< | $(SED) -e 's,content/resume/resume-\([^.-]\+\)\.rst,\1,') \
			$< $@

$(OUTPUT_DIR)/resume/resume-%.pdf: content/resume/resume-%.rst $(RESUME_FONTS) Makefile
	$(MKDIR) -p $(dir $@) && \
		$(RST2PDF) --stylesheets=assets/resume/resume.style --font-path=assets/resume/fonts \
			--language=$(shell echo $< | $(SED) -e 's,content/resume/resume-\([^.-]\+\)\.rst,\1,') \
			--output=$@ $<

serve: all
	$(BLOGC_RUNSERVER) \
		-t $(BLOGC_RUNSERVER_HOST) \
		-p $(BLOGC_RUNSERVER_PORT) \
		$(OUTPUT_DIR)

clean:
	$(RM) -rf "$(OUTPUT_DIR)"

.PHONY: all serve clean
