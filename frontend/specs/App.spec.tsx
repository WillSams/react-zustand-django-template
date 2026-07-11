import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material';
import App from '../src/App';
import { useAppStore } from '../src/stores/appStore';

const theme = createTheme();

const renderWithProviders = (ui: React.ReactElement) =>
  render(<ThemeProvider theme={theme}>{ui}</ThemeProvider>);

// Prevent actual API calls in component tests
vi.mock('../src/stores/appStore', async (importOriginal) => {
  const actual = await importOriginal<typeof import('../src/stores/appStore')>();
  return {
    ...actual,
    useAppStore: vi.fn(() => ({
      message: null,
      loading: false,
      error: null,
      fetchAbout: vi.fn(),
    })),
  };
});

const mockedUseAppStore = vi.mocked(useAppStore);

describe('App routing', () => {
  it('renders the home page at /', () => {
    mockedUseAppStore.mockReturnValue({
      message: null,
      loading: false,
      error: null,
      fetchAbout: vi.fn(),
    });

    renderWithProviders(
      <MemoryRouter initialEntries={['/']}>
        <App />
      </MemoryRouter>,
    );

    expect(screen.getByRole('heading', { name: /template app/i })).toBeInTheDocument();
  });

  it('renders the 404 page for unknown routes', () => {
    renderWithProviders(
      <MemoryRouter initialEntries={['/does-not-exist']}>
        <App />
      </MemoryRouter>,
    );

    expect(screen.getByRole('heading', { name: /404/i })).toBeInTheDocument();
  });
});
