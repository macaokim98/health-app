const puppeteer = require('puppeteer');

async function debugHealthApp() {
  let browser;
  try {
    console.log('🚀 Starting browser debug session...');
    
    browser = await puppeteer.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
    });

    const page = await browser.newPage();
    
    // Capture console logs
    const consoleLogs = [];
    page.on('console', msg => {
      consoleLogs.push({
        type: msg.type(),
        text: msg.text(),
        timestamp: new Date().toISOString()
      });
    });

    // Capture network errors
    const networkErrors = [];
    page.on('requestfailed', request => {
      networkErrors.push({
        url: request.url(),
        error: request.failure()?.errorText,
        timestamp: new Date().toISOString()
      });
    });

    // Capture JavaScript errors
    const jsErrors = [];
    page.on('pageerror', error => {
      jsErrors.push({
        message: error.message,
        stack: error.stack,
        timestamp: new Date().toISOString()
      });
    });

    console.log('📍 Testing homepage...');
    await page.goto('http://localhost:3000', { waitUntil: 'networkidle2', timeout: 10000 });
    
    // Wait a bit for any async operations
    await new Promise(resolve => setTimeout(resolve, 2000));

    console.log('📍 Testing videos page...');
    await page.goto('http://localhost:3000/videos', { waitUntil: 'networkidle2', timeout: 10000 });
    
    // Wait for videos to load
    await new Promise(resolve => setTimeout(resolve, 3000));

    // Check if video cards are present
    const videoCards = await page.$$('.video-card');
    console.log(`📊 Found ${videoCards.length} video cards`);

    // Try clicking on theme toggle
    console.log('📍 Testing theme toggle...');
    const themeToggle = await page.$('.theme-toggle');
    if (themeToggle) {
      await themeToggle.click();
      await new Promise(resolve => setTimeout(resolve, 1000));
      console.log('✅ Theme toggle clicked');
    } else {
      console.log('❌ Theme toggle not found');
    }

    // Try clicking on first video card
    if (videoCards.length > 0) {
      console.log('📍 Testing video card click...');
      await videoCards[0].click();
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // Check if modal opened
      const modal = await page.$('#videoModal');
      const modalVisible = await page.evaluate(el => {
        const style = window.getComputedStyle(el);
        return style.display !== 'none';
      }, modal);
      
      console.log(`📊 Video modal visible: ${modalVisible}`);
    }

    // Generate report
    const report = {
      timestamp: new Date().toISOString(),
      homepage: {
        loaded: true,
        videoCardsFound: videoCards.length
      },
      consoleLogs,
      networkErrors,
      jsErrors,
      summary: {
        totalConsoleMessages: consoleLogs.length,
        totalNetworkErrors: networkErrors.length,
        totalJsErrors: jsErrors.length
      }
    };

    console.log('\n📋 DEBUG REPORT:');
    console.log('================');
    console.log(`Video Cards Found: ${report.homepage.videoCardsFound}`);
    console.log(`Console Messages: ${report.summary.totalConsoleMessages}`);
    console.log(`Network Errors: ${report.summary.totalNetworkErrors}`);
    console.log(`JavaScript Errors: ${report.summary.totalJsErrors}`);

    if (consoleLogs.length > 0) {
      console.log('\n📝 Console Logs:');
      consoleLogs.forEach(log => {
        console.log(`[${log.type.toUpperCase()}] ${log.text}`);
      });
    }

    if (networkErrors.length > 0) {
      console.log('\n🌐 Network Errors:');
      networkErrors.forEach(error => {
        console.log(`❌ ${error.url}: ${error.error}`);
      });
    }

    if (jsErrors.length > 0) {
      console.log('\n🐛 JavaScript Errors:');
      jsErrors.forEach(error => {
        console.log(`❌ ${error.message}`);
        if (error.stack) {
          console.log(`   Stack: ${error.stack.split('\n')[0]}`);
        }
      });
    }

    return report;

  } catch (error) {
    console.error('❌ Browser debug failed:', error.message);
    return { error: error.message };
  } finally {
    if (browser) {
      await browser.close();
    }
  }
}

// Run if called directly
if (require.main === module) {
  debugHealthApp().then(report => {
    if (report.error) {
      process.exit(1);
    } else {
      console.log('\n✅ Debug session completed');
      process.exit(0);
    }
  });
}

module.exports = debugHealthApp;