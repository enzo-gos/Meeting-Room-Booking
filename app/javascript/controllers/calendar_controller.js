import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

import FullCalendar from "fullcalendar";
import moment from "moment";

// Connects to data-controller="calendar"
export default class extends Controller {
  static targets = ["bookModal", "bookForm"];

  connect() {
    this.date_time = "";
    this.date_time_start = "";
    this.date_time_end = "";

    const calendarEl = $("#calendar").get(0);
    const calendar = new FullCalendar.Calendar(calendarEl, {
      timeZone: "local",
      initialView: "timeGridWeek",
      headerToolbar: {
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,timeGridWeek,timeGridDay",
      },
      allDaySlot: false,
      slotMinTime: "9:00:00",
      slotMaxTime: "18:00:00",
      selectable: true,
      eventOverlap: false,
      dayMaxEvents: true,
      // events:
      // "https://fullcalendar.io/api/demo-feeds/events.json?overload-day&start=2024-03-31T00%3A00%3A00Z&end=2024-05-12T00%3A00%3A00Z&timeZone=UTC",
      events: `${window.location.pathname}/events.json`,
      selectAllow: (selectInfo) => {
        const startDateTime = moment(selectInfo.start);
        const endDateTime = moment(selectInfo.end);

        if (startDateTime < moment()) return false;

        const evts = calendar.getEvents().map(function (evt) {
          const eventStart = moment(evt.start);
          const eventEnd = evt.end
            ? moment(evt.end)
            : eventStart.clone().add(1, "hours");

          return (
            startDateTime.isSame(eventStart, "day") &&
            ((startDateTime >= eventStart && startDateTime < eventEnd) ||
              (endDateTime > eventStart && endDateTime <= eventEnd) ||
              (startDateTime <= eventStart && endDateTime >= eventEnd))
          );
        });

        return (
          !selectInfo.allDay &&
          startDateTime.isSame(endDateTime, "day") &&
          endDateTime - startDateTime <= 24 * 60 * 60 * 1000 &&
          evts.every((v) => v === false)
        );
      },
      select: (selectInfo) => {
        this.date_time = moment(selectInfo.start);
        this.date_time_start = moment(selectInfo.start);
        this.date_time_end = moment(selectInfo.end);

        this.openBookModal();
      },
    });
    calendar.render();

    this.eventCreated = $(document).on("eventCreated", (e) => {
      if (e.detail?.refetch) {
        calendar.refetchEvents();
      }
    });
  }

  disconnect() {
    $(document).off("eventCreated", this.eventCreated);
  }

  bookFormTargetConnected() {
    $(this.element).attr("data-controller", "calendar flatpickr");

    Promise.resolve().then(() => {
      if (this.date_time && this.date_time_start && this.date_time_end) {
        const currentDay = moment().date();

        const dateInput = this.getDateInput();
        const timeStartInput = this.getStartTimeInput();
        const timeEndInput = this.getEndTimeInput();

        dateInput.setDate(this.date_time.toDate());
        timeStartInput.setDate(
          this.date_time_start.format("HH:mm"),
          true,
          "H:i"
        );
        timeEndInput.setDate(this.date_time_end.format("HH:mm"), true, "H:i");

        timeStartInput.set(
          "minTime",
          currentDay == this.date_time.date() ? moment().format("H:i") : "9:00"
        );
      }

      $(this.bookModalTarget).removeClass("hidden");
      $("body").addClass("overflow-hidden");
    });
  }

  removeFlatpickr() {
    $(this.element).attr("data-controller", "calendar");
  }

  openBookModal() {
    const url = $(this.element).find("#book_room_btn").attr("href");

    fetch(url, { headers: { Accept: "text/vnd.turbo-stream.html" } })
      .then((r) => r.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }

  closeBookModal() {
    $(this.bookModalTarget).addClass("hidden");
    $("body").removeClass("overflow-hidden");

    $(this.element).find("#modal-title").empty();
    $(this.element).find("#modal-body").empty();
    $(this.element).attr("data-controller", "calendar");

    this.date_time = "";
    this.date_time_start = "";
    this.date_time_end = "";
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
    return this.flatpickrController().getStartTimeInput();
  }

  getEndTimeInput() {
    return this.flatpickrController().getEndTimeInput();
  }
}
