require 'spec_helper'

describe InlineAssets do 
  describe "#render" do
    it "replaces all placeholder tags in the body with markup" do
      stub_request(:any, /.*/).to_return(status: 200, body: "{\n  \"id\": 55966,\n  \"title\": \"Futurama\",\n  \"caption\": \"Futurama is brought to you by... Glagnar's Human Rinds! It's a buncha muncha cruncha human!\",\n  \"owner\": \"Futurama\",\n  \"size\": \"286x257\",\n  \"sizes\": {\n    \"thumb\": {\n      \"width\": 86,\n      \"height\": 87\n    },\n    \"lsquare\": {\n      \"width\": 183,\n      \"height\": 187\n    },\n    \"lead\": {\n      \"width\": 286,\n      \"height\": 257\n    },\n    \"wide\": {\n      \"width\": 286,\n      \"height\": 257\n    },\n    \"full\": {\n      \"width\": 286,\n      \"height\": 257\n    },\n    \"six\": {\n      \"width\": 286,\n      \"height\": 257\n    },\n    \"eight\": {\n      \"width\": 286,\n      \"height\": 257\n    },\n    \"four\": {\n      \"width\": 286,\n      \"height\": 257\n    },\n    \"three\": {\n      \"width\": 255,\n      \"height\": 229\n    },\n    \"five\": {\n      \"width\": 286,\n      \"height\": 257\n    },\n    \"small\": {\n      \"width\": 286,\n      \"height\": 257\n    }\n  },\n  \"tags\": {\n    \"thumb\": \"<img src=\\\"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-thumb.jpg\\\" width=\\\"86\\\" height=\\\"87\\\" alt=\\\"Futurama\\\" />\",\n    \"lsquare\": \"<img src=\\\"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-lsquare.jpg\\\" width=\\\"183\\\" height=\\\"187\\\" alt=\\\"Futurama\\\" />\",\n    \"lead\": \"<img src=\\\"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-lead.jpg\\\" width=\\\"286\\\" height=\\\"257\\\" alt=\\\"Futurama\\\" />\",\n    \"wide\": \"<img src=\\\"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-wide.jpg\\\" width=\\\"286\\\" height=\\\"257\\\" alt=\\\"Futurama\\\" />\",\n    \"full\": \"<img src=\\\"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-full.jpg\\\" width=\\\"286\\\" height=\\\"257\\\" alt=\\\"Futurama\\\" />\",\n    \"six\": \"<img src=\\\"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-six.jpg\\\" width=\\\"286\\\" height=\\\"257\\\" alt=\\\"Futurama\\\" />\",\n    \"eight\": \"<img src=\\\"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-eight.jpg\\\" width=\\\"286\\\" height=\\\"257\\\" alt=\\\"Futurama\\\" />\",\n    \"four\": \"<img src=\\\"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-four.jpg\\\" width=\\\"286\\\" height=\\\"257\\\" alt=\\\"Futurama\\\" />\",\n    \"three\": \"<img src=\\\"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-three.jpg\\\" width=\\\"255\\\" height=\\\"229\\\" alt=\\\"Futurama\\\" />\",\n    \"five\": \"<img src=\\\"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-five.jpg\\\" width=\\\"286\\\" height=\\\"257\\\" alt=\\\"Futurama\\\" />\",\n    \"small\": \"<img src=\\\"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-small.jpg\\\" width=\\\"286\\\" height=\\\"257\\\" alt=\\\"Futurama\\\" />\"\n  },\n  \"urls\": {\n    \"thumb\": \"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-thumb.jpg\",\n    \"lsquare\": \"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-lsquare.jpg\",\n    \"lead\": \"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-lead.jpg\",\n    \"wide\": \"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-wide.jpg\",\n    \"full\": \"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-full.jpg\",\n    \"six\": \"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-six.jpg\",\n    \"eight\": \"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-eight.jpg\",\n    \"four\": \"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-four.jpg\",\n    \"three\": \"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-three.jpg\",\n    \"five\": \"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-five.jpg\",\n    \"small\": \"http://a.scpr.org/i/8f185f3605ea8bf958ed13feff8919d9/55966-small.jpg\"\n  },\n  \"url\": \"http://a.scpr.org/api/assets/55966/\",\n  \"notes\": \"Fetched from URL: http://i.imgur.com/0csRtwS.png?2\",\n  \"created_at\": \"2013-02-28T20:01:46Z\",\n  \"taken_at\": \"2013-02-28T20:01:46Z\",\n  \"native\": null,\n  \"image_file_size\": 99450\n}\n", headers: {})
      result = InlineAssets.render("
        <h2>Inline Assets Test</h2>
        <p>lorem ipsum</p>
        <img class=\"inline-asset\" data-asset-id=\"107507\" src=\"#\">
        <p>dolor sit amet</p>
      ")
      expect(result).to_not include("<img class=\"inline-asset\" data-asset-id=\"107507\" src=\"#\">")
      expect(result).to match /<img .*?src=\"http:\/\/a.scpr.org\/i\/[a-z0-9]+\/[a-z0-9]+-full.jpg\">/
    end
    it "leaves the placeholder tag if the asset is not found" do
      stub_request(:any, /.*/).to_return(status: 404, body: "Sorry amigo.", headers: {})
      result = InlineAssets.render("
        <h2>Inline Assets Test</h2>
        <p>lorem ipsum</p>
        <img class=\"inline-asset\" data-asset-id=\"107507\" src=\"#\">
        <p>dolor sit amet</p>
      ")
      expect(result).to include("<img class=\"inline-asset\" data-asset-id=\"107507\" src=\"#\">")
      expect(result).to_not match /<img .*?src=\"http:\/\/a.scpr.org\/i\/[a-z0-9]+\/[a-z0-9]+-full.jpg\">/
    end
  end
end