require "byebug"
class PostsController < ApplicationController
    include Secured
    before_action :authenticate_user!, only: [:create, :update]

    rescue_from Exception do |e|
        render json: {error: e.message}, status: :internal_error
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
        render json: {error: e.message}, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
        render json: {error: e.message}, status: :unprocessable_entity
    end

    # GET /posts
    def index
        @posts = Post.where(published: true)
        #if params[:search].nil? && params[:search].present?
        if params[:search].present?
            @posts = PostsSearchService.search(@posts, params[:search])
        end
        #byebug
        render json: @posts.includes(:user), status: :ok
    end

    # GET /posts/{id}
    # byebug
    def show
        @post = Post.find(params[:id])
        if @post.published? || (Current.user && @post.user_id == Current.user.id)
            render json: @post, status: :ok
        else
            render json: {error: 'Not found'}, status: :not_found
        end
    end

    # POST /posts
    def create
        # byebug
        @post = Current.user.posts.create!(create_params)
        render json: @post, status: :created
    end

    # PUT /posts/{id}
    def update
        @post = Current.user.posts.find(params[:id])
        @post.update!(update_params)
        render json: @post, status: :ok
    end

    private

    def create_params
        params.require(:post).permit(:title, :content, :published)
    end

    def update_params
        params.require(:post).permit(:title, :content, :published)
    end
end

