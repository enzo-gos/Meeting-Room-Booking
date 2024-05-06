import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="tag"
export default class extends Controller {
  static targets = ["tag", "tagsInput", "tagDropdown"];

  connect() {
    if (
      this.tagsInputTarget.value &&
      !this.tagsInputTarget.value.includes(",")
    ) {
      this.tagsInputTarget.value = this.tagsInputTarget.value
        .split(" ")
        .reduce((prev, curr) => (prev += curr + ","), "");

      this.element.querySelector(".tags").classList.remove("hidden");
      this.element.querySelector(".tags").classList.add("block");

      this.tagTargets.forEach((el) => {
        if (this.tagsInputTarget.value.includes(el.value)) {
          el.classList.add("hidden");
          this.insertTagElement(el.value, el.textContent);
        }
      });
    }
  }

  insertTagElement(tagId, tagName) {
    const newDivText = document.createElement("div");
    newDivText.textContent = tagName;

    const iconElement = document.createElement("i");
    iconElement.setAttribute("class", "material-icons md-18 round");
    iconElement.textContent = "do_disturb_on";

    const newRemoveButton = document.createElement("button");
    newRemoveButton.type = "button";
    newRemoveButton.value = tagId;
    newRemoveButton.setAttribute("class", "flex items-center text-red-500");
    newRemoveButton.setAttribute("data-action", "click->tag#removeTag");

    newRemoveButton.appendChild(iconElement);

    const newDiv = document.createElement("div");
    newDiv.setAttribute("class", "tags-item");

    newDiv.appendChild(newDivText);
    newDiv.appendChild(newRemoveButton);

    const tagsDiv = this.element.querySelector(".tags");
    tagsDiv.appendChild(newDiv);
  }

  addTag(event) {
    const tagId = event.target.value.trim();
    const tagName = event.target.textContent.trim();

    // add to real input
    this.tagsInputTarget.value += tagId + ",";

    // show list of tag
    this.element.querySelector(".tags").classList.remove("hidden");
    this.element.querySelector(".tags").classList.add("block");

    // add item in to list of tag
    this.insertTagElement(tagId, tagName);

    event.target.classList.add("hidden");
  }

  removeTag(event) {
    event.target.parentElement.parentElement.remove();

    const ids = this.tagsInputTarget.value
      .split(",")
      .filter((val) => val !== event.target.parentElement.value);

    this.tagsInputTarget.value = ids.join(",");

    if (ids == "") {
      this.element.querySelector(".tags").classList.remove("block");
      this.element.querySelector(".tags").classList.add("hidden");
    }

    this.tagTargets
      .find((el) => el.value === event.target.parentElement.value)
      .classList.remove("hidden");
  }

  searchTag(event) {
    const eventValueLowerCase = event.target.value.toLowerCase();

    this.tagTargets.forEach((el) => {
      if (!this.tagsInputTarget.value.includes(el.value)) {
        const lowercaseTag = el.textContent.toLowerCase();

        if (!lowercaseTag.includes(eventValueLowerCase)) {
          el.classList.add("hidden");
        } else {
          el.classList.remove("hidden");
        }
      }
    });
  }

  keepDropdownOpen() {
    this.element.querySelector(".tag_dropdown").classList.add("open");
  }

  closeDropdown() {
    this.element.querySelector(".tag_dropdown").classList.remove("open");
  }
}
