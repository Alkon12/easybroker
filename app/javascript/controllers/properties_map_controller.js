import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="properties-map"
export default class extends Controller {
  static values = {
    apiUrl: String
  }

  static targets = ["container", "loading", "error", "counter"]

  connect() {
    this.map = null
    this.markers = []
    this.waitForLeaflet()
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  waitForLeaflet() {
    if (typeof window.L !== 'undefined') {
      this.initializeMap()
      this.loadProperties()
    } else {
      setTimeout(() => this.waitForLeaflet(), 100)
    }
  }

  async loadProperties() {
    this.showLoading()

    try {
      const response = await fetch(this.apiUrlValue)

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()

      if (data.error) {
        this.showError(data.error)
        return
      }

      this.addPropertiesToMap(data.properties)
      this.updateCounter(data.meta.valid_count)
      this.hideLoading()

      // Fit map bounds to show all markers
      if (this.markers.length > 0) {
        const group = window.L.featureGroup(this.markers)
        this.map.fitBounds(group.getBounds(), { padding: [50, 50] })
      }
    } catch (error) {
      console.error('Failed to load properties:', error)
      this.showError('Failed to load property locations. Please try again.')
    }
  }

  initializeMap() {
    const L = window.L

    // Fix Leaflet icon paths when using CDN
    delete L.Icon.Default.prototype._getIconUrl
    L.Icon.Default.mergeOptions({
      iconRetinaUrl: 'https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images/marker-icon-2x.png',
      iconUrl: 'https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images/marker-icon.png',
      shadowUrl: 'https://cdn.jsdelivr.net/npm/leaflet@1.9.4/dist/images/marker-shadow.png',
    })

    // Create map - will be centered when markers load
    this.map = L.map(this.containerTarget).setView([19.4326, -99.1332], 11)

    // Add OpenStreetMap tiles
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19
    }).addTo(this.map)
  }

  addPropertiesToMap(properties) {
    const L = window.L

    properties.forEach(property => {
      const marker = L.marker([property.latitude, property.longitude])
        .addTo(this.map)

      // Create popup with mini-card
      const popupContent = this.createPopupContent(property)
      marker.bindPopup(popupContent, {
        maxWidth: 320,
        className: 'property-popup'
      })

      this.markers.push(marker)
    })
  }

  createPopupContent(property) {
    // Create iOS-style mini card matching the design system
    return `
      <a href="${property.url}" class="block hover:opacity-90 transition-opacity">
        <div class="property-popup-card">
          ${property.thumbnail ? `
            <div class="property-popup-image">
              <img src="${property.thumbnail}" alt="${this.escapeHtml(property.title)}" />
              ${property.operation_types ? `
                <span class="property-popup-badge">${this.escapeHtml(property.operation_types)}</span>
              ` : ''}
            </div>
          ` : ''}

          <div class="property-popup-content">
            <h3 class="property-popup-title">${this.escapeHtml(property.title)}</h3>

            ${property.full_location ? `
              <p class="property-popup-location">
                <svg class="w-3 h-3 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                ${this.escapeHtml(property.full_location)}
              </p>
            ` : ''}

            ${property.summary ? `
              <p class="property-popup-summary">${this.escapeHtml(property.summary)}</p>
            ` : ''}

            <div class="property-popup-footer">
              <span class="property-popup-price">${this.escapeHtml(property.price)}</span>
              <span class="property-popup-link">View details →</span>
            </div>
          </div>
        </div>
      </a>
    `
  }

  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove('hidden')
    }
    if (this.hasContainerTarget) {
      this.containerTarget.classList.add('opacity-50')
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add('hidden')
    }
    if (this.hasContainerTarget) {
      this.containerTarget.classList.remove('opacity-50')
    }
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.remove('hidden')
    }
    this.hideLoading()
  }

  updateCounter(count) {
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `Showing ${count} ${count === 1 ? 'property' : 'properties'}`
    }
  }
}
