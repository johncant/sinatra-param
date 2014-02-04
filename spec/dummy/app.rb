require 'sinatra/base'
require 'sinatra/param'
require 'json'
require 'time'

class App < Sinatra::Base
  helpers Sinatra::Param

  before do
    content_type :json
  end

  get '/' do
    begin
      param :a, String
      param :b, String, required: true
      param :c, String, default: 'test'
      param :d, String
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end
    params.to_json
  end

  get '/keys/stringify' do
    begin
      param :q, String, transform: :upcase
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params['q']
  end

  get '/coerce/string' do
    params['arg'] = params['arg'].to_i
    begin
      param :arg, String
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/coerce/integer' do
    begin
      param :arg, Integer
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/coerce/float' do
    begin
      param :arg, Float
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/coerce/time' do
    begin
      param :arg, Time
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/coerce/date' do
    begin
      param :arg, Date
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/coerce/datetime' do
    begin
      param :arg, DateTime
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/coerce/array' do
    begin
      param :arg, Array
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/coerce/hash' do
    begin
      param :arg, Hash
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/coerce/boolean' do
    begin
      param :arg, Boolean
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/default' do
    begin
      param :sort, String, default: "title"
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/default/boolean/true' do
    begin
      param :arg, Boolean, default: true
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/default/boolean/false' do
    begin
      param :arg, Boolean, default: false
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/transform' do
    begin
      param :order, String, transform: :upcase
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/validation/required' do
    begin
      param :arg, String, required: true
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/validation/blank/string' do
    begin
      param :arg, String, blank: false
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

  end

  get '/validation/blank/array' do
    begin
      param :arg, Array, blank: false
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

  end

  get '/validation/blank/hash' do
    begin
      param :arg, Hash, blank: false
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

  end

  get '/validation/blank/other' do
    begin
      param :arg, Class, blank: false
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

  end

  get '/validation/nonblank/string' do
    begin
      param :arg, String, blank: true
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

  end

  get '/validation/is' do
    begin
      param :arg, String, is: 'foo'
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/validation/in' do
    begin
      param :arg, String, in: ['ASC', 'DESC']
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/validation/within' do
    begin
      param :arg, Integer, within: 1..10
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/validation/range' do
    begin
      param :arg, Integer, range: 1..10
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/validation/min' do
    begin
      param :arg, Integer, min: 12
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/validation/max' do
    begin
      param :arg, Integer, max: 20
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/validation/min_length' do
    begin
      param :arg, String, min_length: 5
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/validation/max_length' do
    begin
      param :arg, String, max_length: 10
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    params.to_json
  end

  get '/choice' do
    begin
      param :a, String
      param :b, String
      param :c, String

      one_of(:a, :b, :c)
    rescue InvalidParameterError => e
      halt(400, {:message => e.message}.to_json)
    end

    {
      message: 'OK'
    }.to_json
  end
end

#App.run!(:port => 6555)
