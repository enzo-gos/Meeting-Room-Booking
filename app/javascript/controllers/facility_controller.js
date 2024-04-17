import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="facility"
export default class extends Controller {
  static targets = ["facility", "facilitiesInput", "facilityDropdown"];

  connect() {
    if (this.facilitiesInputTarget.value) {
      this.facilitiesInputTarget.value = this.facilitiesInputTarget.value
        .split(" ")
        .join(",");

      this.element.querySelector(".facilities").classList.remove("hidden");
      this.element.querySelector(".facilities").classList.add("block");

      this.facilityTargets.forEach((el) => {
        if (this.facilitiesInputTarget.value.includes(el.value)) {
          el.classList.add("hidden");
          this.insertFacilityElement(el.value, el.textContent);
        }
      });
    }
  }

  insertFacilityElement(facilityId, facilityName) {
    const newDivText = document.createElement("div");
    newDivText.textContent = facilityName;

    const iconElement = document.createElement("i");
    iconElement.setAttribute("class", "material-icons md-18 round");
    iconElement.textContent = "do_disturb_on";

    const newRemoveButton = document.createElement("button");
    newRemoveButton.type = "button";
    newRemoveButton.value = facilityId;
    newRemoveButton.setAttribute("class", "flex items-center text-red-500");
    newRemoveButton.setAttribute(
      "data-action",
      "click->facility#removeFacility"
    );

    newRemoveButton.appendChild(iconElement);

    const newDiv = document.createElement("div");
    newDiv.setAttribute("class", "facilities-item");

    newDiv.appendChild(newDivText);
    newDiv.appendChild(newRemoveButton);

    const facilitiesDiv = this.element.querySelector(".facilities");
    facilitiesDiv.appendChild(newDiv);
  }

  addFacility(event) {
    const facilityId = event.target.value.trim();
    const facilityName = event.target.textContent.trim();

    // add to real input
    this.facilitiesInputTarget.value += facilityId + ",";

    // show list of facility
    this.element.querySelector(".facilities").classList.remove("hidden");
    this.element.querySelector(".facilities").classList.add("block");

    // add item in to list of facility
    this.insertFacilityElement(facilityId, facilityName);

    event.target.classList.add("hidden");
  }

  removeFacility(event) {
    event.target.parentElement.parentElement.remove();

    const ids = this.facilitiesInputTarget.value
      .split(",")
      .filter((val) => val !== event.target.parentElement.value);

    this.facilitiesInputTarget.value = ids.join(",");

    if (ids == "") {
      this.element.querySelector(".facilities").classList.remove("block");
      this.element.querySelector(".facilities").classList.add("hidden");
    }

    this.facilityTargets
      .find((el) => el.value === event.target.parentElement.value)
      .classList.remove("hidden");
  }

  searchFacility(event) {
    const eventValueLowerCase = event.target.value.toLowerCase();

    this.facilityTargets.forEach((el) => {
      if (!this.facilitiesInputTarget.value.includes(el.value)) {
        const lowercaseFacility = el.textContent.toLowerCase();

        if (!lowercaseFacility.includes(eventValueLowerCase)) {
          el.classList.add("hidden");
        } else {
          el.classList.remove("hidden");
        }
      }
    });
  }

  keepDropdownOpen() {
    this.element.querySelector(".facility_dropdown").classList.add("open");
  }

  closeDropdown(event) {
    this.element.querySelector(".facility_dropdown").classList.remove("open");
  }
}
