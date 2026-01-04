import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    latitude: Number,
    longitude: Number,
    name: String
  }

  connect() {
    // Wait for Leaflet to be loaded from CDN
    this.waitForLeaflet()
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }

  waitForLeaflet() {
    if (typeof window.L !== 'undefined') {
      this.initializeMap()
    } else {
      setTimeout(() => this.waitForLeaflet(), 100)
    }
  }

  initializeMap() {
    const L = window.L

    // Fix Leaflet icon paths when using CDN
    delete L.Icon.Default.prototype._getIconUrl;
    L.Icon.Default.mergeOptions({
      iconRetinaUrl: 'https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images/marker-icon-2x.png',
      iconUrl: 'https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images/marker-icon.png',
      shadowUrl: 'https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images/marker-shadow.png',
    });

    // Create map centered on the property location
    this.map = L.map(this.element).setView(
      [this.latitudeValue, this.longitudeValue],
      15
    )

    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19
    }).addTo(this.map)

    // Add marker for the property
    const marker = L.marker([this.latitudeValue, this.longitudeValue]).addTo(this.map)

    // Add popup with property name if available
    if (this.nameValue) {
      marker.bindPopup(this.nameValue).openPopup()
    }
  }
}
