scpr.GA_PAGE_MAPPING =
    "^/listen_live"         : "Streaming"
    "^/news/\\d{4}"         : "Story"
    "^/blogs/.+?/\\d{4}"    : "Story"
    "^/programs"            : "Program"
    "^/events"              : "Events/Calendar"
    "^/schedule"            : "Schedule"
    "^/search"              : "Search"
    "^/about/press"         : "About"
    "^/about/people"        : "People"
    "^/podcasts"            : "Program"
    # No need to loop through these since we have the fallback.
    # We'll keep them around just so we know what we're interested in
    # tracking.
    # "^/about"               : "Content/About"
    # "^/news"                : "Content/About"
    # "^/arts-life"           : "Content/About"
    # "^/blogs"               : "Content/About"
    # "^/topics"              : "Content/About"
    # "^/network"             : "Content/About"
    # "^/archive"             : "Content/About"
    ""                      : "Content/About" # Catch-all fallback
