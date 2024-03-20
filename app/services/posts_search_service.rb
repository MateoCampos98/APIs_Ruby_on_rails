class PostsSearchService
    def self.search(current_post, query)
        current_post.where("title like '%#{query}%'")      
    end
end