Featured Story
==============

This is another instance where we are expecting something in the form of an Article.  That rule should apply to both KPCC and external content.  It's intended to be displayed on conceptual landing pages like the program landing page.

## Use

The concept of a "featured story" appears in a few different contexts, so there are multiple templates for this cell.  For example, vertical landing pages have a featured story with a different styling and extra elements.  This is an example of how we can render a vertical page styled featured story:

```ruby
  cell(:featured_story, @vertical.featured_articles.first).call(:vertical)
```

