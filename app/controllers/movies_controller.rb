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
# new movie

  def add_movie
    new_movie = Movie.new(external_id: movie_params[:external_id], title: movie_params[:title],overview: movie_params[:overview], release_date: movie_params[:release_date], image_url: movie_params[:image_url] )
    if !Movie.find_by(external_id: new_movie.external_id)

      if new_movie.save
        render status: :ok, json: {}
      else
        render status: :bad_request, json: { errors: movie.errors.messages }
      end

    else   
      render status: :bad_request, json: {errors: "movie already in database"}
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

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end

  def movie_params
    return params.permit(:external_id, :title, :inventory, :overview, :release_date, :image_url)
  end

end
