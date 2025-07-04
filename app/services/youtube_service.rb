class YoutubeService
  require 'google/apis/youtube_v3'
  
  def initialize
    @youtube = Google::Apis::YoutubeV3::YouTubeService.new
    @youtube.key = ENV['YOUTUBE_API_KEY'] || 'demo_key'
  end

  def search_videos(query, max_results: 5)
    search_videos_with_cycle(query, cycle: 1, max_results: max_results)
  end

  def search_videos_with_cycle(query, cycle: 1, max_results: 5)
    # Use real YouTube API if key is available
    if @youtube.key && @youtube.key != 'demo_key'
      begin
        Rails.logger.info "Searching YouTube for: #{query} (Cycle: #{cycle})"
        
        # Get more results to enable cycling through different sets
        total_results = max_results * 10 # Get 50 results total for 5 cycles of 5 videos each
        
        search_response = @youtube.list_searches(
          'snippet',
          q: query,
          type: 'video',
          max_results: total_results,
          order: 'relevance',
          safe_search: 'moderate',
          video_duration: 'medium'
        )
        
        all_videos = search_response.items.map do |item|
          {
            id: item.id.video_id,
            title: item.snippet.title,
            description: item.snippet.description || 'No description available',
            thumbnail: item.snippet.thumbnails&.medium&.url || item.snippet.thumbnails&.default&.url,
            channel: item.snippet.channel_title,
            published_at: item.snippet.published_at
          }
        end
        
        # Create deterministic but different results for each cycle
        # Use query and cycle as seed for consistent randomization
        seed = "#{query}_#{cycle}".hash.abs
        random_generator = Random.new(seed)
        
        # Shuffle with the seeded random generator
        shuffled_videos = all_videos.shuffle(random: random_generator)
        
        # Get the specific slice for this cycle
        start_index = (cycle - 1) * max_results
        end_index = start_index + max_results - 1
        
        cycle_videos = shuffled_videos[start_index..end_index] || []
        
        # If we don't have enough videos, fill with random selection
        if cycle_videos.length < max_results && all_videos.length > 0
          remaining_needed = max_results - cycle_videos.length
          available_videos = all_videos - cycle_videos
          additional_videos = available_videos.shuffle(random: random_generator).first(remaining_needed)
          cycle_videos += additional_videos if additional_videos
        end
        
        Rails.logger.info "Found #{cycle_videos.length} videos for query: #{query}, cycle: #{cycle}"
        
        return cycle_videos.first(max_results)
        
      rescue Google::Apis::Error => e
        Rails.logger.error "YouTube API Error: #{e.message}"
        Rails.logger.error "Error details: #{e.body}" if e.respond_to?(:body)
        # Fall back to mock data on API error
        return mock_videos_with_cycle(query, cycle: cycle)
      rescue => e
        Rails.logger.error "Unexpected error: #{e.message}"
        return mock_videos_with_cycle(query, cycle: cycle)
      end
    else
      Rails.logger.info "Using mock data - API key not configured"
      return mock_videos_with_cycle(query, cycle: cycle)
    end
  end

  private

  def mock_videos(query)
    mock_videos_with_cycle(query, cycle: 1)
  end

  def mock_videos_with_cycle(query, cycle: 1)
    # Extended mock data for cycling through different sets
    all_health_videos = [
      # Cycle 1 - Yoga Focus
      {
        id: 'X655B4ISakg',
        title: '10 Minute Morning Yoga - Energizing Flow',
        description: 'Start your day with this energizing yoga routine perfect for beginners. This gentle flow will wake up your body and mind.',
        thumbnail: 'https://i.ytimg.com/vi/X655B4ISakg/mqdefault.jpg',
        channel: 'Yoga with Adriene',
        published_at: '2023-01-15T08:00:00Z'
      },
      {
        id: 'inpok4MKVLM',
        title: 'Guided Meditation for Stress Relief - 15 Minutes',
        description: 'Guided meditation to help reduce stress and improve mental clarity. Perfect for daily practice.',
        thumbnail: 'https://i.ytimg.com/vi/inpok4MKVLM/mqdefault.jpg',
        channel: 'The Mindful Movement',
        published_at: '2023-01-10T18:45:00Z'
      },
      {
        id: 'sTANio_2E0Q',
        title: 'Full Body Stretch - 20 Minutes',
        description: 'Relieve tension and improve flexibility with this comprehensive stretching routine.',
        thumbnail: 'https://i.ytimg.com/vi/sTANio_2E0Q/mqdefault.jpg',
        channel: 'Yoga with Kassandra',
        published_at: '2023-01-28T16:30:00Z'
      },
      {
        id: 'M-8FvC3GD8s',
        title: 'Pilates Core Workout - 15 Minutes',
        description: 'Strengthen your core with this effective pilates routine. Great for posture and stability.',
        thumbnail: 'https://i.ytimg.com/vi/M-8FvC3GD8s/mqdefault.jpg',
        channel: 'MadFit',
        published_at: '2023-02-12T09:00:00Z'
      },
      {
        id: 'aHR-7kV4dhA',
        title: 'Sleep Better Tonight - Relaxation Techniques',
        description: 'Improve your sleep quality with these proven relaxation techniques and bedtime routines.',
        thumbnail: 'https://i.ytimg.com/vi/aHR-7kV4dhA/mqdefault.jpg',
        channel: 'The Sleep Doctor',
        published_at: '2023-02-10T20:00:00Z'
      },
      
      # Cycle 2 - HIIT & Cardio Focus
      {
        id: 'ml6cT4AZdqI',
        title: 'HIIT Cardio Workout - 20 Minutes Fat Burn',
        description: 'High-intensity interval training perfect for burning calories at home. No equipment needed!',
        thumbnail: 'https://i.ytimg.com/vi/ml6cT4AZdqI/mqdefault.jpg',
        channel: 'FitnessBlender',
        published_at: '2023-01-20T14:15:00Z'
      },
      {
        id: 'RqcOCBb4arc',
        title: 'Dance Workout - Fun Cardio Session',
        description: 'Get your heart pumping with this fun dance cardio workout. No dance experience required!',
        thumbnail: 'https://i.ytimg.com/vi/RqcOCBb4arc/mqdefault.jpg',
        channel: 'emkfit',
        published_at: '2023-02-15T14:00:00Z'
      },
      {
        id: 'YQampHWCeao',
        title: 'Full Body Strength Training - 30 Minutes',
        description: 'Build muscle and strength with this comprehensive workout routine. Perfect for all fitness levels.',
        thumbnail: 'https://i.ytimg.com/vi/YQampHWCeao/mqdefault.jpg',
        channel: 'Calisthenic Movement',
        published_at: '2023-01-30T11:30:00Z'
      },
      {
        id: 'ABC1234567',
        title: 'Tabata Training - 4 Minute Intense Workout',
        description: 'Maximum results in minimum time with this high-intensity Tabata training session.',
        thumbnail: 'https://i.ytimg.com/vi/ABC1234567/mqdefault.jpg',
        channel: 'HIIT Workouts',
        published_at: '2023-03-01T15:00:00Z'
      },
      {
        id: 'DEF2345678',
        title: 'Jumping Jacks Challenge - 10 Minutes',
        description: 'Simple but effective cardio workout using just jumping jacks. Great for beginners!',
        thumbnail: 'https://i.ytimg.com/vi/DEF2345678/mqdefault.jpg',
        channel: 'Cardio Masters',
        published_at: '2023-03-05T11:30:00Z'
      },
      
      # Cycle 3 - Nutrition Focus
      {
        id: 'UEx3iGVhHPA',
        title: 'Healthy Meal Prep - 5 Easy Recipes',
        description: 'Prepare a week\'s worth of healthy meals in just 1 hour. Budget-friendly and nutritious recipes.',
        thumbnail: 'https://i.ytimg.com/vi/UEx3iGVhHPA/mqdefault.jpg',
        channel: 'Pick Up Limes',
        published_at: '2023-02-05T12:00:00Z'
      },
      {
        id: 'gC_L9qAHVJ8',
        title: 'Understanding Macronutrients - Complete Guide',
        description: 'Learn about proteins, carbs, and fats. Essential knowledge for a healthy diet.',
        thumbnail: 'https://i.ytimg.com/vi/gC_L9qAHVJ8/mqdefault.jpg',
        channel: 'Abbey Sharp',
        published_at: '2023-01-18T12:00:00Z'
      },
      {
        id: 'GHI3456789',
        title: 'Green Smoothie Recipes - 10 Healthy Options',
        description: 'Delicious and nutritious green smoothie recipes to boost your energy and health.',
        thumbnail: 'https://i.ytimg.com/vi/GHI3456789/mqdefault.jpg',
        channel: 'Healthy Kitchen',
        published_at: '2023-03-10T09:15:00Z'
      },
      {
        id: 'JKL4567890',
        title: 'Intermittent Fasting for Beginners',
        description: 'Everything you need to know about intermittent fasting and how to get started safely.',
        thumbnail: 'https://i.ytimg.com/vi/JKL4567890/mqdefault.jpg',
        channel: 'Nutrition Science',
        published_at: '2023-03-15T14:20:00Z'
      },
      {
        id: 'MNO5678901',
        title: 'Hydration Tips - How Much Water Do You Need?',
        description: 'Learn the science behind proper hydration and calculate your daily water needs.',
        thumbnail: 'https://i.ytimg.com/vi/MNO5678901/mqdefault.jpg',
        channel: 'Health Facts',
        published_at: '2023-03-20T16:45:00Z'
      },
      
      # Cycle 4 - Strength & Weight Training
      {
        id: 'PQR6789012',
        title: 'Beginner Weight Training - Full Body',
        description: 'Complete weight training guide for beginners. Learn proper form and basic exercises.',
        thumbnail: 'https://i.ytimg.com/vi/PQR6789012/mqdefault.jpg',
        channel: 'Strength Training 101',
        published_at: '2023-04-01T10:00:00Z'
      },
      {
        id: 'STU7890123',
        title: 'Bodyweight Exercises - No Equipment Needed',
        description: 'Effective bodyweight exercises you can do anywhere. Perfect for home workouts.',
        thumbnail: 'https://i.ytimg.com/vi/STU7890123/mqdefault.jpg',
        channel: 'Home Fitness Pro',
        published_at: '2023-04-05T13:30:00Z'
      },
      {
        id: 'VWX8901234',
        title: 'Push-Up Variations - 10 Different Types',
        description: 'Master different push-up variations to target various muscle groups effectively.',
        thumbnail: 'https://i.ytimg.com/vi/VWX8901234/mqdefault.jpg',
        channel: 'Calisthenics King',
        published_at: '2023-04-10T15:45:00Z'
      },
      {
        id: 'YZA9012345',
        title: 'Squat Challenge - 30 Days to Stronger Legs',
        description: 'Transform your lower body with this comprehensive 30-day squat challenge.',
        thumbnail: 'https://i.ytimg.com/vi/YZA9012345/mqdefault.jpg',
        channel: 'Leg Day Every Day',
        published_at: '2023-04-15T11:20:00Z'
      },
      {
        id: 'BCD0123456',
        title: 'Core Strengthening - 6 Pack Abs Workout',
        description: 'Intensive core workout to build strong abs and improve overall stability.',
        thumbnail: 'https://i.ytimg.com/vi/BCD0123456/mqdefault.jpg',
        channel: 'Ab Workout Central',
        published_at: '2023-04-20T17:10:00Z'
      },
      
      # Cycle 5 - Mental Health & Recovery
      {
        id: 'EFG1234567',
        title: 'Mental Health and Exercise Connection',
        description: 'Discover how regular exercise can improve your mental health and overall well-being.',
        thumbnail: 'https://i.ytimg.com/vi/EFG1234567/mqdefault.jpg',
        channel: 'Mind Body Connection',
        published_at: '2023-05-01T12:30:00Z'
      },
      {
        id: 'HIJ2345678',
        title: 'Recovery Techniques - Post Workout Care',
        description: 'Essential recovery techniques to prevent injury and improve workout performance.',
        thumbnail: 'https://i.ytimg.com/vi/HIJ2345678/mqdefault.jpg',
        channel: 'Recovery Science',
        published_at: '2023-05-05T14:15:00Z'
      },
      {
        id: 'KLM3456789',
        title: 'Breathing Exercises for Stress Relief',
        description: 'Simple breathing techniques to reduce stress and improve focus throughout your day.',
        thumbnail: 'https://i.ytimg.com/vi/KLM3456789/mqdefault.jpg',
        channel: 'Breathwork Academy',
        published_at: '2023-05-10T08:45:00Z'
      },
      {
        id: 'NOP4567890',
        title: 'Foam Rolling Guide - Self Massage Techniques',
        description: 'Learn proper foam rolling techniques to improve mobility and reduce muscle tension.',
        thumbnail: 'https://i.ytimg.com/vi/NOP4567890/mqdefault.jpg',
        channel: 'Mobility Masters',
        published_at: '2023-05-15T16:20:00Z'
      },
      {
        id: 'QRS5678901',
        title: 'Sleep Optimization for Athletes',
        description: 'Maximize your recovery and performance with these science-backed sleep strategies.',
        thumbnail: 'https://i.ytimg.com/vi/QRS5678901/mqdefault.jpg',
        channel: 'Sleep Performance',
        published_at: '2023-05-20T19:30:00Z'
      }
    ]
    
    # Filter videos based on query
    filtered_videos = if query.present?
      all_health_videos.select { |video| 
        video[:title].downcase.include?(query.downcase) ||
        video[:description].downcase.include?(query.downcase)
      }
    else
      all_health_videos
    end
    
    # Use the same deterministic randomization as the real API
    result_videos = filtered_videos.any? ? filtered_videos : all_health_videos
    
    # Create deterministic but different results for each cycle
    seed = "#{query}_#{cycle}".hash.abs
    random_generator = Random.new(seed)
    
    # Shuffle with the seeded random generator and take 5 videos
    shuffled_videos = result_videos.shuffle(random: random_generator)
    shuffled_videos.first(5)
  end
end