Flatpage
===============

This is generic page that outpost users can create and bind to specific paths (e.g. '/support/leadership_circle'). There are four different kinds of flatpages:
- Normal (with sidebar)
- Full Width (no sidebar)
- KPCC In Person
- None

### Data flow:
1. When a flatpage is accessed, it goes to the `handle_flatpage` method of the FlatpageHandler in `controllers/flatpage_handler`.
2. `handle_flatpage` first checks if it is a redirect, and if it's not, renders a layout by calling the adjacent function `flatpage_layout_template`.
3. Inside `flatpage_layout_template`, the template style is passed into the `FLATPAGE_TEMPLATE_MAP` and stored in the variable `template` - if `template` is nil, then the `application` view is rendered.
4. In `views/flatpages/show.html.erb`, the flatpage cell is rendered. There are also two checks. If the flatpages template is none, do not include the metadata, title, and vertical social tools. If the flatpage is set to 'inherit' (or 'sidebar'), then the advertisement and popular article cells should be rendered.
5. In `cells/flatpage`, the `.template` attribute is being used to concatenate into a modifying css class that looks like this: `o-flatpage--<%= model.template %>`. That class would resolve into `o-flatpage--full` for a full-width flatpage.
6. In `assets/stylesheets/layouts`, each template layout has its own style declarations (e.g. `o-flatpage--full` has a width of $col * 15).