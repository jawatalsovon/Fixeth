#!/bin/bash

# Fixeth Developer Quick Setup
# Fast local development environment with sensible defaults
# Usage: ./scripts/dev-setup.sh

set -e

echo "Fixeth Developer Setup (Quick)"
echo ""

# Install with pnpm (faster)
if command -v pnpm &> /dev/null; then
    echo "Installing dependencies (pnpm)..."
    pnpm install
else
    echo "Installing dependencies (npm)..."
    npm install
fi

# Create .env.local with minimal config for local testing
if [ ! -f .env.local ]; then
    echo "Creating .env.local with development defaults..."
    cat > .env.local << 'EOF'
# Development Defaults
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=$(openssl rand -base64 32)

# Supabase (use the shared data project)
NEXT_PUBLIC_SUPABASE_URL=https://oxfynuytsnifqqhbmpcv.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=sb_publishable_ATVf_la2Z6kuYO3rp1MIyg_SnBm0Snd
NEXT_PUBLIC_SUPABASE_DATA_URL=https://oxfynuytsnifqqhbmpcv.supabase.co
NEXT_PUBLIC_SUPABASE_DATA_KEY=sb_publishable_ATVf_la2Z6kuYO3rp1MIyg_SnBm0Snd

# AI (optional — Chat-with-Video & AI Mentor won't work without these)
# Add your own Gemini API key: https://ai.google.dev/gemini-api
NEXT_PUBLIC_GEMINI_API_KEY=

# App config
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_ENV=development
EOF
    echo "✓ Created .env.local"
    echo ""
    echo "To enable Chat-with-Video & AI Mentor:"
    echo "  1. Get a free Gemini API key: https://ai.google.dev/gemini-api"
    echo "  2. Add to .env.local: NEXT_PUBLIC_GEMINI_API_KEY=your_key_here"
fi

echo ""
echo "Type checking..."
npx tsc --noEmit

echo ""
echo "✓ Ready to develop!"
echo "  npm run dev       → Start dev server (http://localhost:3000)"
echo "  npm run build     → Production build"
echo "  npm run lint      → Check code quality"
echo ""
