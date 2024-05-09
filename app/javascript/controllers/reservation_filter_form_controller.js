import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="reservation-filter-form"
export default class extends Controller {
  static targets = ["form", "roomSelect"];

  connect() {}

  filter() {
    clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit();
    }, 300);
  }

  reset() {
    this.element.reset();
    $(this.roomSelectTarget).prop("selectedIndex", 0);
    this.filter();
    this.getDateInput().clear();
    this.getStartTimeInput().clear();
  }

  flatpickrController() {
    return this.application.getControllerForElementAndIdentifier(
      this.element,
      "flatpickr"
    );
  }

  getDateInput() {
    return this.flatpickrController().getDateInput();
  }

  getStartTimeInput() {
    return this.flatpickrController().getOnlyStartTimeInput();
  }
}
