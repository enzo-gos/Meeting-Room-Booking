import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";

export default class extends Controller {
  connect() {
    this.time_input = flatpickr(".fp_time", {
      enableTime: true,
      noCalendar: true,
      dateFormat: "H:i",
      minTime: "9:00",
      maxTime: "18:00",
      time_24hr: true,
    });

    this.date_input = flatpickr(".fp_date", {
      minDate: "today",
      disable: [
        function (date) {
          return date.getDay() === 0;
        },
      ],
    });
  }

  getStartTimeInput() {
    return this.time_input[0];
  }

  getEndTimeInput() {
    return this.time_input[1];
  }

  getDateInput() {
    return this.date_input;
  }
}
