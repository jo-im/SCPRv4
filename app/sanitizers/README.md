# Sanitizers
Use these with the #sanitize helper provided by the *rails-html-sanitizer* gem.

## Example
```
<%= sanitize @article.body, scrubber: MyScrubber.new %>
```