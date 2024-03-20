class PostsSearchService
    def self.search(current_post, query)
        # {k => v}
        posts_ids = Rails.cache.fetch("posts_search/#{query}", expires_in: 1.hours) do 
            current_post.where("title like '%#{query}%'").map(&:id)
        end
        # current_post.where("title like '%#{query}%'")
        current_post.where(id: posts_ids)
    end
end