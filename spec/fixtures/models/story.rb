module TestClass
  class Story < ActiveRecord::Base
    self.table_name = "test_class_stories"
    
    include Concern::Scopes::SinceScope
    include Concern::Scopes::PublishedScope
    
    include Concern::Associations::AssetAssociation
    include Concern::Associations::AudioAssociation
    include Concern::Associations::ContentAlarmAssociation
    include Concern::Associations::RelatedContentAssociation
    include Concern::Associations::RelatedLinksAssociation
    include Concern::Associations::BylinesAssociation
    include Concern::Associations::CategoryAssociation
    
    include Concern::Callbacks::GenerateShortHeadlineCallback
    include Concern::Callbacks::GenerateTeaserCallback
    include Concern::Callbacks::SetPublishedAtCallback
    include Concern::Callbacks::GenerateSlugCallback
    include Concern::Callbacks::SphinxIndexCallback
    include Concern::Callbacks::HomepageCachingCallback
    
    include Concern::Methods::CommentMethods
    include Concern::Methods::PublishingMethods
    include Concern::Methods::StatusMethods
    
    include Concern::Validations::ContentValidation

    validates :short_url, url: { allow_blank: true, allowed: [URI::HTTP, URI::FTP] }
    
    def obj_key
      "test_class_story:#{id}"
    end
  end
end
