module Job
  class Indexer < Base
    class << self

      def queue; QUEUES[:mid_priority]; end

      def perform(klass,id,action)
        obj = (klass.constantize).find_by id:id

        case action.to_sym
        when :create,:update
          if !obj
            raise "Failed to find object for indexing: #{klass}/#{id}"
          end

          # the models index (used in Outpost)
          obj.__elasticsearch__.index_document

          # update the Article index if appropriate
          if obj.respond_to?(:to_article)
            # eh, a one-item bulk operation? Not very bulk...
            ContentBase.es_client.bulk body:obj.to_article.to_es_bulk_operation
          end

        when :destroy
          k = klass.constantize
          k.__elasticsearch__.client.delete({
            index:  k.__elasticsearch__.index_name,
            type:   k.__elasticsearch__.document_type,
            id:     id,
          })

          if k.new.respond_to?(:to_article)
            ContentBase.es_client.delete({
              index:  ES_ARTICLES_INDEX,
              type:   klass.underscore,
              id:     k.obj_key(id),
            })
          end
        else
          raise "Unknown action type for Job::Indexer: #{action} (#{klass}/#{id})"
        end
      end
    end
  end
end