# Fixeth Scripts Guide

This document describes all automation scripts available for development, testing, and deployment of the Fixeth learning platform.

## Quick Start

For first-time setup:

```bash
npm run dev:setup    # Quick developer setup (creates .env.local, installs deps)
npm run dev          # Start the development server
```

For a more comprehensive setup (with type checking and validation):

```bash
npm run setup        # Full setup with environment verification
npm run dev
```

---

## Available Scripts

### Development

#### `npm run dev`
Start the Next.js development server with hot module replacement (HMR).

```bash
npm run dev
# Opens http://localhost:3000
```

**Features:**
- Automatic code recompilation on file changes
- Real-time browser refresh (HMR)
- TypeScript type checking in the background
- Supabase local emulation (if configured)

---

#### `npm run dev:setup`
Quick developer setup for local development environment.

**Location:** `scripts/dev-setup.sh`

```bash
npm run dev:setup
```

**What it does:**
- Installs dependencies via npm/pnpm
- Creates `.env.local` with minimal configuration for local testing
- Runs TypeScript type check
- Provides instructions for enabling AI features (Chat-with-Video, AI Mentor)

**When to use:**
- First time cloning the repository
- When you need a fresh development environment
- Before starting work on a feature

---

#### `npm run setup`
Complete environment setup with full validation.

**Location:** `scripts/setup.sh`

```bash
npm run setup
```

**What it does:**
- Verifies Node.js version (requires >= 20.9.0)
- Installs dependencies with your package manager (pnpm/yarn/npm)
- Creates `.env.local` from template
- Tests Supabase REST API connection
- Runs full TypeScript type check
- Guides through optional database migration setup

**When to use:**
- Initial project setup in a new environment
- Before deploying to production
- Troubleshooting environment issues

**Output example:**
```
==================================================
  Fixeth — Project Setup
==================================================

[1/6] Checking Node.js version...
✓ Node.js v20.10.0 (required: >= 20.9.0)

[2/6] Installing dependencies...
...
✓ Dependencies installed

[3/6] Checking environment variables...
→ .env.local already exists

[4/6] Verifying Supabase connection...
✓ Supabase connection successful

[5/6] Running TypeScript type check...
✓ Type check passed

[6/6] Database readiness
...
```

---

### Building & Testing

#### `npm run build`
Create an optimized production build.

```bash
npm run build
```

Generates:
- `.next/` directory with compiled code
- Optimized bundle analysis
- Type checking during build

#### `npm run start`
Run the production server locally.

```bash
npm run build
npm run start
```

Opens http://localhost:3000 with the production build.

#### `npm run lint`
Check code quality and style compliance.

```bash
npm run lint
```

Runs ESLint on TypeScript/JavaScript files. Fix automatically:

```bash
npm run lint -- --fix
```

#### `npm run type-check`
Perform TypeScript type checking without running the dev server.

```bash
npm run type-check
```

Useful for CI/CD pipelines and pre-commit hooks.

---

### Database & Data

#### `npm run seed`
Populate the database with sample data for development and testing.

**Location:** `scripts/seed-db.ts`

```bash
npm run seed
```

**What it does:**
- Creates 3 test user accounts with sample enrollments
- Simulates progress across 3 tracks (Digital Literacy, Git, Data Science)
- Adds progress records for completed lessons
- Generates quiz submission data

**Generated test accounts:**
```
Email: learner1@fixeth.test | Name: Rahim Ahmed
Email: learner2@fixeth.test | Name: Fatima Khan
Email: learner3@fixeth.test | Name: Arjun Roy
Password: Test@1234 (all accounts)
```

**When to use:**
- Setting up a fresh development database
- Testing enrollment flows
- Verifying progress tracking functionality
- Before demoing to stakeholders

**Prerequisites:**
- `.env.local` must have Supabase credentials
- Supabase project must have published tracks and lessons

---

#### `npm run migrate:apply`
Apply pending database migrations to your Supabase project.

**Location:** `scripts/migrate.sh`

```bash
npm run migrate:apply
```

**Prerequisites:**
- Supabase CLI installed: `npm install -g supabase`
- Logged into Supabase: `supabase login`
- `.env.local` has `NEXT_PUBLIC_SUPABASE_URL` set

**What it does:**
- Reads SQL files from `supabase/migrations/`
- Applies unapplied migrations in order
- Creates schema (tables, RLS policies, functions)
- Seeds initial data if specified

**Common migrations:**
```
✓ 20250527_init_schema.sql        — Core tables (tracks, lessons, users, progress)
✓ 20250528_users_rls.sql          — Row-level security policies
✓ 20250602_notebooks_and_publish.sql — Notebooks table + Git course publish
```

