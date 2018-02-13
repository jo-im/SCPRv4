Appeal
======

An appeal is an aside that appears anywhere in the middle of article or landing pages that serves a marketing purpose and provides an action the user can take.  An example would be a newsletter signup form or an ad for our mobile app.

## Use

There are a few different appeal templates available.  For example, to render the newsletter appeal:

```ruby
  cell(:appeal).call(:newsletter)
```

---

## Methods

#### `has_podcast_links`
- **Input:** model (`kpccprogram`, `external_program`)
- **Output:** boolean
- **Tests:** `spec/cells/appeal_cell.rb`
- This function uses the `ProgramPresenter` to check if there are podcast or xml links associated to the current program. It's then tied to the render of the `podcast` block so that we don't render the cell if we don't have any links.