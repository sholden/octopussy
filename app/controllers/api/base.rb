module Api
  class Base < ApplicationController
    skip_before_filter :verify_authenticity_token
  end
end