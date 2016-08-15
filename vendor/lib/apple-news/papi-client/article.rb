# Copyright (C) 2015 Apple Inc. All Rights Reserved.
#
# See LICENSE.txt for this sample’s licensing information

require "papi-client/papi-thor"

module PapiClient
    class Article < PapiThor
        desc "publish ARTICLE_DIR", "Publish an article with the given directory of resources"
        option :is_candidate_to_be_featured, type: :boolean
        option :is_sponsored, type: :boolean
        option :is_preview, type: :boolean
        option :section_ids, type: :string
        option :is_developing_story, type: :boolean
        option :maturity_rating, type: :string
        def publish(article_dir)
            output {
                client.publish_article(
                    options,
                    article_dir
                )
            }
        end

        desc "get ID", "Get the article with the given id"
        def get(id)
            output { client.get_article(id) }
        end

        desc "delete ID", "Delete the article with the given id"
        def delete(id)
            output { client.delete_article(id) }
        end

        desc "update ID REVISION", "Update the article with the given id"
        option :article_dir, type: :string
        option :is_sponsored, type: :boolean
        option :is_preview, type: :boolean
        option :section_ids, type: :string
        def update(id, revision)
            output {
                client.update_article(id, revision,
                    options
                )
            }
        end

        desc "search", "Search and list articles by channel or section"
        option :page_token
        option :page_size
        option :from_date
        option :to_date
        option :sort_dir
        option :section_id
        def search()
            output {
                client.search_articles(
                    options[:channel_id],
                    options[:page_token],
                    options[:page_size],
                    options[:from_date],
                    options[:to_date],
                    options[:sort_dir],
                    options[:section_id]
                )
            }
        end
    end
end
