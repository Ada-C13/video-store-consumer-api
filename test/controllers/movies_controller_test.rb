require 'test_helper'
require 'pry'

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
    it "Returns a JSON object and 201 created status for new movies from external db with valid params" do
      new_movie_params = {
        title: "Our test movie",
        overview: "Awesome times ahead",
        release_date: Date.today,
        external_id: 38583,
        image_url: "test url string for url"
      }

      expect { post movies_url, params: new_movie_params }.must_differ "Movie.count", 1
      must_respond_with :created
      expect(response.header['Content-Type']).must_include 'json'
  
      # Attempt to parse
      data = JSON.parse response.body
      data.must_be_kind_of Hash
    end

   
    it "Returns a JSON object with errors and 400 bad request status if movie already exists" do
      duplicate_movie_params = {
        title: "WowMovie!",
        overview: "MyText",
        release_date: "2017-01-11",
        external_id: 16373
      }

      expect { post movies_url, params: duplicate_movie_params }.wont_change "Movie.count"
      must_respond_with :bad_request
      expect(response.header['Content-Type']).must_include 'json'
      expect(response.body).must_include "external_id"
      expect(response.body).must_include "has already been taken"
    end
  end
end
