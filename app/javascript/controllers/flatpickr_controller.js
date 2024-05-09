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

    const start_time_el = this.getStartTimeInput();
    const end_time_el = this.getEndTimeInput();

    if (start_time_el && end_time_el) {
      const start_time = $(start_time_el.element).attr("value").split(" ")[1];
      const end_time = $(end_time_el.element).attr("value").split(" ")[1];

      if (start_time && end_time) {
        $(start_time_el.element).attr("value", start_time);
        $(end_time_el.element).attr("value", end_time);

        start_time_el.setDate(start_time, true, "H:i");
        end_time_el.setDate(end_time, true, "H:i");
      }
    }
  }

  getOnlyStartTimeInput() {
    return this.time_input;
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
