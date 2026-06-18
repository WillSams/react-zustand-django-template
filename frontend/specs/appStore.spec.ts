import { describe, it, expect, vi, beforeEach } from 'vitest';
import { useAppStore } from '../src/stores/appStore';
import { apiClient } from '../src/api/client';

vi.mock('../src/api/client', () => ({
  apiClient: {
    get: vi.fn(),
  },
}));

const mockedGet = vi.mocked(apiClient.get);

describe('appStore', () => {
  beforeEach(() => {
    useAppStore.setState({ message: null, loading: false, error: null });
    vi.clearAllMocks();
  });

  it('starts with empty state', () => {
    const { message, loading, error } = useAppStore.getState();
    expect(message).toBeNull();
    expect(loading).toBe(false);
    expect(error).toBeNull();
  });

  it('sets loading while fetching', async () => {
    let resolvePromise!: (value: unknown) => void;
    mockedGet.mockReturnValue(new Promise((res) => (resolvePromise = res)));

    const fetchPromise = useAppStore.getState().fetchStatus();
    expect(useAppStore.getState().loading).toBe(true);

    resolvePromise({ data: { message: 'ok' } });
    await fetchPromise;
  });

  it('stores the API result on success', async () => {
    mockedGet.mockResolvedValue({ data: { message: 'hello from api' } });

    await useAppStore.getState().fetchStatus();

    const { message, loading, error } = useAppStore.getState();
    expect(message).toBe('hello from api');
    expect(loading).toBe(false);
    expect(error).toBeNull();
  });

  it('stores error message on failure', async () => {
    mockedGet.mockRejectedValue(new Error('Network error'));

    await useAppStore.getState().fetchStatus();

    const { message, loading, error } = useAppStore.getState();
    expect(error).toBe('Network error');
    expect(loading).toBe(false);
    expect(message).toBeNull();
  });
});
