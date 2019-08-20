module Job
  class Indexer < Base
    include Resque::Plugins::UniqueJob
    class << self
      def queue; QUEUES[:low_priority]; end

      def perform(klass,id,action)
        obj = (klass.constantize).find_by id:id

        case action.to_sym
        when :create,:update
          if !obj
            raise "Failed to find object for indexing: #{klass}/#{id}"
          end
          obj.index # index to ES
        when :destroy
          k = klass.constantize
          k.__elasticsearch__.client.delete({
            index:  k.__elasticsearch__.index_name,
            type:   k.__elasticsearch__.document_type,
            id:     id,
          })

          if k.new.respond_to?(:to_article)
            ContentBase.es_client.delete({
              index:  ContentBase.es_index,
              type:   klass.underscore,
              id:     k.obj_key(id),
            })
          end
        else
          raise "Unknown action type for Job::Indexer: #{action} (#{klass}/#{id})"
        end

        # I don't like putting this here, but I'm not sure how else to do
        # it at the moment.
        if Rails.env.test?
          ContentBase.es_client.indices.refresh index:"_all"
        end
      end
    end
  end
end