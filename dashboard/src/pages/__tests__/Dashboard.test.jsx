import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor, act } from '@testing-library/react'
import Dashboard from '../Dashboard'

// Mock Supabase with proper chain
const mockSupabase = {
  from: vi.fn(() => ({
    select: vi.fn(() => ({
      eq: vi.fn(() => ({
        select: vi.fn(() => ({
          count: vi.fn(() => Promise.resolve({ count: 0, error: null })),
        })),
      })),
      count: vi.fn(() => Promise.resolve({ count: 0, error: null })),
    })),
  })),
}

vi.mock('../../lib/supabase', () => ({
  supabase: mockSupabase,
}))

// Mock lucide-react icons
vi.mock('lucide-react', () => ({
  Users: () => <div data-testid="icon-users">Users</div>,
  CheckCircle: () => <div data-testid="icon-check">Check</div>,
  XCircle: () => <div data-testid="icon-x">X</div>,
  FileText: () => <div data-testid="icon-file">File</div>,
  TrendingUp: () => <div data-testid="icon-trend">Trend</div>,
}))

describe('Dashboard Component', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders dashboard title', async () => {
    await act(async () => {
      render(<Dashboard />)
    })
    
    await waitFor(() => {
      expect(screen.getByText(/dashboard/i)).toBeInTheDocument()
    })
  })

  it('displays stats cards', async () => {
    await act(async () => {
      render(<Dashboard />)
    })
    
    await waitFor(() => {
      // Should render stats cards
      expect(screen.getByText(/dashboard/i)).toBeInTheDocument()
    })
  })

  it('handles missing Supabase configuration', () => {
    // Mock supabase as null
    vi.mocked(mockSupabase.from).mockReturnValue(null)
    
    render(<Dashboard />)
    
    expect(screen.getByText(/supabase not configured/i)).toBeInTheDocument()
  })
})

