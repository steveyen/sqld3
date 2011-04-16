require 'rubygems'
require 'sinatra'
require 'erb'

class App < Sinatra::Base
  set :static, true
  set :public, 'public'

  ["/", "/index", "/index.html"].each do |path|
    get path do
      erb :index
    end
  end
end
