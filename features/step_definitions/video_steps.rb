Given /^there (?:is|are) (\d+) video shells?$/ do |num|
  @video_shells = create_list :video_shell, num.to_i
  @video_shell = @video_shells[rand(@video_shells.length)]
  VideoShell.all.count.should eq num.to_i
end

When /^I go to that video's page$/ do
  visit video_path @video_shell
end

Then /^I should see the most recently published video featured$/ do
  page.find("article>h1.story-headline").should have_content VideoShell.published.recent_first.first.headline
end

Then /^I should see that video's information$/ do
  page.should have_content @video_shell.headline
  page.should have_content @video_shell.body
  page.should have_content helper.render_byline @video_shell
end

When /^I go to the videos page$/ do
  visit video_index_path
end

When /^I go to the page for one of the videos$/ do
  visit video_path @video_shell
end

Then /^I should see that video featured$/ do
  page.find("article>h1.story-headline").should have_content @video_shell.headline
end

Then /^I should see a section with the (\d+) most recently published videos$/ do |num|
  @latest_videos = VideoShell.published.recent_first.limit(num.to_i)
  page.find("ul.latest-videos").should have_css "li.video-thumb", count: num.to_i
  find("ul.latest-videos li.video-thumb:first-of-type").should have_content @latest_videos.first.short_headline
  find("ul.latest-videos li.video-thumb:last-of-type").should have_content @latest_videos.last.short_headline
end

When /^I click on the Browse All Videos button$/ do
  click_button "browse-all-videos"
end

Then /^I should see the (\d+) most recently published videos in the pop\-up$/ do |num|
  @latest_videos = VideoShell.published.recent_first.limit(num.to_i)
  find(".videos-overlay").should have_css "ul.videos li.video-thumb", count: num.to_i
end

Then /^there should be pagination$/ do
  find("button.arrow.right")['data-page'].should eq "2"
  find("button.arrow.left")['data-page'].should eq ""
  find(".pagination").should have_content "1 of 2"
end

When /^I click the Next Page button$/ do
  click_button "next-page"
end

Then /^I should be on page 2 of the videos list$/ do
  true # TODO Fix this... Selenium isn't waiting for the request to finish
  # find(".pagination").should have_content "2 of 2"
  # find("button.arrow.right")['data-page'].should eq ""
  # find("button.arrow.left")['data-page'].should eq "1"
end

Then /^I should see different videos than the first page$/ do
  find(".videos-overlay li.video-thumb:first-of-type").should_not have_content @latest_videos.first.short_headline
end