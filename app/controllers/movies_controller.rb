class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  # def create
  #   new_movie = MovieWrapper.construct_movie(params)
  #   new_movie.inventory = 10

  #   if new_movie.save
  #     render status: :ok, json: {}
  #   else
  #     render status: :bad_request, json: { errors: new_movie.errors.messages }
  #   end
  # end

  def create
    new_movie = Movie.new(movie_params)
    new_movie.inventory = 5

    if new_movie.save
      render status: :ok, json: {}
      return
    else
      render status: :bad_request, json: { errors: new_movie.errors.messages }
      return
    end
  end

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

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

  def movie_params
    params.permit(:title, :overview, :release_date, :image_url, :external_id)
  end
end
