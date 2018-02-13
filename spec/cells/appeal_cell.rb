require "spec_helper"

describe AppealCell do
  describe "GET" do
    before :each do
      # Create an external program
      @program = build :external_program
    end
    
    it "does not render the cell if no podcast or xml link is given" do
      cell_instance = cell(:appeal, @program)
      expect(cell_instance.call(:podcast)).to eq ""
    end
    
    it "renders a podcast subscribe link if there is one" do
      @program.related_links.build(title: "Podcast", url: "http://itunes.apple.com/some/itunes/link", link_type: "podcast")
      cell_instance = cell(:appeal, @program)
      expect(cell_instance.call(:podcast)).to include 'Subscribe via iTunes'
    end
    
    it "renders an XML link if there is one" do
      @program.related_links.build(title: "RSS", url: "show.com/airtalk", link_type: "rss")
      cell_instance = cell(:appeal, @program)
      expect(cell_instance.call(:podcast)).to include 'Any podcast app (XML)'
    end
  end
end