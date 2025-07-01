// Xanadu pane drag functionality
// Allows users to drag panes by clicking and dragging the window header

(function() {
  let isDragging = false;
  let currentPane = null;
  let startX = 0;
  let startY = 0;
  let startLeft = 0;
  let startTop = 0;

  function initializeDragging() {
    const panes = document.querySelectorAll('.xanadu-pane');
    
    panes.forEach(pane => {
      const header = pane.querySelector('.window-header');
      if (!header) return;

      // Make header cursor indicate it's draggable
      header.style.cursor = 'move';
      
      header.addEventListener('mousedown', startDrag);
    });

    // Global mouse events
    document.addEventListener('mousemove', drag);
    document.addEventListener('mouseup', stopDrag);
  }

  function startDrag(e) {
    e.preventDefault();
    
    currentPane = e.target.closest('.xanadu-pane');
    if (!currentPane) return;

    isDragging = true;
    
    // Record starting positions
    startX = e.clientX;
    startY = e.clientY;
    
    // Get current position of the pane
    const rect = currentPane.getBoundingClientRect();
    startLeft = rect.left;
    startTop = rect.top;
    
    // Bring pane to front
    currentPane.style.zIndex = '1000';
    
    // Add dragging class for visual feedback
    currentPane.classList.add('dragging');
    
    // Disable text selection while dragging
    document.body.style.userSelect = 'none';
  }

  function drag(e) {
    if (!isDragging || !currentPane) return;
    
    e.preventDefault();
    
    // Calculate new position
    const deltaX = e.clientX - startX;
    const deltaY = e.clientY - startY;
    
    const newLeft = startLeft + deltaX;
    const newTop = startTop + deltaY;
    
    // Constrain to viewport bounds (with some padding)
    const maxLeft = window.innerWidth - currentPane.offsetWidth - 20;
    const maxTop = window.innerHeight - currentPane.offsetHeight - 20;
    
    const constrainedLeft = Math.max(20, Math.min(newLeft, maxLeft));
    const constrainedTop = Math.max(20, Math.min(newTop, maxTop));
    
    // Apply new position
    currentPane.style.left = constrainedLeft + 'px';
    currentPane.style.top = constrainedTop + 'px';
    currentPane.style.bottom = 'auto';
    currentPane.style.right = 'auto';
  }

  function stopDrag(e) {
    if (!isDragging) return;
    
    isDragging = false;
    
    if (currentPane) {
      // Remove dragging class
      currentPane.classList.remove('dragging');
      
      // Keep the dragged pane on top by setting it to the highest z-index
      // First, find the current highest z-index among all panes
      const allPanes = document.querySelectorAll('.xanadu-pane');
      let highestZIndex = 0;
      
      allPanes.forEach(pane => {
        if (pane !== currentPane) {
          const zIndex = parseInt(window.getComputedStyle(pane).zIndex) || 0;
          if (zIndex > highestZIndex) {
            highestZIndex = zIndex;
          }
        }
      });
      
      // Set the dragged pane to be one level higher than the current highest
      currentPane.style.zIndex = (highestZIndex + 1).toString();
    }
    
    currentPane = null;
    
    // Re-enable text selection
    document.body.style.userSelect = '';
  }

  // Initialize when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeDragging);
  } else {
    initializeDragging();
  }

  // Reinitialize on window resize to update constraints
  window.addEventListener('resize', function() {
    // Reset positions on mobile to prevent issues
    if (window.innerWidth <= 768) {
      const panes = document.querySelectorAll('.xanadu-pane');
      panes.forEach(pane => {
        pane.style.left = '';
        pane.style.top = '';
        pane.style.bottom = '';
        pane.style.right = '';
      });
    }
  });
})(); 