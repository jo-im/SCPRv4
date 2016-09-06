# Filters
Use these with the *html-pipeline* gem to filter/sanitize HTML before rendering.

## Example
```
pipeline = HTML::Pipeline.new([Filter::CleanupFilter, Filter::AmpFilter])
pipeline.call("<p>hello world</p>")
```