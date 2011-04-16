require 'app'

use Rack::ShowExceptions

run App.new
