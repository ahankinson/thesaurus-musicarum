This is a static site rendered version of the Thesaurus Musicarum Latinarum. 

The TEI encoded texts were downloaded from the [Fenyx site](https://fenyx.me). These TEI texts
were corrected with various XSLT scripts (in the `xslt` directory) to produce valid TEI.

An LLM (ChatGPT 5.2) was used to build the scripts and the site.

## Building

A Makefile is provided to run various scripts for building the site.

`make install` will install various tools necessary for processing the XML. It has been
tested on macOS 26 and Ubuntu.

The TEI texts (in `tml-source/tei`) are processed to HTML using the `xslt/tei2html.xsl` XSLT. This
produces HTML of the body, but embedded in a Markdown file, with frontmatter containing some metadata
about the text. The output is stored in `content/texts/`.

`make build` is used to run the XSLT to convert the TEI to HTML. It will also postprocess the generated
files with the `pagefind` tool and generate a client-side search index.

`make serve` will run the hugo web server locally for development. This will automatically transform the
Markdown files into a static site.


