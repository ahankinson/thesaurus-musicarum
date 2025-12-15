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

TEI_FILES := $(wildcard $(TEI_SRC)/*.xml)
HTML_FILES := $(patsubst $(TEI_SRC)/%.xml,$(OUT)/%.md,$(TEI_FILES))

NPROC := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu)
MAKEFLAGS += -j$(NPROC)

.PHONY: all build serve install

all: build

$(OUT)/%.md: $(TEI_SRC)/%.xml $(XSL)
	$(SAXON) -s:$< -xsl:$(XSL) -o:$@

build: $(HTML_FILES)
	hugo

serve: $(HTML_FILES)
	hugo server

install: $(SAXON_JAR) $(XMLRESOLVER_JAR)
	@echo "✓ Saxon and XML Resolver installed in $(TOOLS_DIR)/"

$(TOOLS_DIR):
	mkdir -p $(TOOLS_DIR)

$(SAXON_JAR): | $(TOOLS_DIR)
	curl -L $(SAXON_URL) -o $(SAXON_JAR)

$(XMLRESOLVER_JAR): | $(TOOLS_DIR)
	curl -L $(XMLRESOLVER_URL) -o $(XMLRESOLVER_JAR)
