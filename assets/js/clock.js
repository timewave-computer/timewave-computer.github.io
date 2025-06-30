// Analog Clock Functionality
function updateClock() {
  const now = new Date();
  const hours = now.getHours() % 12;
  const minutes = now.getMinutes();
  const seconds = now.getSeconds();
  
  // Calculate angles (360 degrees = full circle)
  const hourAngle = (hours * 30) + (minutes * 0.5); // 30 degrees per hour + minute adjustment
  const minuteAngle = minutes * 6; // 6 degrees per minute
  const secondAngle = seconds * 6; // 6 degrees per second
  
  const applyRotations = (prefix = '') => {
    const hourHand = document.querySelector(`.${prefix}hour-hand`);
    const minuteHand = document.querySelector(`.${prefix}minute-hand`);
    const secondHand = document.querySelector(`.${prefix}second-hand`);
    
    if (hourHand && minuteHand && secondHand) {
      hourHand.style.transform = `rotate(${hourAngle}deg)`;
      minuteHand.style.transform = `rotate(${minuteAngle}deg)`;
      secondHand.style.transform = `rotate(${secondAngle}deg)`;
    }
  };

  applyRotations(); // Main clock
  applyRotations('mini-'); // Mini clock
}

// Initialize clock functionality
function initializeClock() {
  // Update clock immediately and then every second
  updateClock();
  setInterval(updateClock, 1000);
}

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeClock);
} else {
  initializeClock();
} 