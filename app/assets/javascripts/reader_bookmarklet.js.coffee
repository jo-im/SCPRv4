READER_BASE = "http://reader.scprdev.org"

window.getReaderUrl = ->
    readerUrlRes = [
            {
                re: new RegExp("^/blogs/.+/.+/.+/.+/(.+)/.+/?$", "gi"),
                key: "blog_entry"
            },
            {
                re: new RegExp("^/news/.+/.+/.+/(.+)/.+/?$", "gi"),
                key: "news_story"
            },
            {
                re: new RegExp("^/programs/.+/.+/.+/.+/(.+)/.+/?$", "gi"),
                key: "show_segment"
            }
        ]

    path = window.location.pathname

    for matcher in readerUrlRes
        if match = matcher.re.exec(path)
            readerUrl = "#{READER_BASE}/#/#{matcher.key}-#{match[1]}"
            break;

    if readerUrl
        return readerUrl;
    else
        alert("Only News Stories, Blog Entries, and Show Segments are supported.")
        return false;

# Bookmark JS
# Paste here to turn it into bookmark-safe code: http://ted.mielczarek.org/code/mozilla/bookmarklet.html
# var url, newWin; try { if(url = getReaderUrl()) newWin = window.open(url, 'reader-' + (new Date().getTime() / 1000)) } catch(e) { if(newWin) { newWin.close() }; alert('This function is not available on this page.'); }
