// Basic JavaScript functionality for the documentation

document.addEventListener("DOMContentLoaded", function () {
  const sidebar = document.getElementById("sidebar");
  const menuToggle = document.querySelector(".menuToggle");
  const main = document.querySelector("main");
  const links = sidebar.querySelectorAll('a[href^="#"]');

  // Add this inside the DOMContentLoaded event listener
  const copyButtons = document.querySelectorAll(".copy-button");

  copyButtons.forEach((button) => {
    button.addEventListener("click", function () {
      // Add a class to indicate the button was clicked
      this.classList.add("active");

      // Remove the class after a short delay
      setTimeout(() => {
        this.classList.remove("active");
      }, 200); // Adjust the duration as needed
    });
  });

  // Set initial state from localStorage
  const sidebarState = localStorage.getItem("sidebarState");
  if (sidebarState === "closed") {
    sidebar.classList.add("closed");
    main.classList.add("full-width");
    menuToggle?.classList.add("closed");
  }

  // Toggle sidebar
  menuToggle?.addEventListener("click", function () {
    const isClosed = sidebar.classList.toggle("closed");
    if (isClosed) {
      sidebar.classList.remove("open");
    } else {
      sidebar.classList.add("open");
    }

    // Save state to localStorage
    localStorage.setItem("sidebarState", isClosed ? "closed" : "open");
  });

  // Handle navigation highlighting and smooth scroll
  links.forEach((link) => {
    link.addEventListener("click", function (e) {
      e.preventDefault();

      // Remove active class from all links
      links.forEach((l) => l.classList.remove("active"));

      // Add active class to clicked link
      this.classList.add("active");

      // Smooth scroll to section
      const targetId = this.getAttribute("href");
      const targetSection = document.querySelector(targetId);

      if (targetSection) {
        targetSection.scrollIntoView({
          behavior: "smooth",
          block: "start",
        });
      }

      // Close sidebar on mobile
      if (window.innerWidth <= 768) {
        sidebar.classList.add("closed");
        main.classList.add("full-width");
        menuToggle?.classList.add("closed");
      }
    });
  });

  // Highlight current section while scrolling
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const id = entry.target.getAttribute("id");
          links.forEach((link) => {
            link.classList.toggle(
              "active",
              link.getAttribute("href") === `#${id}`
            );
          });
        }
      });
    },
    { threshold: 0.5 }
  );

  // Observe all sections
  document.querySelectorAll("section[id]").forEach((section) => {
    observer.observe(section);
  });

  // Handle mobile menu
  if (window.innerWidth <= 768) {
    sidebar.classList.add("closed");
    main.classList.add("full-width");
    menuToggle?.classList.add("closed");
  }

  // Handle window resize
  window.addEventListener("resize", function () {
    if (window.innerWidth <= 768) {
      sidebar.classList.add("closed");
      main.classList.add("full-width");
      menuToggle?.classList.add("closed");
    }
  });

  // Prevent clicks inside sidebar from closing it
  sidebar.addEventListener("click", function (e) {
    e.stopPropagation();
  });

  // Filter sections based on search input
  if (document.getElementById("search") !== null) {
    const searchInput = document.getElementById("search");
    const sections = document.querySelectorAll(".section-link");

    searchInput.addEventListener("input", function () {
      const query = this.value.toLowerCase();

      sections.forEach((section) => {
        const name = section.querySelector("h2").textContent.toLowerCase();
        const tags = Array.from(section.querySelectorAll(".tag")).map((tag) =>
          tag.textContent.toLowerCase()
        );
        const matches =
          name.includes(query) || tags.some((tag) => tag.includes(query));

        section.style.display = matches ? "" : "none";
      });
    });
  }

  // Handle dark mode toggle
  const toggleContainer = document.querySelector(".dark-mode-toggle");
  const sunIcon = toggleContainer.querySelector(".fa-sun");
  const moonIcon = toggleContainer.querySelector(".fa-moon");

  // Check local storage for dark mode preference
  if (localStorage.getItem("darkMode") === "enabled") {
    document.body.classList.add("dark-mode");
    sunIcon.style.display = "none"; // Hide sun icon
    moonIcon.style.display = "inline"; // Show moon icon

    // Apply dark mode to all sections
    document.querySelectorAll("section").forEach((section) => {
      section.classList.add("dark-mode");
    });
  }

  // Add event listener for toggle
  toggleContainer.addEventListener("click", () => {
    document.body.classList.toggle("dark-mode");
    document.querySelectorAll("section").forEach((section) => {
      section.classList.toggle("dark-mode");
    });

    // Toggle icon visibility
    sunIcon.style.display =
      sunIcon.style.display === "none" ? "inline" : "none";
    moonIcon.style.display =
      moonIcon.style.display === "none" ? "inline" : "none";

    // Save the current state to local storage
    if (document.body.classList.contains("dark-mode")) {
      localStorage.setItem("darkMode", "enabled");
    } else {
      localStorage.setItem("darkMode", "disabled");
    }
  });
});
