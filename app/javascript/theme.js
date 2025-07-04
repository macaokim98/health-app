// Dark/Light Theme Toggle Functionality

// Initialize theme on page load
document.addEventListener('DOMContentLoaded', function() {
  initializeTheme();
});

function initializeTheme() {
  const savedTheme = localStorage.getItem('theme') || 'light';
  const html = document.documentElement;
  const themeIcon = document.getElementById('themeIcon');
  
  if (savedTheme === 'dark') {
    html.setAttribute('data-theme', 'dark');
    if (themeIcon) themeIcon.textContent = '☀️';
  } else {
    html.setAttribute('data-theme', 'light');
    if (themeIcon) themeIcon.textContent = '🌙';
  }
}

// Toggle theme function (called from HTML)
window.toggleTheme = function() {
  const html = document.documentElement;
  const themeIcon = document.getElementById('themeIcon');
  const currentTheme = html.getAttribute('data-theme');
  
  if (currentTheme === 'dark') {
    html.setAttribute('data-theme', 'light');
    localStorage.setItem('theme', 'light');
    if (themeIcon) themeIcon.textContent = '🌙';
  } else {
    html.setAttribute('data-theme', 'dark');
    localStorage.setItem('theme', 'dark');
    if (themeIcon) themeIcon.textContent = '☀️';
  }
  
  // Add transition class for smooth theme change
  document.body.style.transition = 'background-color 0.3s ease, color 0.3s ease';
  setTimeout(() => {
    document.body.style.transition = '';
  }, 300);
};

// Auto-detect system theme preference
function detectSystemTheme() {
  if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
    return 'dark';
  }
  return 'light';
}

// Listen for system theme changes
if (window.matchMedia) {
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function(e) {
    if (!localStorage.getItem('theme')) {
      initializeTheme();
    }
  });
}