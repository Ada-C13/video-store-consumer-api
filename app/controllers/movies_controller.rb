class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query])
    else
      data = Movie.all
    end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @movie.as_json(
        only: [:title, :overview, :release_date, :inventory],
        methods: [:available_inventory]
        )
      )
  end

  def create 
    movie = Movie.new(movie_params)
    existing_movie = Movie.find_by(external_id: movie.external_id)

    # if movie was already added to library, update inventory
    if existing_movie
      existing_movie.inventory = existing_movie.inventory + 1
      existing_movie.save
      return
    else
      # else save new movie to database
      if movie.save 
        render json: movie.as_json(only: [:id]), status: :created
        return
      else
        render json: {
          errors: movie.errors.messages
          }, status: :bad_request
          return   
      end
    end

  end 

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

  def movie_params
    return params.permit(:title, :overview, :release_date, :image_url, :external_id, :inventory)
  end
end

