require 'test_helper'

class MoviesControllerTest < ActionDispatch::IntegrationTest
  def check_response(expected_type: ,expected_status: :success)
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

  describe 'create' do 
    let(:movies_data) {
      {

          title: 'Harry Potter 3',
          overview: 'The best movie ever!',
          release_date: 'Wed, 22 Jun 1960',
          inventory: 10,
          image_url: "some image",
          external_id: 1547,
      }
    }

    it 'can create a new movies' do 
      expect {
        post movies_path, params: movies_data
      }.must_differ 'Movie.count', 1

      check_response(expected_type: Hash, expected_status: :ok)
    end

    it 'will respond with bad_request for invalid data' do
      movies_data[:external_id] = nil

      expect {
        post movies_path, params: movies_data
      }.wont_change "Movie.count"
      body = check_response(expected_type: Hash, expected_status: :bad_request)
      expect(body["errors"].keys).must_include 'external_id'
    end

    it 'cannot be added twice for the same movie' do
      first_count = Movie.count

      expect {
        post movies_path, params: movies_data
      }.must_differ 'Movie.count', 1

      second_count = Movie.count 

      expect {
        post movies_path, params: movies_data
      }.wont_change 'Movie.count'

    end
  end

end
