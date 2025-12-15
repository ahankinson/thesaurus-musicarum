TEI_SRC = tml-source/tei
OUT     = content/texts
XSL     = xslt/tei2html.xsl
SAXON   = saxon

TEI_FILES := $(wildcard $(TEI_SRC)/*.xml)
HTML_FILES := $(patsubst $(TEI_SRC)/%.xml,$(OUT)/%.md,$(TEI_FILES))

NPROC := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu)
MAKEFLAGS += -j$(NPROC)

.PHONY: all build serve

all: build

$(OUT)/%.md: $(TEI_SRC)/%.xml $(XSL)
	$(SAXON) -s:$< -xsl:$(XSL) -o:$@

build: $(HTML_FILES)
	hugo

serve: $(HTML_FILES)
	hugo server
