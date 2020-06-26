class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      if params[:query].empty?
        render status: :not_found, json: { errors: { query: ["Please enter a search query"] } }
        return
      else
        data = MovieWrapper.search(params[:query])
        if data.empty?
          render status: :not_found, json: { errors: { query: ["No movie matching the query \"#{params[:query]}\""] } }
          return
        end
      end
    elsif params[:showcase]
      if params[:showcase] == "recently_added"
        data = Movie.recently_added
      elsif params[:showcase] == "popular"
        data = Movie.popular
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
    movie = Movie.new(movie_params)
    movie.inventory = 5
    if Movie.find_by(external_id: movie.external_id)
      render status: :bad_request, json: { errors: { external_id: ["#{movie.title} is already in library"] } }
    else
      movie.save
      render status: :ok, json: movie
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
    return params.permit(:title, :overview, :release_date, :external_id, :image_url)
  end
end
