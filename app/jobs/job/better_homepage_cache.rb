# Cache the homepage sections.
module Job
  class BetterHomepageCache < Base
    class << self
      def queue; QUEUES[:mid_priority]; end

      def perform
        homepage = ::BetterHomepage.current.last
        return if !homepage

        content  = homepage.content

        self.cache(content, "better_homepage/contents", "better_homepage/contents")
      end
    private
      def latest_headlines homepage
        ignore_obj_keys = homepage.content
          .order("position ASC")
          .limit(2).map{|c| "#{c.class.to_s.underscore}-#{c.id}"}
        ContentBase.active_query do |query|
          query
            .where("status = 5", "category_id IS NOT NULL")
            .where("id NOT IN (?)", ignore_obj_keys)
            .order("published_at DESC").limit(5)
        end 
      end  
    end
  end
end
