#!/bin/bash

# Fixeth Database Migration Runner
# Applies SQL migrations from supabase/migrations/ to your Supabase project
# 
# Prerequisites:
#   - Supabase CLI installed: https://supabase.com/docs/guides/cli
#   - You're logged in: supabase login
#   - .env.local has NEXT_PUBLIC_SUPABASE_URL set
#
# Usage:
#   ./scripts/migrate.sh apply    → Apply pending migrations
#   ./scripts/migrate.sh status   → Show migration status
#   ./scripts/migrate.sh reset    → Reset and re-apply all migrations (⚠️ destructive!)

set -e

MIGRATION_DIR="supabase/migrations"

if [ ! -d "$MIGRATION_DIR" ]; then
    echo "Error: $MIGRATION_DIR not found"
    exit 1
fi

# Load Supabase project ref from .env.local (if available)
if [ -f .env.local ]; then
    # Extract project ID from URL (e.g., oxfynuytsnifqqhbmpcv from URL)
    SUPABASE_URL=$(grep NEXT_PUBLIC_SUPABASE_URL .env.local | cut -d'=' -f2 | xargs)
    SUPABASE_PROJECT=$(echo "$SUPABASE_URL" | sed 's|.*//\([^.]*\).*|\1|')
fi

if [ -z "$SUPABASE_PROJECT" ]; then
    echo "Error: Could not determine Supabase project. Set NEXT_PUBLIC_SUPABASE_URL in .env.local"
    exit 1
fi

echo "Fixeth Database Migration Runner"
echo "================================="
echo "Project: $SUPABASE_PROJECT"
echo ""

# Check if supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "Error: Supabase CLI not found. Install it:"
    echo "  npm install -g supabase"
    exit 1
fi

case "${1:-help}" in
    apply)
        echo "Applying pending migrations..."
        supabase migration up --project-ref "$SUPABASE_PROJECT"
        echo "✓ Migrations applied"
        ;;
    status)
        echo "Migration status:"
        supabase migration list --project-ref "$SUPABASE_PROJECT"
        ;;
    reset)
        echo "⚠️  WARNING: This will reset your database and re-apply all migrations!"
        echo "    All data will be lost."
        read -p "Type 'yes' to confirm: " confirm
        if [ "$confirm" = "yes" ]; then
            supabase migration down --project-ref "$SUPABASE_PROJECT" --all
            supabase migration up --project-ref "$SUPABASE_PROJECT"
            echo "✓ Database reset and re-migrated"
        else
            echo "Cancelled."
        fi
        ;;
    *)
        echo "Usage: $0 {apply|status|reset}"
        echo ""
        echo "Commands:"
        echo "  apply   - Apply pending migrations to your Supabase project"
        echo "  status  - Show which migrations have been applied"
        echo "  reset   - Destructively reset all migrations (⚠️ deletes all data)"
        exit 1
        ;;
esac
