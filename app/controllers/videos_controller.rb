class VideosController < ApplicationController
  def index
    require_relative '../services/youtube_service'
    @youtube_service = YoutubeService.new
    @videos = @youtube_service.search_videos('health fitness workout yoga exercise', max_results: 5)
    @search_query = 'health fitness workout yoga exercise'
    @cycle_count = 1
    @max_cycles = 5
    Rails.logger.info "VideosController#index - Found #{@videos.length} videos"
  end

  def search
    require_relative '../services/youtube_service'
    @youtube_service = YoutubeService.new
    query = params[:q] || 'health'
    cycle = (params[:cycle] || 1).to_i
    
    # Reset cycle if it exceeds max cycles
    cycle = 1 if cycle > 5
    
    @videos = @youtube_service.search_videos_with_cycle(query, cycle: cycle, max_results: 5)
    @search_query = query
    @cycle_count = cycle
    @max_cycles = 5
    
    Rails.logger.info "VideosController#search - Query: #{query}, Cycle: #{cycle}, Found #{@videos.length} videos"
    
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @videos }
    end
  end

  def refresh
    require_relative '../services/youtube_service'
    @youtube_service = YoutubeService.new
    query = params[:q] || 'health'
    current_cycle = (params[:cycle] || 1).to_i
    next_cycle = current_cycle >= 5 ? 1 : current_cycle + 1
    
    @videos = @youtube_service.search_videos_with_cycle(query, cycle: next_cycle, max_results: 5)
    @search_query = query
    @cycle_count = next_cycle
    @max_cycles = 5
    
    Rails.logger.info "VideosController#refresh - Query: #{query}, Next Cycle: #{next_cycle}, Found #{@videos.length} videos"
    
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @videos }
    end
  end
end
