# Upcoming Events List Cell
https://www.scpr.org/events/kpcc-in-person
This is a two-column cell that lists current and upcoming events for the KPCC In Person Landing page.

---

## Methods

#### `asset_position`
- **Input:** Event
- **Output:** Image gravity, type: string
- **Tests:** `spec/cells/upcoming_events_list_spec.rb`
- Since these images are in a square aspect ratio, there are many times when a subject is cut off. This method uses the `image_gravity` property exposed by AssetHost to apply the positioning via the css property, `background-position: {image_gravity}`.