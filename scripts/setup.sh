#!/bin/bash

# Fixeth Setup Script
# Complete environment setup, dependency installation, and database initialization
# Usage: ./scripts/setup.sh

set -e

echo "=================================================="
echo "  Fixeth — Project Setup"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check Node.js version
echo -e "${BLUE}[1/6]${NC} Checking Node.js version..."
NODE_VERSION=$(node -v | cut -d'v' -f2)
REQUIRED_VERSION="20.9.0"
if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" == "$REQUIRED_VERSION" ]]; then
    echo -e "${GREEN}✓${NC} Node.js v$NODE_VERSION (required: >= $REQUIRED_VERSION)"
else
    echo -e "${RED}✗${NC} Node.js v$NODE_VERSION is too old. Please upgrade to >= $REQUIRED_VERSION"
    exit 1
fi

# Install dependencies
echo ""
echo -e "${BLUE}[2/6]${NC} Installing dependencies..."
if command -v pnpm &> /dev/null; then
    echo -e "${YELLOW}→${NC} Using pnpm"
    pnpm install
elif command -v yarn &> /dev/null; then
    echo -e "${YELLOW}→${NC} Using yarn"
    yarn install
else
    echo -e "${YELLOW}→${NC} Using npm"
    npm install
fi
echo -e "${GREEN}✓${NC} Dependencies installed"

# Create .env.local from template
echo ""
echo -e "${BLUE}[3/6]${NC} Checking environment variables..."
if [ ! -f .env.local ]; then
    echo -e "${YELLOW}→${NC} .env.local not found. Creating from template..."
    cat > .env.local << 'EOF'
# Auth & NextAuth
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your_nextauth_secret_here

# OAuth Providers (optional for local dev)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GITHUB_CLIENT_ID=
GITHUB_CLIENT_SECRET=
LINKEDIN_CLIENT_ID=
LINKEDIN_CLIENT_SECRET=

# Supabase (PostgreSQL + Auth)
NEXT_PUBLIC_SUPABASE_URL=https://oxfynuytsnifqqhbmpcv.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=sb_publishable_ATVf_la2Z6kuYO3rp1MIyg_SnBm0Snd
NEXT_PUBLIC_SUPABASE_DATA_URL=https://oxfynuytsnifqqhbmpcv.supabase.co
NEXT_PUBLIC_SUPABASE_DATA_KEY=sb_publishable_ATVf_la2Z6kuYO3rp1MIyg_SnBm0Snd

# AI Services (BYOA — Bring Your Own API Key)
NEXT_PUBLIC_GEMINI_API_KEY=
NEXT_PUBLIC_ANTHROPIC_API_KEY=
NEXT_PUBLIC_OPENAI_API_KEY=

# GitHub (for Codespace feature)
GITHUB_PAT_TOKEN=

# Services
YOUTUBE_API_KEY=
OPENAI_API_KEY=
JUDGE0_API_URL=
JUDGE0_API_TOKEN=

# Payment Providers (optional)
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
SSLCOMMERZ_STORE_ID=
SSLCOMMERZ_STORE_PASSWORD=

# Email
RESEND_API_KEY=

# App Config
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_ENV=development
EOF
    echo -e "${YELLOW}→${NC} Created .env.local. Please fill in your API keys."
    echo -e "${YELLOW}→${NC} At minimum, you need Supabase credentials to get started."
else
    echo -e "${GREEN}✓${NC} .env.local already exists"
fi

# Check Supabase connection
echo ""
echo -e "${BLUE}[4/6]${NC} Verifying Supabase connection..."
if [ -z "$NEXT_PUBLIC_SUPABASE_URL" ]; then
    source .env.local
fi

if [ ! -z "$NEXT_PUBLIC_SUPABASE_URL" ] && [ ! -z "$NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY" ]; then
    echo -e "${YELLOW}→${NC} Testing Supabase REST API..."
    SUPABASE_TEST=$(curl -s -o /dev/null -w "%{http_code}" \
        "$NEXT_PUBLIC_SUPABASE_URL/rest/v1/tracks?limit=1" \
        -H "apikey: $NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY")
    
    if [ "$SUPABASE_TEST" == "200" ]; then
        echo -e "${GREEN}✓${NC} Supabase connection successful"
    else
        echo -e "${YELLOW}⚠${NC} Supabase returned HTTP $SUPABASE_TEST (check credentials)"
    fi
else
    echo -e "${YELLOW}⚠${NC} Supabase credentials not configured. Add to .env.local to continue."
fi

# TypeScript type check
echo ""
echo -e "${BLUE}[5/6]${NC} Running TypeScript type check..."
npx tsc --noEmit
echo -e "${GREEN}✓${NC} Type check passed"

# Database migrations (optional — requires Supabase admin access)
echo ""
echo -e "${BLUE}[6/6]${NC} Database readiness"
echo -e "${YELLOW}→${NC} Run migrations manually (if you have admin access):"
echo -e "${YELLOW}→${NC} \$ npm run migrate:apply"
echo -e "${YELLOW}→${NC} Or visit Supabase SQL Editor to run migrations from supabase/migrations/"

echo ""
echo -e "${GREEN}=================================================="
echo "  Setup complete! 🚀"
echo "=================================================="
echo ""
echo "Next steps:"
echo "  1. Fill in API keys in .env.local (at minimum: Supabase, Gemini/OpenAI for AI Mentor)"
echo "  2. Start dev server:  npm run dev"
echo "  3. Open http://localhost:3000"
echo ""
echo "Features require:"
echo "  • Gemini/OpenAI API key → Chat-with-Video & AI Mentor"
echo "  • GitHub PAT → Codespace feature"
echo "  • YouTube API key → Video metadata (optional)"
echo ""
