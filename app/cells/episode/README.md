# Episode Cell
https://www.scpr.org/programs/airtalk/:year/:month/:day/:id/
This is a one-column cell that features the episode date and title at the top, and lists related content (usually show segments) underneath.

---

## Methods

#### `related_content`
- **Input:** @options[:content]
- **Output:** Heterogeneous collection of content records, type: array
- **Tests:** `spec/cells/episode.rb`
- This is a passive method that takes and returns the content option. If the content option is nil, it defaults to an empty array. The content option is taken from the instance variable, @content, which is generated in this concern: https://github.com/SCPR/SCPRv4/blob/master/app/concerns/concern/controller/show_episodes.rb