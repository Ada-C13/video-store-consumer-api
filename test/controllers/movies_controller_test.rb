require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
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

  describe "create" do
    before do
      @movie_hash = {
        title: "xxxxxx", 
        overview: "xxxxxxx",
        release_date: "2017-01-11",
        inventory: 23,
        image_url: "hshsioadhisod",
        external_id: 2389,
      }
      @invalid_movie_hash = {
        title: nil, 
        overview: "xxxxxxx",
        release_date: "2017-01-11",
        inventory: 23,
        image_url: "hshsioadhisod",
        external_id: 2389,
      }
    end
   
    it "can create a new movie with valid information accurately " do
      expect { 
        post movies_path, params: @movie_hash
      }.must_differ "Movie.count", 1

      
      expect(Movie.last.title).must_equal @movie_hash[:title]
      expect(Movie.last.overview).must_equal @movie_hash[:overview]
 
      must_respond_with :success
    end

    it "can create a new movie with invalid information accurately " do

      expect{
        post movies_path, params: @invalid_movie_hash
      }.wont_change "Movie.count"

      must_respond_with :bad_request
      data = JSON.parse @response.body
      data.must_include "errors"

    end

    it "does not create a movie if title is not present, and responds with a redirect" do
      post movies_path(@invalid_movie_hash)
      
      must_respond_with :bad_request
      data = JSON.parse @response.body
      data.must_include "errors"
      data["errors"].must_include "title"
    end
  end
end
