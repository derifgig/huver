// timestamp.js
document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll(".js-timestamp").forEach((el) => {
    const ts = parseInt(el.dataset.ts, 10);
    if (!isNaN(ts)) {
      const date = new Date(ts * 1000);
      el.textContent = date.toLocaleString();
    }
  });
});
