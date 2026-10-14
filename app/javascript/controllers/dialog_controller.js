import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.frame = this.element.closest("turbo-frame");
    this.element.showModal();
  }

  disconnect() {
    this.frame?.removeAttribute("src");
  }

  close() {
    this.element.close();
  }

  closeOnBackdrop(event) {
    if (event.target === this.element) {
      this.close();
    }
  }

  clear() {
    this.element.remove();
  }
}
