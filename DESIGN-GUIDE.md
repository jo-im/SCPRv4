Design Guide
============

It is the opinion of Ben that the codebase for SCPR.org should eventually be in a state where a new developer should be able to implement a new feature in the same day they get the codebase running in a development environment.  This design guide is a step in that direction.  Comprehending the inner workings of the site should not require digging or depend heavily on an oracle with undocumented knowledge.  By working with new conventions and describing them in this guide, I hope to make the lives of our programmers easier, increase development time, and promote practices that reduce the number of potential issues.

## Templates & Cells

Traditionally, Rails has "layouts", "templates", and "partials" that all reside underneath "app/views".  This gets pretty complicated when a project gets large and pages vary significantly.  It gets to be a headache when the views directory becomes a deeply nested network of templates and partials that don't directly correspond to style sheet files, helper files, or presenters.

To make things more comprehensible, I decided to introduce the concept of "Cells", which are like components or "view controllers" that reside under "app/cells", outside of "app/views".  In this dichotomy, views should have more of a focus on pure layout and cells should represent specific concepts in pages and have their own scoped logic, templates, and style sheets.

A well-designed cell should be able to live on its own and can be invoked outside of ActionView and ActionController.  Sadly, this is difficult to pull off because Rails' dopey path helpers depend on ActionController.  In an ideal universe, a cell should be able to work without Rails or at least with only ActiveRecord calls, when necessary.  Do your best to make each cell as if they are their own app.  This often isn't completely possible, but the less coupled our system components are, the better.

Prioritize simplicity over premature optimization and code-sharing.  In other words, don't worry so much if logic gets duplicated.  

If a cell is complicated or not self-explanatory, include a README.md file inside the cell's own directory and provide some basic documentation.

Learn more about Cells [here](http://trailblazer.to/gems/cells/).

## Style Sheets

As mentioned above, style sheets that describe the display of page components should go in the directory for the corresponding cell.  This is just to keep things organized and have all the important pieces of a component in one place.  Style sheets that describe the behavior of the layout should go in `app/assets/stylesheets`.  Every style sheet should be named after the page being laid out, and be imported into `application.css.sass`.

When designing the stylesheet for a cell, the intended position, width, and margin it will have on its destination page(s) should not be taken into account.  Style properties involving layout should instead be handled in the stylesheet for a page that will include that cell.

### BEM

BEM stands for Block-Element-Modifier, which is the naming convention we want to use for CSS selectors going forward from now.  Anything that doesn't currently follow it is old and should be considered for deprecation.

An example of a BEM class name:

`news-article__audio-player--playing`

Our BEM classes are often prefixed with a letter denoting whether or not it's intended for layout(l), basic text(b), components(c), or objects(o).  This is not a required convention, but it's encouraged.  

When it comes to individual names in a class name, I use *kabob-case* for names in BEM as opposed to *camelCase*.  Either one is appropriate.

