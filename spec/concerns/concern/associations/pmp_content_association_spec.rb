require "spec_helper"

describe Concern::Associations::PmpContentAssociation do
  describe Concern::Associations::PmpContentAssociation::StoryProfile do

    context 'publish_to_pmp? set to true' do
      context 'published news story' do
        it "creates a PmpContent record" do
          content = create :news_story, publish_to_pmp: true
          expect(content.pmp_content).not_to eq(nil)
        end
      end
    end

    context 'publish_to_pmp? set to false' do
      context 'draft status news story' do
        it "doesn't create a PmpContent record" do
          content = create :news_story, publish_to_pmp: false
          expect(content.pmp_content).to eq(nil)
        end
      end
      context 'published news story' do
        context 'with existing pmp_content' do
          it 'destroys the PmpContent record' do
            content = create :news_story, publish_to_pmp: true
            expect(content.pmp_content).not_to eq(nil)
            content.update publish_to_pmp: false
            content.reload
            expect(content.pmp_content).to eq(nil)
          end
        end
      end
    end

    describe 'versions' do
      context 'published_to_pmp? changes' do
        context 'from false to true' do
          it 'is included in a version' do
            content = create :news_story
            content.update publish_to_pmp: true
            expect(content.versions.last.object_changes['publish_to_pmp']).to eq ['false', 'true']
          end
        end
        context 'from true to false' do
          it 'is included in a version' do
            content = create :news_story, publish_to_pmp: true
            content.update publish_to_pmp: false
            expect(content.versions.last.object_changes['publish_to_pmp']).to eq ['true', 'false']
          end
        end
        it 'is included with other changes in version' do
          content = create :news_story
          content.update publish_to_pmp: true, headline: "a new headline"
          expect(content.versions.last.object_changes['publish_to_pmp']).to be
          expect(content.versions.last.object_changes['headline']).to include('a new headline')
        end
      end
      context 'published_to_pmp? does not change' do
        it 'is not included in a version' do
          content = create :news_story, publish_to_pmp: true
          content.update headline: "Title changed"
          expect(content.versions.last.object_changes['publish_to_pmp']).to eq nil
        end
      end
    end

    describe '#pmp_permission_groups' do
      context 'content has california-counts tag' do
        it 'returns a link' do
          tag = Tag.create slug: 'california-counts', title: "California Counts", description: "California Counts"
          group = PmpGroup.create(title: "California Counts", guid: "123456789")
          story = create :news_story, tags: [tag]
          expect(story.pmp_permission_groups.pop.class).to eq PMP::Link
        end
      end
      context 'content has no california-counts tag' do
        it 'returns nothing' do
          story = create :news_story
          expect(story.pmp_permission_groups.pop).to eq nil
        end
      end
    end

    describe 'saving' do
      story = nil
      before do
        Resque.stub(enqueue: nil)
      end
      context 'news story is published' do
        it 'queues up a pmp content publish' do
          story = create :news_story, status: 0, publish_to_pmp: true
          allow(Resque).to receive(:enqueue).and_return nil
          allow(Resque).to receive(:enqueue).and_return nil
          expect(Resque).to receive(:enqueue).with(
            Job::PublishPmpContent, "story", story.pmp_content.id).ordered
          story.update status: 5
        end
      end
      context 'news story is pending' do
        it 'queues up a pmp content publish' do
          story = create :news_story, status: 0, publish_to_pmp: true
          allow(Resque).to receive(:enqueue).and_return nil
          allow(Resque).to receive(:enqueue).and_return nil
          expect(Resque).to receive(:enqueue).with(
            Job::PublishPmpContent, "story", story.pmp_content.id).ordered
          story.update status: 3
        end
      end
      context 'news story is updated' do 
        it 'queues up a pmp content publish' do
          story = create :news_story, status: 5, publish_to_pmp: true
          allow(Resque).to receive(:enqueue).and_return nil
          allow(Resque).to receive(:enqueue).and_return nil
          expect(Resque).to receive(:enqueue).with(
            Job::PublishPmpContent, "story", story.pmp_content.id).ordered
          story.update headline: "test headline"
        end      
      end
      context 'news story that has not changed' do 
        it 'does not add a job to the queue' do
          story = create :news_story, status: 5, publish_to_pmp: true
          story.pmp_content.update guid: "dummy guid"
          expect(Resque).to_not receive(:enqueue).with(
            Job::PublishPmpContent, "story", story.pmp_content.id).ordered
          story.update({})
        end      
      end
      context 'news story with publish_to_pmp unchecked' do
        it 'destroys the pmp_content' do
          story = create :news_story, status: 5, publish_to_pmp: true
          expect(story.pmp_content).to_not eq nil
          story.update publish_to_pmp: false
          story.reload
          expect(story.pmp_content).to eq nil
        end
      end
      context 'news story is not published' do
        it 'does not queue up a pmp content publish' do
          story = create :news_story, status: 0, publish_to_pmp: true
          expect(Resque).to_not receive(:enqueue).with(
            Job::PublishPmpContent, "story", story.pmp_content.id).ordered
          story.update status: 1
        end
      end
    end

    describe 'rendering' do
      describe 'rendered body' do
        it "renders html" do
          story = create :news_story, status: 0, publish_to_pmp: true, body: "Lorem ipsum dolor sit amet"
          rendered_body = story.rendered_body
          expect(Nokogiri::HTML(story.rendered_body).css("article").inner_text).to include story.body
        end
      end
    end
  end
end
