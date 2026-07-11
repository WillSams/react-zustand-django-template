import { create } from 'zustand';
import { apiClient } from '../api/client';

interface AppState {
  message: string | null;
  loading: boolean;
  error: string | null;
  fetchAbout: () => Promise<void>;
}

export const useAppStore = create<AppState>((set) => ({
  message: null,
  loading: false,
  error: null,

  fetchAbout: async () => {
    set({ loading: true, error: null });
    try {
      const { data } = await apiClient.get<{ message: string }>('/about');
      set({ message: data.message, loading: false });
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      set({ error: message, loading: false });
    }
  },
}));
