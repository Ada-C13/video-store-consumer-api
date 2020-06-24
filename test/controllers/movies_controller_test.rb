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
    it "add a movie to the db" do
      movie_hash = {
        title: "Cinderella",
        overview: "Cinderella has faith her dreams of a better life will come true. With help from her loyal mice friends and a wave of her Fairy Godmother's wand, Cinderella's rags are magically turned into a glorious gown and off she goes to the Royal Ball. But when the clock strikes midnight, the spell is broken, leaving a single glass slipper... the only key to the ultimate fairy-tale ending!",
        release_date: "1997-11-02",
        image_url: "https://image.tmdb.org/t/p/w185/wkeOjIcpuqLMW4GnVowlM9VI0JE.jpg",
        external_id: -1
      }

      expect{post movies_path, params: movie_hash}.must_change "Movie.count", 1
      
      new_movie = Movie.find_by(external_id: -1)
      expect(new_movie.title).must_equal "Cinderella"
    
      must_respond_with :created
    end

    it "won't add a movie if the data is invalid" do
      movie_hash = {}
      expect{post movies_path, params: movie_hash}.wont_change "Movie.count", 1
      must_respond_with :bad_request

      data = JSON.parse response.body
      expect(data["errors"].keys).must_include "external_id"
    end

    it "won't add a movie to the db if it is already there" do
      existing_movie = movies(:one)
      existing_movie_title = existing_movie.title
      existing_movie_release_date = existing_movie.release_date
      existing_movie_ext_id = existing_movie.external_id

      movie_hash = {
        title: existing_movie_title,
        release_date: existing_movie_release_date,
        external_id: existing_movie_ext_id
      }

      expect{post movies_path, params: movie_hash}.wont_change "Movie.count", 1
      must_respond_with :bad_request

      data = JSON.parse response.body
      expect(data["errors"].keys).must_include "external_id"
    end
  end
end
