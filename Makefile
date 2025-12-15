TEI_SRC = tml-source/tei
OUT     = content/texts
XSL     = xslt/tei2html.xsl
TOOLS_DIR = tools
SAXON_JAR = $(TOOLS_DIR)/saxon-he.jar
XMLRESOLVER_JAR = $(TOOLS_DIR)/xmlresolver.jar

SAXON = java -cp "$(SAXON_JAR):$(XMLRESOLVER_JAR)" net.sf.saxon.Transform

SAXON_VERSION = 12.9
XMLRESOLVER_VERSION = 5.2.0
SAXON_URL = https://repo1.maven.org/maven2/net/sf/saxon/Saxon-HE/$(SAXON_VERSION)/Saxon-HE-$(SAXON_VERSION).jar
XMLRESOLVER_URL = https://repo1.maven.org/maven2/org/xmlresolver/xmlresolver/$(XMLRESOLVER_VERSION)/xmlresolver-$(XMLRESOLVER_VERSION).jar

PAGEFIND_VERSION = 1.4.0
PAGEFIND_BIN = tools/pagefind
PAGEFIND_TMP = tools/pagefind.tar.gz
PAGEFIND_URL_MAC = https://github.com/Pagefind/pagefind/releases/download/v$(PAGEFIND_VERSION)/pagefind-v$(PAGEFIND_VERSION)-aarch64-apple-darwin.tar.gz
PAGEFIND_URL_LINUX = https://github.com/Pagefind/pagefind/releases/download/v$(PAGEFIND_VERSION)/pagefind-v$(PAGEFIND_VERSION)-x86_64-unknown-linux-musl.tar.gz

TEI_FILES := $(wildcard $(TEI_SRC)/*.xml)
HTML_FILES := $(patsubst $(TEI_SRC)/%.xml,$(OUT)/%.md,$(TEI_FILES))

NPROC := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu)
MAKEFLAGS += -j$(NPROC)

.PHONY: all build serve install install-pagefind

all: build

$(OUT)/%.md: $(TEI_SRC)/%.xml $(XSL)
	$(SAXON) -s:$< -xsl:$(XSL) -o:$@

build: $(HTML_FILES)
	hugo
	$(PAGEFIND_BIN) --site "public"

serve: $(HTML_FILES)
	hugo server

install: $(SAXON_JAR) $(XMLRESOLVER_JAR) install-pagefind
	@echo "✓ Saxon and XML Resolver installed in $(TOOLS_DIR)/"

$(TOOLS_DIR):
	mkdir -p $(TOOLS_DIR)

$(SAXON_JAR): | $(TOOLS_DIR)
	curl -L $(SAXON_URL) -o $(SAXON_JAR)

$(XMLRESOLVER_JAR): | $(TOOLS_DIR)
	curl -L $(XMLRESOLVER_URL) -o $(XMLRESOLVER_JAR)

install-pagefind: | tools
	@if [ "$$(uname)" = "Darwin" ]; then \
	  curl -L $(PAGEFIND_URL_MAC) -o $(PAGEFIND_TMP); \
	else \
	  curl -L $(PAGEFIND_URL_LINUX) -o $(PAGEFIND_TMP); \
	fi
	tar -xzf $(PAGEFIND_TMP) -C tools; \
	chmod +x $(PAGEFIND_BIN)
	rm -f $(PAGEFIND_TMP)
