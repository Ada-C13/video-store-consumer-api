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
        title: "XXXXX",
        overview: "XXXXXXXX",
        release_date: "2017-01-11",
        inventory: 10,
        image_url: "https://lh3.googleusercontent.com/pw/ACtC-3dgueD28nFt8fbmnEVSWrDdgXdH4dy91CXoWO818YTNFQlfnH-GN1O9t3zX4UEOGH3cncMC2Ze9WfNm13ofTlzOV97WdprqYmUPbj5H0oTS7Qwi8QtAEV8RFNyrcCJy09V04GFZQySqt9yhxf2v37Cg=w401-h397-no?authuser=0",
        external_id: 2342
      }
    end
    it "create a new movie instance/object" do 
      # post movies_path, params: @valid_movie

      
      expect{post movies_path, params: @valid_movie}.must_differ "Movie.count", 1
      must_respond_with :success

      last_movie = Movie.last
      expect(last_movie.title).must_equal "XXXXX"
      p last_movie
    end
  end
end