**When to use:**
- Initial database setup
- After pulling schema changes from git
- When adding new migrations

#### `npm run migrate:status`
Check which migrations have been applied.

```bash
npm run migrate:status
```

Output example:
```
Migration status:
✓ 20250527_init_schema.sql
✓ 20250528_users_rls.sql
✓ 20250602_notebooks_and_publish.sql
```

#### `npm run migrate:reset`
Destructively reset and re-apply all migrations.

```bash
npm run migrate:reset
```

⚠️ **WARNING:** This deletes all data. Only use on development databases.

Prompts for confirmation:
```
⚠️  WARNING: This will reset your database and re-apply all migrations!
    All data will be lost.
Type 'yes' to confirm:
```

---

## Environment Variables

Both setup scripts create `.env.local` with templates. Key variables:

```env
# Essential for development
NEXT_PUBLIC_SUPABASE_URL=https://oxfynuytsnifqqhbmpcv.supabase.co
NEXT_PUBLIC_SUPABASE_DATA_KEY=...

# AI features (Chat-with-Video, AI Mentor)
NEXT_PUBLIC_GEMINI_API_KEY=your_api_key_here
NEXT_PUBLIC_OPENAI_API_KEY=optional

# GitHub Codespace feature
GITHUB_PAT_TOKEN=your_pat_here

# Development server
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

Get free API keys:
- **Gemini:** https://ai.google.dev/gemini-api
- **OpenAI:** https://platform.openai.com/api-keys
- **GitHub PAT:** https://github.com/settings/personal-access-tokens

---

## Workflow Examples

### Fresh Clone → Fully Set Up

```bash
git clone https://github.com/jawatalsovon/Fixeth.git
cd Fixeth
npm run setup         # Complete setup
npm run seed          # Add test data
npm run dev           # Start development server
```

### Feature Development (changes to features)

```bash
npm run type-check    # Verify no type errors
npm run lint          # Check code style
npm run dev           # Test in browser
```

### Before Committing

```bash
npm run lint -- --fix  # Auto-fix style issues
npm run type-check     # Verify types
npm run build          # Test production build
git add .
git commit -m "feat: ..."
```

### Debugging Database Issues

```bash
npm run migrate:status   # Check applied migrations
npm run migrate:reset    # Reset and re-seed
npm run seed             # Re-add test data
```

### CI/CD Pipeline (GitHub Actions, Vercel)

```bash
npm ci                 # Clean install
npm run type-check     # Type validation
npm run lint           # Code quality
npm run build          # Production build
npm start              # Health check
```

---

## Troubleshooting

### `npm run setup` fails with "Node version too old"

```bash
node -v  # Check your version
# If < 20.9.0, upgrade from https://nodejs.org
nvm install 20         # Or: nvm install node (latest)
nvm use 20
npm run setup
```

### Supabase connection fails

```bash
# Check credentials in .env.local
echo $NEXT_PUBLIC_SUPABASE_URL
echo $NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY

# Test manually
curl -s "$NEXT_PUBLIC_SUPABASE_URL/rest/v1/tracks?limit=1" \
  -H "apikey: $NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY"
# Should return HTTP 200 + JSON
```

### `npm run seed` doesn't work

```bash
# Ensure Supabase credentials are loaded
source .env.local

# Check that Supabase project has tracks
npm run migrate:apply   # Apply schema first
npm run seed
```

### TypeScript errors in dev server

```bash
npm run type-check     # See detailed error list
# Or in VSCode: Ctrl+Shift+B → "build" to show problems panel
```

---

## Scripts Architecture

```
scripts/
├── setup.sh           # Full setup with validation (bash)
├── dev-setup.sh       # Quick dev setup (bash)
├── seed-db.ts         # Database seeding (TypeScript)
└── migrate.sh         # Database migrations (bash)
```

All scripts:
- Exit on first error (`set -e`)
- Use color output for clarity
- Provide helpful error messages
- Support offline operation (except database scripts)

---

## Contributing New Scripts

When adding a new script:

1. Place in `scripts/` with appropriate extension (`.sh` for bash, `.ts` for TypeScript)
2. Add shebang and descriptive header comment
3. Include usage examples in comments
4. Add npm script entry to `package.json`
5. Document in this file with examples and prerequisites
6. Make executable: `chmod +x scripts/your-script.sh`

---

## References

- **Setup Guide:** `README.md` → Getting Started
- **Architecture:** `plan.md` → AI-Native Architecture
- **Database Schema:** `supabase/migrations/`
- **Troubleshooting:** See above "Troubleshooting" section
