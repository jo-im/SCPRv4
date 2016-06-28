require 'spec_helper'

describe Concern::Associations::FeatureAssociation do
  describe '#feature' do
    it "gets the aricle's feature" do
      story = create :test_class_story, feature_type_id: 1

      story.feature.key.should eq :slideshow
    end

    it "is nil if it doesn't have a feature" do
      story = create :test_class_story, feature_type_id: nil

      story.feature.should be_nil
    end

    context "no feature id provided" do
      context "on publish" do
        context "has audio" do
          it "assigns audio as feature type" do
            story = create :test_class_story
            story.audio << create(:audio, :external)
            story.status = 5
            story.save
            expect(story.feature.key).to eq :audio
          end
        end
        context "asset display is slideshow" do
          it "assigns slideshow as feature type" do
            story = create :test_class_story
            story.asset_display = :slideshow
            story.status = 5
            story.save
            expect(story.feature.key).to eq :slideshow
          end
        end
        it "doesn't override existing feature type" do
          story = create :test_class_story, feature_type_id: 3
          story.asset_display = :slideshow
          story.status = 5
          story.save
          expect(story.feature_type_id).to eq 3
        end
      end
      context "before publish" do
        it "does nothing" do
          story = create :test_class_story
          story.asset_display = :slideshow
          story.status = 0
          story.save
          expect(story.feature).to be_nil
        end
      end
    end
  end


  describe '#feature=' do
    let(:feature) { ArticleFeature.find_by_id(1) }

    context 'with ArticleFeature' do
      it 'assigns the feature' do
        story = create :test_class_story, feature_type_id: nil

        story.feature = feature
        story.feature_type_id.should eq 1
      end
    end

    context 'with String' do
      it 'assigns the feature' do
        story = create :test_class_story, feature_type_id: nil

        story.feature = "slideshow"
        story.feature_type_id.should eq 1
      end
    end

    context 'with Symbol' do
      it 'assigns the feature' do
        story = create :test_class_story, feature_type_id: nil

        story.feature = :slideshow
        story.feature_type_id.should eq 1
      end
    end

    context 'with Integer' do
      it 'assigns the feature' do
        story = create :test_class_story, feature_type_id: nil

        story.feature = 1
        story.feature_type_id.should eq 1
      end
    end

    context 'with NilClass' do
      it 'unassigns the feature' do
        story = create :test_class_story, feature_type_id: 1

        story.feature.should eq feature
        story.feature = nil
        story.feature_type_id.should be_nil
      end
    end
  end
end
