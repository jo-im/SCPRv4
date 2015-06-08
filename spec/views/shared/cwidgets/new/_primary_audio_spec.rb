require "spec_helper"

describe "new/_primary_audio.html.erb" do
  article = nil
  options = nil
  before :each do
    article = OpenStruct.new({
      short_title: "Test title",
      audio: [OpenStruct.new({
        duration: 330,
        url: "#",
      })]
    })
    options = {context: ""}
  end
  it "displays a custom prompt" do
    options[:prompt] = "Listen to this episode"
    render "shared/cwidgets/new/primary_audio", options: options, article: article
    expect(rendered).to match /Listen to this episode/i
  end
  it "displays a default prompt if none is provided" do
    render "shared/cwidgets/new/primary_audio", options: options, article: article
    expect(rendered).to match /Listen to this story/i    
  end
end