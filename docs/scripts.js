// Basic JavaScript functionality for the documentation

document.addEventListener('DOMContentLoaded', function() {
    const sidebar = document.getElementById('sidebar');
    const menuToggle = document.querySelector('.menuToggle');
    const main = document.querySelector('main');
    const links = sidebar.querySelectorAll('a[href^="#"]');
    
    // Set initial state from localStorage
    const sidebarState = localStorage.getItem('sidebarState');
    if (sidebarState === 'closed') {
        sidebar.classList.add('closed');
        main.classList.add('full-width');
        menuToggle?.classList.add('closed');
    }
    
    // Toggle sidebar
    menuToggle?.addEventListener('click', function() {
        sidebar.classList.toggle('closed');
        main.classList.toggle('full-width');
        menuToggle.classList.toggle('closed');
        
        // Save state to localStorage
        localStorage.setItem('sidebarState', 
            sidebar.classList.contains('closed') ? 'closed' : 'open'
        );
    });

    // Handle navigation highlighting and smooth scroll
    links.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Remove active class from all links
            links.forEach(l => l.classList.remove('active'));
            
            // Add active class to clicked link
            this.classList.add('active');
            
            // Smooth scroll to section
            const targetId = this.getAttribute('href');
            const targetSection = document.querySelector(targetId);
            
            if (targetSection) {
                targetSection.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }

            // Close sidebar on mobile
            if (window.innerWidth <= 768) {
                sidebar.classList.add('closed');
                main.classList.add('full-width');
                menuToggle?.classList.add('closed');
            }
        });
    });

    // Highlight current section while scrolling
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const id = entry.target.getAttribute('id');
                links.forEach(link => {
                    link.classList.toggle('active', link.getAttribute('href') === `#${id}`);
                });
            }
        });
    }, { threshold: 0.5 });

    // Observe all sections
    document.querySelectorAll('section[id]').forEach((section) => {
        observer.observe(section);
    });

    // Handle mobile menu
    if (window.innerWidth <= 768) {
        sidebar.classList.add('closed');
        main.classList.add('full-width');
        menuToggle?.classList.add('closed');
    }

    // Handle window resize
    window.addEventListener('resize', function() {
        if (window.innerWidth <= 768) {
            sidebar.classList.add('closed');
            main.classList.add('full-width');
            menuToggle?.classList.add('closed');
        }
    });

    // Prevent clicks inside sidebar from closing it
    sidebar.addEventListener('click', function(e) {
        e.stopPropagation();
    });
});
