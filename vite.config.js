import { defineConfig } from 'vite';
import elmPlugin from 'vite-plugin-elm';

export default defineConfig({
  plugins: [elmPlugin()],
  server: {
    port: 8001,
    open: true,
    // Fixes "Blank Screen" on refresh of sub-pages
    historyApiFallback: true 
  },
  // This helps Vite resolve the .elm files correctly
  resolve: {
    extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json', '.elm']
  }
});