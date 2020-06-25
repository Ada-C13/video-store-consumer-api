require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  def check_response(expected_type:, expected_status: :success)
    must_respond_with expected_status
    expect(response.header['Content-Type']).must_include 'json'

    body = JSON.parse(response.body)
    expect(body).must_be_kind_of expected_type
    return body
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

  describe "create" do 
    let (:valid_new_movie){
      {
        title: "A New Hope",
        overview: "cool movie",
        release_date: Date.today,
        image_url: "testurl.com",
        external_id: 1000
      }
    }

    let (:invalid_new_movie){
      {
        title: "VeryVideo",
        overview: "MyText",
        release_date: 2017-01-11,
        image_url: "testurl.com",
        external_id: 1001 # this makes this movie invalid b/c fixture already has a movie with this external id
      }
    }

    it "can create a valid movie and add it to this API's movie db" do 
      expect {
        post movies_path, params: valid_new_movie
      }.must_differ "Movie.count", 1

      check_response(expected_type: Hash, expected_status: :created)
    end 

    it "does not add the same movie twice to the db" do 
      expect {
        post movies_path, params: invalid_new_movie
      }.wont_change "Movie.count"
    end 

    it "it updates the inventory quantity of the movie if movie already exists" do 
      post movies_path, params: invalid_new_movie

      expect(movies(:three).inventory).must_equal 5
    end
  end 
end
