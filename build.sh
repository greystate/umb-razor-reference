DOCSET_NAME="Umbraco Razor Quick Reference"
ARCHIVE_NAME="Umbraco_Razor_Quick_Reference"
BUNDLE="dist/$DOCSET_NAME.docset"
DOC_XML_FILE="src/data/razor-reference.xml"
FEED_FILENAME="umbraco-razor-quick-reference"
DIST_DIR="dist"

# Build the resulting file
xsltproc --xinclude -o "$DIST_DIR/index.html" src/xslt/build-dash-docset.xslt "$DOC_XML_FILE"

# Build the SQL to populate the docSet.dsidx SQLLite database
xsltproc --xinclude -o dist/docs.sql src/xslt/build-sql.xslt "$DOC_XML_FILE"


# Build the Dash DocSet feed XML file
xsltproc -o "dist/$FEED_FILENAME.xml" --stringparam filename "$ARCHIVE_NAME" src/xslt/build-feed.xslt "$DOC_XML_FILE"

