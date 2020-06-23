require 'test_helper'

class MovieTest < ActiveSupport::TestCase
  let (:movie_data) {
    {
      "title": "Hidden Figures",
      "overview": "Some text",
      "release_date": "1960-06-16",
      "inventory": 8,
      "external_id": 100001
    }
  }

  before do
    @movie = Movie.new(movie_data)
  end

  describe "Constructor" do
    it "Can be created" do
      Movie.create!(movie_data)
    end

    it "Has rentals" do
      @movie.must_respond_to :rentals
    end

    it "Has customers" do
      @movie.must_respond_to :customers
    end
  end

  describe "available_inventory" do
    it "Matches inventory if the movie isn't checked out" do
      # Make sure no movies are checked out
      Rental.destroy_all
      Movie.all.each do |movie|
        movie.available_inventory().must_equal movie.inventory
      end
    end

    it "Decreases when a movie is checked out" do
      Rental.destroy_all

      movie = movies(:one)
      before_ai = movie.available_inventory

      Rental.create!(
        customer: customers(:one),
        movie: movie,
        due_date: Date.today + 7,
        returned: false
      )

      movie.reload
      after_ai = movie.available_inventory
      after_ai.must_equal before_ai - 1
    end

    it "Increases when a movie is checked in" do
      Rental.destroy_all

      movie = movies(:one)

      rental =Rental.create!(
        customer: customers(:one),
        movie: movie,
        due_date: Date.today + 7,
        returned: false
      )

      movie.reload
      before_ai = movie.available_inventory

      rental.returned = true
      rental.save!

      movie.reload
      after_ai = movie.available_inventory
      after_ai.must_equal before_ai + 1
    end
  end
end
