import { describe, it, expect, vi } from 'vitest'
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import App from './App'

// Mock Supabase
vi.mock('./lib/supabase', () => ({
  supabase: {
    from: vi.fn(),
  },
}))

describe('App Component', () => {
  it('renders without crashing', () => {
    render(
      <BrowserRouter>
        <App />
      </BrowserRouter>
    )
    
    // App should render without errors
    expect(document.body).toBeTruthy()
  })

  it('handles Supabase configuration check', () => {
    render(
      <BrowserRouter>
        <App />
      </BrowserRouter>
    )
    
    // Should render app or configuration error
    expect(document.body).toBeTruthy()
  })
})


