// YouTube Video Modal and Streaming Functionality

let player;
let isPlayerReady = false;

// Initialize video functionality when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  initializeVideoHandlers();
  loadYouTubeAPI();
});

function initializeVideoHandlers() {
  // Add click handlers to video cards
  const videoCards = document.querySelectorAll('.video-card');
  videoCards.forEach(card => {
    card.addEventListener('click', function() {
      const videoId = this.getAttribute('data-video-id');
      const videoTitle = this.querySelector('.video-title').textContent;
      openVideoModal(videoId, videoTitle);
    });
  });

  // Add click handler to modal close button
  const modal = document.getElementById('videoModal');
  if (modal) {
    modal.addEventListener('click', function(e) {
      if (e.target === modal || e.target.classList.contains('modal-close')) {
        closeVideoModal();
      }
    });
  }

  // Close modal with Escape key
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
      closeVideoModal();
    }
  });
}

function loadYouTubeAPI() {
  // Load YouTube IFrame Player API
  if (!window.YT) {
    const tag = document.createElement('script');
    tag.src = 'https://www.youtube.com/iframe_api';
    const firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  }
}

// YouTube API ready callback
window.onYouTubeIframeAPIReady = function() {
  isPlayerReady = true;
};

function openVideoModal(videoId, title) {
  const modal = document.getElementById('videoModal');
  const modalTitle = document.getElementById('modalTitle');
  const videoPlayer = document.getElementById('videoPlayer');
  
  if (!modal || !modalTitle || !videoPlayer) return;
  
  // Set modal title
  modalTitle.textContent = title;
  
  // Show modal
  modal.style.display = 'block';
  document.body.style.overflow = 'hidden';
  
  // Add modal open animation
  modal.style.opacity = '0';
  setTimeout(() => {
    modal.style.opacity = '1';
  }, 10);
  
  // Create YouTube player
  if (isPlayerReady && window.YT && window.YT.Player) {
    createYouTubePlayer(videoId);
  } else {
    // Fallback to iframe embed
    createFallbackPlayer(videoId);
  }
}

function createYouTubePlayer(videoId) {
  const videoPlayer = document.getElementById('videoPlayer');
  
  // Clear previous content
  videoPlayer.innerHTML = '';
  
  // Create YouTube player
  player = new YT.Player('videoPlayer', {
    height: '450',
    width: '100%',
    videoId: videoId,
    playerVars: {
      autoplay: 1,
      controls: 1,
      modestbranding: 1,
      rel: 0,
      showinfo: 0,
      fs: 1,
      playsinline: 1
    },
    events: {
      onReady: function(event) {
        event.target.playVideo();
      },
      onStateChange: function(event) {
        // Handle player state changes if needed
      }
    }
  });
}

function createFallbackPlayer(videoId) {
  const videoPlayer = document.getElementById('videoPlayer');
  
  videoPlayer.innerHTML = `
    <iframe
      width="100%"
      height="450"
      src="https://www.youtube.com/embed/${videoId}?autoplay=1&controls=1&modestbranding=1&rel=0&showinfo=0&fs=1&playsinline=1"
      frameborder="0"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
      allowfullscreen>
    </iframe>
  `;
}

window.closeVideoModal = function() {
  const modal = document.getElementById('videoModal');
  const videoPlayer = document.getElementById('videoPlayer');
  
  if (!modal) return;
  
  // Add modal close animation
  modal.style.opacity = '0';
  
  setTimeout(() => {
    modal.style.display = 'none';
    document.body.style.overflow = '';
    
    // Stop video playback
    if (player && player.stopVideo) {
      player.stopVideo();
      player.destroy();
      player = null;
    }
    
    // Clear player content
    if (videoPlayer) {
      videoPlayer.innerHTML = '';
    }
  }, 300);
};

// Search functionality
function handleSearch(event) {
  event.preventDefault();
  const form = event.target;
  const formData = new FormData(form);
  const query = formData.get('q');
  
  if (query.trim()) {
    // Show loading state
    showSearchLoading();
    
    // Redirect to search with query
    window.location.href = `/videos/search?q=${encodeURIComponent(query)}`;
  }
}

function showSearchLoading() {
  const searchBtn = document.querySelector('.search-btn');
  if (searchBtn) {
    const originalContent = searchBtn.innerHTML;
    searchBtn.innerHTML = '<span style="animation: spin 1s linear infinite;">⟳</span>';
    searchBtn.disabled = true;
    
    // Reset after 3 seconds (fallback)
    setTimeout(() => {
      searchBtn.innerHTML = originalContent;
      searchBtn.disabled = false;
    }, 3000);
  }
}

// Add search form handler
document.addEventListener('DOMContentLoaded', function() {
  const searchForm = document.querySelector('.search-form');
  if (searchForm) {
    searchForm.addEventListener('submit', handleSearch);
  }
});

// Add CSS for search loading animation
const style = document.createElement('style');
style.textContent = `
  @keyframes spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }
`;
document.head.appendChild(style);

// Mobile touch optimization
function addTouchOptimization() {
  const videoCards = document.querySelectorAll('.video-card');
  
  videoCards.forEach(card => {
    // Add touch feedback
    card.addEventListener('touchstart', function() {
      this.style.transform = 'scale(0.98)';
    });
    
    card.addEventListener('touchend', function() {
      this.style.transform = '';
    });
    
    card.addEventListener('touchcancel', function() {
      this.style.transform = '';
    });
  });
}

// Initialize touch optimization on mobile
if ('ontouchstart' in window) {
  document.addEventListener('DOMContentLoaded', addTouchOptimization);
}

// Progressive Web App features
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function() {
    navigator.serviceWorker.register('/service-worker.js')
      .then(function(registration) {
        console.log('SW registered: ', registration);
      })
      .catch(function(registrationError) {
        console.log('SW registration failed: ', registrationError);
      });
  });
}