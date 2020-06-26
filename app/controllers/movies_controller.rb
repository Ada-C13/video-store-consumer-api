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

  def create
    if Movie.find_by(title: params[:title])
      render json: {
        errors: ["movie already exists"]
      }, status: :bad_request
      return
    end
    movie = Movie.new(movie_params)
    if movie.save
      render json: movie.as_json(only: [:id]), status: :created
      return
    else
      puts movie.errors.messages
      render json: {
          errors: movie.errors.messages
        }, status: :bad_request
      return
      puts "these are the error messages #{movie.errors.messages}"
    end
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

  private

  def movie_params
    return params.permit(:title, :overview, :release_date, :total_inventory, :image_url, :external_id)
  end


  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
