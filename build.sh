DOCSET_NAME="Umbraco Razor Quick Reference"
ARCHIVE_NAME="Umbraco_Razor_Quick_Reference"
DOC_XML_FILE="src/data/razor-reference.xml"
FEED_FILENAME="umbraco-razor-quick-reference"
TEMP_DIR="dist/temp"
DIST_DIR="dist"
BUNDLE="$DIST_DIR/$DOCSET_NAME.docset"

# Build the resulting file
xsltproc --xinclude -o "$DIST_DIR/index.html" src/xslt/build-dash-docset.xslt "$DOC_XML_FILE"

# Build the SQL to populate the docSet.dsidx SQLLite database
xsltproc --xinclude -o "$TEMP_DIR/docs.sql" src/xslt/build-sql.xslt "$DOC_XML_FILE"

# Build the Dash DocSet feed XML file
xsltproc -o "$TEMP_DIR/$FEED_FILENAME.xml" --stringparam filename "$ARCHIVE_NAME" src/xslt/build-feed.xslt "$DOC_XML_FILE"

# Backup the existing DocSet (if any)
if [[ -d "$BUNDLE" ]]; then
	rm -rf "$BUNDLE.bak"
	mv "$BUNDLE" "$BUNDLE.bak"
fi

# Create the Docset Folder
mkdir -p "$BUNDLE/Contents/Resources/Documents/"

# Copy HTML + assets to Docset
cp $DIST_DIR/index.html "$BUNDLE/Contents/Resources/Documents"
cp build/assets/app.css "$BUNDLE/Contents/Resources/Documents"
cp build/assets/app.min.js "$BUNDLE/Contents/Resources/Documents"

# Copy assets to dist as well for easier transfer to deploy server
cp build/assets/app.css $DIST_DIR
cp build/assets/app.min.js $DIST_DIR

# Copy the Info.plist file
cp "lib/Info.plist" "$BUNDLE/Contents"

# Copy the icon
cp "lib/icon.png" "$BUNDLE"

# Create the SQLite file + Index
sqlite3 "$BUNDLE/Contents/Resources/docSet.dsidx" "CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);"
sqlite3 "$BUNDLE/Contents/Resources/docSet.dsidx" "CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);"

# Populate the index
sqlite3 "$BUNDLE/Contents/Resources/docSet.dsidx" ".read $TEMP_DIR/docs.sql"

# Create the archived Docset file
tar --exclude='.DS_Store' -cvzf "$DIST_DIR/$ARCHIVE_NAME.tgz" "$BUNDLE"

# Clean up
rm -rf "$BUNDLE.bak"

echo "Completed build - don't forget to upload the $ARCHIVE_NAME.tgz and feed (XML) files to greystate.dk as well as all the HTML files"
