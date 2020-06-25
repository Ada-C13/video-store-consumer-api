require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  describe "add_movie" do 
    # adds movie
    it "will add a movie successfully" do 
      new_movie = Movie.new(external_id: 991 , title: "new testing movie",overview: "testing overview" )


      post add_movie_path, params: {
        external_id: new_movie.external_id,
        title: new_movie.title,
        overview: new_movie.overview
      }

      must_respond_with :success
      expect(Movie.count).must_equal 3
      expect(Movie.last.title).must_equal "new testing movie"


    end 
    # cannot add a movie twice
    it "cannot add a movie with the same external_id" do 

      new_movie = movies(:one)
      count = Movie.count 

      post add_movie_path, params: {
        external_id: new_movie.external_id,
        title: new_movie.title,
        overview: new_movie.overview,
        release_date: new_movie.release_date
      }

      must_respond_with :bad_request 
      expect(Movie.count).must_equal count 
    end 
  end 


  describe "index" do
    it "returns a JSON array" do
      get movies_url
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Array
    end

    it "should return many movie fields" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.each do |movie|
        movie.must_include "title"
        movie.must_include "release_date"
      end
    end

    it "returns all movies when no query params are given" do
      get movies_url
      assert_response :success

      data = JSON.parse @response.body
      data.length.must_equal Movie.count

      expected_names = {}
      Movie.all.each do |movie|
        expected_names[movie["title"]] = false
      end

      data.each do |movie|
        expected_names[movie["title"]].must_equal false, "Got back duplicate movie #{movie["title"]}"
        expected_names[movie["title"]] = true
      end
    end
  end

  describe "show" do
    it "Returns a JSON object" do
      get movie_url(title: movies(:one).title)
      assert_response :success
      @response.headers['Content-Type'].must_include 'json'

      # Attempt to parse
      data = JSON.parse @response.body
      data.must_be_kind_of Hash
    end

    it "Returns expected fields" do
      get movie_url(title: movies(:one).title)
      assert_response :success

      movie = JSON.parse @response.body
      movie.must_include "title"
      movie.must_include "overview"
      movie.must_include "release_date"
      movie.must_include "inventory"
      movie.must_include "available_inventory"
    end

    it "Returns an error when the movie doesn't exist" do
      get movie_url(title: "does_not_exist")
      assert_response :not_found

      data = JSON.parse @response.body
      data.must_include "errors"
      data["errors"].must_include "title"

    end
  end
end
