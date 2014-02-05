module Job
  class AudioVisionCache < Base
    @priority = :low

    class << self
      def perform
        current_billboard_key = "audiovision:current_billboard"
        featured_post_key     = "scprv4:homepage:av-featured-post"

        current_billboard = AudioVision::Billboard.current
        cached_billboard  = Rails.cache.read(current_billboard_key)
        current_featured  = Rails.cache.read(featured_post_key)

        if current_billboard && !current_billboard.posts.empty?
          featured = nil

          # When this task gets run:
          #
          # * If the updated timestamp of the billboard
          #   has changed, then use the first post.
          #
          # * If there is only one post on this billboard, use it.
          #
          # * Otherwise, use a random post that isn't
          #   the currently featured post.
          #
          if !cached_billboard ||
          current_billboard.posts.size == 1 ||
          current_billboard.updated_at > cached_billboard.updated_at
            featured = current_billboard.posts.first
          else
            featured = current_billboard.posts.select do |p|
              p.id != current_featured.id
            end

            featured = featured.sample
          end

          if featured
            Rails.cache.write(current_billboard_key, current_billboard)
            Rails.cache.write(featured_post_key, featured)

            self.cache(
              featured,
              "/home/cached/audiovision",
              "views/home/audiovision",
              local: :post
            )
          end
        end
      end
    end
  end
end
