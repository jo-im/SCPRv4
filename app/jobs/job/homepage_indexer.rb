module Job
  class HomepageIndexer < Base # For the new homepage model, not the old one.
    class << self

      def queue; QUEUES[:mid_priority]; end

      def perform(id,action)
        obj = BetterHomepage.where(id: id).first!

        case action.to_sym
        when :create,:update
          obj.index # index to ES
        when :destroy
          obj.unindex
        else
          raise "Unknown action type for Job::HomepageIndexer: #{action} (id:#{id})"
        end

        # I don't like putting this here, but I'm not sure how else to do
        # it at the moment.
        if Rails.env.test?
          BetterHomepage.es_client.indices.refresh index:"_all"
        end

      rescue ActiveRecord::RecordNotFound
        raise "Failed to find homepage for indexing with id: #{id}"
      end
    end
  end
end