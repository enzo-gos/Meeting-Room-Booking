import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="room-filter-form"
export default class extends Controller {
  static targets = ["form", "filterBtn", "filterOption"];

  connect() {
    this.activeFilter();
    $("body").on("click", (event) => {
      this.closeDropdown();
    });
  }

  hasFilter() {
    return this.filterOptionTargets.some((el) => el.checked === true);
  }

  activeFilter() {
    if (this.hasFilter()) {
      $(this.filterBtnTarget).removeClass("text-secondary-500");
      $(this.filterBtnTarget).addClass(
        "text-primary-800 border border-primary-600"
      );

      $(this.filterBtnTarget).children().removeClass("text-black");
      $(this.filterBtnTarget).children().addClass("text-primary-800");
    } else {
      $(this.filterBtnTarget).removeClass(
        "text-primary-800 border-primary-600"
      );
      $(this.filterBtnTarget).addClass("text-secondary-500");

      $(this.filterBtnTarget).children().removeClass("text-primary-800");
      $(this.filterBtnTarget).children().addClass("text-black");
    }
  }

  filter() {
    clearTimeout(this.timeout);
    this.activeFilter();

    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit();
    }, 300);
  }

  keepDropdownOpen(event) {
    event.stopPropagation();
    $(".tag_dropdown").addClass("open");
  }

  stopPropagation(event) {
    event.stopPropagation();
  }

  closeDropdown(event) {
    $(".tag_dropdown").removeClass("open");
  }
}
