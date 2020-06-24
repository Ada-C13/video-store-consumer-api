class MoviesController < ApplicationController
  before_action :require_movie, only: [:show]

  def index
    if params[:query]
      data = MovieWrapper.search(params[:query]) # all ids are null, external_id is not null
      hash = {} # {external_id => id}
      Movie.all.select(:id, :external_id).each {|movie| hash[movie.external_id] = movie.id }
      data.each_with_index do |item,i|
        data[i][:id] = hash[item[:external_id]]
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
    movie = Movie.new(
      title: params[:title],
      overview: params[:overview],
      release_date: params[:release_date],
      image_url: params[:image_url],
      inventory: 1,
      external_id: params[:external_id]
    )
    if movie.save
      render status: :ok, json: movie
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
