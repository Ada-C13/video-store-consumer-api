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
end
