import { Controller } from "@hotwired/stimulus"
import Tagify from "@Yaireo/tagify"

export default class extends Controller {
    connect() {
        // Tagify handles the typing, searching, dropdown, and "Enter to create" natively!
        this.tagify = new Tagify(this.element, {
            whitelist: this.element.dataset.tagsValue ? JSON.parse(this.element.dataset.tagsValue) : [],
            dropdown: {
                enabled: 1, // start suggestions after 1 character typed
                maxItems: 10,
                fuzzySearch: true
            }
        })
    }

  disconnect() {
    this.tagify.destroy()
  }
}