import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import Layout from '../Layout'

// Mock lucide-react icons
vi.mock('lucide-react', () => ({
  LayoutDashboard: () => <div data-testid="icon-dashboard">Dashboard</div>,
  Building2: () => <div data-testid="icon-pharmacies">Pharmacies</div>,
  Package: () => <div data-testid="icon-products">Products</div>,
  FileText: () => <div data-testid="icon-reports">Reports</div>,
  Menu: () => <div data-testid="icon-menu">Menu</div>,
  X: () => <div data-testid="icon-close">Close</div>,
}))

const renderWithRouter = (component, { route = '/dashboard' } = {}) => {
  window.history.pushState({}, 'Test page', route)
  return render(
    <BrowserRouter>
      {component}
    </BrowserRouter>
  )
}

describe('Layout Component', () => {
  it('renders sidebar with navigation items', () => {
    renderWithRouter(<Layout><div>Test Content</div></Layout>)
    
    expect(screen.getByText('MedGuard Admin')).toBeInTheDocument()
    // Use getAllByText since "Dashboard" appears multiple times (icon and text)
    expect(screen.getAllByText('Dashboard').length).toBeGreaterThan(0)
    expect(screen.getAllByText('Pharmacies').length).toBeGreaterThan(0)
    expect(screen.getAllByText('Products').length).toBeGreaterThan(0)
    expect(screen.getAllByText('Reports').length).toBeGreaterThan(0)
  })

  it('renders children content', () => {
    renderWithRouter(<Layout><div>Test Content</div></Layout>)
    
    expect(screen.getByText('Test Content')).toBeInTheDocument()
  })

  it('has toggle button for sidebar', () => {
    renderWithRouter(<Layout><div>Test</div></Layout>)
    
    const toggleButton = screen.getByRole('button')
    expect(toggleButton).toBeInTheDocument()
  })

  it('displays navigation icons', () => {
    renderWithRouter(<Layout><div>Test</div></Layout>)
    
    expect(screen.getByTestId('icon-dashboard')).toBeInTheDocument()
    expect(screen.getByTestId('icon-pharmacies')).toBeInTheDocument()
    expect(screen.getByTestId('icon-products')).toBeInTheDocument()
    expect(screen.getByTestId('icon-reports')).toBeInTheDocument()
  })
})

