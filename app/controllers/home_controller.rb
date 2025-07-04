class HomeController < ApplicationController
  def index
    # Health dashboard home page
    @current_date = Date.current
    @app_title = "Health Tracker"
  end
end
