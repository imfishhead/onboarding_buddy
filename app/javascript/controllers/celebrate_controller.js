import { Controller } from "@hotwired/stimulus"

// data-controller="celebrate"
// data-action="submit->celebrate#burst click->celebrate#burst"
export default class extends Controller {
  burst(event) {
    // Play confetti/sparkles without blocking the form submit
    try {
      this.#confettiAtEvent(event)
      this.#ringPulse()
    } catch (_) {}
    
    // Ensure form submission continues
    if (event.type === 'click' && event.target.type === 'submit') {
      // Don't prevent default for submit buttons
      return
    }
  }

  #confettiAtEvent(event) {
    const origin = this.#eventToViewport(event)
    this.#confetti({ origin, particleCount: 80, spread: 60, startVelocity: 28 })
    setTimeout(() => this.#confetti({ origin, particleCount: 40, spread: 80, startVelocity: 22 }), 120)
  }

  #ringPulse() {
    const el = this.element
    el.classList.add("animate-scale-pop")
    setTimeout(() => el.classList.remove("animate-scale-pop"), 280)
  }

  #eventToViewport(event) {
    let x = 0.5, y = 0.5
    if (event && event.clientX != null) {
      x = event.clientX / window.innerWidth
      y = event.clientY / window.innerHeight
    } else if (this.element?.getBoundingClientRect) {
      const rect = this.element.getBoundingClientRect()
      x = (rect.left + rect.width / 2) / window.innerWidth
      y = (rect.top + rect.height / 2) / window.innerHeight
    }
    return { x, y }
  }

  // Tiny confetti implementation (no dependency)
  #confetti({ origin, particleCount = 60, spread = 45, startVelocity = 25 }) {
    const angle = -90
    const defaults = { ticks: 120, gravity: 0.9, decay: 0.92, scalar: 1 }
    const canvas = this.#getCanvas()
    const ctx = canvas.getContext("2d")
    const colors = ["#6366F1", "#22C55E", "#F59E0B", "#EF4444", "#06B6D4"]
    const particles = []
    const rad = (deg) => (deg * Math.PI) / 180
    const random = (min, max) => Math.random() * (max - min) + min

    for (let i = 0; i < particleCount; i++) {
      particles.push({
        x: origin.x * canvas.width,
        y: origin.y * canvas.height,
        angle: rad(angle + random(-spread / 2, spread / 2)),
        velocity: startVelocity * 0.5 + Math.random() * startVelocity,
        tick: 0,
        wobble: Math.random() * 10,
        wobbleSpeed: 0.1 + Math.random() * 0.15,
        color: colors[(i % colors.length)],
        shape: Math.random() > 0.5 ? "rect" : "circle",
        ...defaults,
      })
    }

    let animationFrame
    const update = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      particles.forEach((p) => {
        p.tick++
        p.x += Math.cos(p.angle) * p.velocity
        p.y += Math.sin(p.angle) * p.velocity + p.gravity
        p.velocity *= p.decay
        p.wobble += p.wobbleSpeed

        if (p.shape === "rect") {
          ctx.fillStyle = p.color
          ctx.fillRect(p.x + Math.cos(p.wobble) * 2, p.y + Math.sin(p.wobble) * 2, 4 * p.scalar, 4 * p.scalar)
        } else {
          ctx.fillStyle = p.color
          ctx.beginPath()
          ctx.arc(p.x, p.y, 2.5 * p.scalar, 0, Math.PI * 2)
          ctx.fill()
        }
      })

      if (particles.every((p) => p.tick > p.ticks)) {
        cancelAnimationFrame(animationFrame)
        canvas.remove()
      } else {
        animationFrame = requestAnimationFrame(update)
      }
    }

    update()
  }

  #getCanvas() {
    let canvas = document.getElementById("celebrate-canvas")
    if (!canvas) {
      canvas = document.createElement("canvas")
      canvas.id = "celebrate-canvas"
      canvas.style.position = "fixed"
      canvas.style.pointerEvents = "none"
      canvas.style.inset = "0"
      canvas.style.zIndex = "9999"
      document.body.appendChild(canvas)
      const resize = () => {
        canvas.width = window.innerWidth
        canvas.height = window.innerHeight
      }
      resize()
      window.addEventListener("resize", resize, { passive: true })
      // Clean up when page unloads
      window.addEventListener("turbo:before-render", () => canvas.remove(), { once: true })
    }
    return canvas
  }
}


