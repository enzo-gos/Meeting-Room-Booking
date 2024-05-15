import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="reservation"
export default class extends Controller {
  static targets = ["optionModal", "exceptDate", "currentDate"];

  connect() {}

  exceptDateTargetConnected() {
    $(this.exceptDateTarget).val(this.currentDateTarget.value);
  }

  openModal() {
    $(this.optionModalTarget).removeClass("hidden");
    $("body").addClass("overflow-hidden");
  }

  closeModal() {
    $(this.optionModalTarget).addClass("hidden");
    $("body").removeClass("overflow-hidden");

    $(this.element).find("#modal-body").empty();
  }
}
