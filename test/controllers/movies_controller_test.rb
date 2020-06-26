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
      @valid_movie = {
        title: "something",
        overview: "something",
        release_date: "01-01-2020",
        inventory: 5,
        image_url: "https://designerdoginfo.files.wordpress.com/2012/10/apricot-cavoodle-puppy-on-blue-blanket.jpg",
        external_id: 6
      }
      @invalid_movie = {
        inventory: 5,
      }
    end
    

    

    it "can create a new movie with valid data" do
      expect { post movies_path, params: @valid_movie }.must_differ "Movie.count", 1
    end
    
    it "responds with bad request and errors for invalid data" do
      expect { post movies_path, params: @invalid_movie }.wont_change "Movie.count"
      
      body = check_response(expected_type: Hash, expected_status: :bad_request)
      expect(body.keys).must_include "errors"
      expect(body["errors"].keys).must_include "title"
      expect(body["errors"].keys).must_include "overview"
      expect(body["errors"].keys).must_include "release_date"
      expect(body["errors"].keys).must_include "external_id"
    end

  end
end
