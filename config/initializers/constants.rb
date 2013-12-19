DESCENDING = "DESC"
ASCENDING  = "ASC"

DFP_ADS = YAML.load_file("#{Rails.root}/config/dfp_ads.yml")

RSS_SPEC = {
  'version'       => '2.0',
  'xmlns:dc'      => "http://purl.org/dc/elements/1.1/",
  'xmlns:atom'    => "http://www.w3.org/2005/Atom"
}

SPHINX_MAX_MATCHES = 1000
STATIC_TABLES      = %w{ permissions }

CONNECT_DEFAULTS = {
  :facebook      => "http://www.facebook.com/kpccfm",
  :twitter       => "kpcc",
  :rss           => "http://wwww.scpr.org/feeds/all_news",
  :podcast       => "http://www.scpr.org/podcasts/news",
  :web           => "http://scpr.org"
}


ITUNES_CATEGORIES = {
  1     => "Arts",
  2     => "Design",
  3     => "Fashion &amp; Beauty",
  4     => "Food",
  5     => "Literature",
  6     => "Performing Arts",
  7     => "Visual Arts",
  8     => "Business",
  9     => "Business News",
  10    => "Careers",
  11    => "Investing",
  12    => "Management &amp; Marketing",
  13    => "Shopping",
  14    => "Comedy",
  15    => "Education",
  16    => "Education",
  17    => "Education Technology",
  18    => "Higher Education",
  19    => "K-12",
  20    => "Language Courses",
  21    => "Training",
  22    => "Games &amp; Hobbies",
  23    => "Automotive",
  24    => "Aviation",
  25    => "Hobbies",
  26    => "Other Games",
  27    => "Video Games",
  28    => "Government &amp; Organizations",
  29    => "Local",
  30    => "National",
  31    => "Non-Profit",
  32    => "Regional",
  33    => "Health",
  34    => "Alternative Health",
  35    => "Fitness &amp; Nutrition",
  36    => "Self-Help",
  37    => "Sexuality",
  38    => "Kids &amp; Family",
  39    => "Music",
  40    => "News &amp; Politics",
  41    => "Religion &amp; Spirituality",
  42    => "Buddhism",
  43    => "Christianity",
  44    => "Hinduism",
  45    => "Islam",
  46    => "Judaism",
  47    => "Other",
  48    => "Spirituality",
  49    => "Science &amp; Medicine",
  50    => "Medicine",
  51    => "Natural Sciences",
  52    => "Social Sciences",
  53    => "Society &amp; Culture",
  54    => "History",
  55    => "Personal Journals",
  56    => "Philosophy",
  57    => "Places &amp; Travel",
  58    => "Sports &amp; Recreation",
  59    => "Amateur",
  60    => "College &amp; High School",
  61    => "Outdoor",
  62    => "Professional",
  63    => "Technology",
  64    => "Gadgets",
  65    => "Tech News",
  66    => "Podcasting",
  67    => "Software How-To",
  68    => "TV &amp; Film"
}
