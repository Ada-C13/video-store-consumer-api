class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      @movies = Movie.where("title ilike ?", "%#{params[:query]}%").all
      if !@movies.empty?
        data = @movies
      else
        data = MovieWrapper.search(params[:query])
      end
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
    raise
    movie = Movie.new(
      title: params[:title],
      overview: params[:overview],
      release_date: params[:release_date],
      image_url: params[:image_url],
      inventory: 1
    )
    if movie.save
      render status: :ok, json: { success: "success" }
    else
      render status: :bad_request, json: { errors: rental.errors.messages }
    end
  end

  private

  def require_movie
    @movie = Movie.find_by(title: params[:title])
    unless @movie
      render status: :not_found, json: { errors: { title: ["No movie with title #{params["title"]}"] } }
    end
  end
end
