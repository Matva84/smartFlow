document.addEventListener("DOMContentLoaded", function() {
  const menuItems = document.querySelectorAll(".btn-lat-menu");

  menuItems.forEach(item => {
    item.addEventListener("click", function(e) {
      menuItems.forEach(i => i.classList.remove("active"));
      e.currentTarget.classList.add("active");
    });
  });
});
