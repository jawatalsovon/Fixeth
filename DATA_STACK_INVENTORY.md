# Fixeth — Data Lifecycle & Engineering Stack

## 1. Data Sources
- **Internal (own DB / app data)** ✓
  - Supabase PostgreSQL: curriculum (tracks, modules, lessons), user accounts, enrollments, progress tracking, transcript chunks
  - Real-time user learning data: quiz attempts, lesson completion, engagement metrics
  
- **User Uploads / Bulk Import** ✓
  - Notebook files (Python code) created and saved via Pyodide
  - GitHub repo access (via Personal Access Token)

- **Synthetic / AI-generated Data** ✓
  - AI Mentor responses (via BYOA Gemini/Ollama)
  - Chat-with-Video answers with `[ts:MM:SS]` markers
  - Quiz questions (implied generation from lesson content)

- **Streaming / Live Data** ✓
  - YouTube video playback events (iframe postMessage)
  - Supabase Realtime for potential live curriculum updates

---

## 2. Acquisition Methods
- **API Pull / SDK integrations** ✓
  - Supabase client (`@supabase/supabase-js`) for curriculum, enrollments, progress
  - GitHub REST API client for repo/file access
  - YouTube IFrame API for playback events
  
- **Web Scrapers** ✓
  - Playwright (in dependencies) — not actively used but available for future web scraping

- **AI Extraction** ✓
  - LLM-based transcript parsing and enhancement (Gemini/Ollama)

---

## 3. Parsing, Formats & Cleaning
- **JSON** ✓
  - REST API responses from Supabase and GitHub
  - Type-validated payloads via TypeScript

- **Markdown** ✓
  - Lesson notes stored and rendered (`lesson_notes` column)
  - Clean, structured documentation

- **HTML** ✓
  - YouTube iframe embedding (`<iframe enablejsapi=1>`)
  - Rendered from Markdown lesson content

- **Video** ✓
  - YouTube video URLs indexed in `lessons.youtube_video_id`
  - Real-time seek/playback via IFrame API

- **Audio / Speech** ✓
  - Transcript chunks (`transcript_chunks` table) — derived from video via speech-to-text (upstream)
  - Timestamped segments with `[ts:MM:SS]` markers

- **Schema Validation** ✓
  - TypeScript types (`types/ui.ts`, `types/index.ts`) for all domain models
  - Supabase RLS policies + type-safe client

---

## 4. Storage Targets
- **Relational (PostgreSQL)** ✓
  - Supabase PostgreSQL with full schema:
    - `users` (auth identity)
    - `tracks` (courses with tier 1/2/3)
    - `modules`, `lessons` (curriculum hierarchy)
    - `enrollments` (user progress per track, `progress_percent`)
    - `progress` (per-lesson completion with timestamps)
    - `transcript_chunks` (indexed, with RLS)
    - `quiz_items` (questions per lesson)
    - `notebooks` (user-created Python notebooks)
    - `chat_messages` (optional for AI Mentor history)

- **Vector DB (pgvector)** ✓
  - `transcript_chunks.embedding` — 1536-dim vectors for semantic search
  - IVFFlat index with cosine similarity (`vector_cosine_ops`)
  - Custom RPC: `match_transcript_chunks()` for similarity-based retrieval

- **Cache / KV** ✓
  - Browser `sessionStorage` for UI state (preferences, theme, current track)
  - Session-based auth tokens via Supabase SSR

---

## 5. Visualization
- **Chart.js / Recharts** ✓
  - Progress dashboards (enrollment `progress_percent` tracking)
  - Tier-based achievement badges and certificates
  
- **Interactive UI** ✓
  - Real-time video transcript with clickable `[ts:MM:SS]` seek chips
  - Live lesson progress bar with duration sync

---

## 6. Insights — AI, ML & Non-AI
- **LLM Inference / RAG** ✓
  - Chat-with-Video: Retrieval from `transcript_chunks` → AI response with exact `[ts:MM:SS]` citations
  - AI Mentor: Full-transcript context + conversation history → adaptive tutor responses
  - BYOA model selection: Gemini 2.5 Flash, Pro, Flash-Lite, or local Ollama

- **Clustering / Segmentation** ✓
  - Tier-based UI progression (Tier 1: video/quiz; Tier 2: +submissions/mentor; Tier 3: +notebook/codespace)
  - User segmentation by `enrollments.tier` and `progress_percent`

- **Statistical Analysis** ✓
  - Progress tracking with completion timestamps
  - Enrollment health metrics: `progress_percent` per learner
  - Quiz performance data (from `quiz_items`)

- **Anomaly Detection** ✓
  - Stale progress detection (no completion updates in X days)
  - Quiz failure patterns (tracking retry counts)

---

## 7. Pipelines & Orchestration
- **Scheduling / Triggers** ✓
  - Server Actions: `markLessonComplete()` → upserts `progress` and recalculates `enrollments.progress_percent`
  - Webhook-ready schema for future external triggers

- **Streaming / Real-time** ✓
  - Supabase Realtime subscriptions ready (curriculum, enrollments, progress)
  - YouTube IFrame postMessage events for playback sync

- **Event-Driven Updates** ✓
  - Lesson completion → progress write + enrollment % update (transactional)
  - Chat message → AI inference → response append

---

## 8. Outbound — APIs & Distribution
- **REST APIs** ✓
  - Supabase PostgREST auto-generated endpoints
  - `GET /rest/v1/tracks`, `/lessons`, `/transcript_chunks`, etc.
  - Authentication via JWT (Supabase auth)

- **Embeddings / Model Serving** ✓
  - BYOA Gemini API inference (client-side via byoa.ts)
  - Ollama local inference support
  - Custom RPC for pgvector similarity search

- **Webhooks & Exports** ✓
  - Schema supports outbound webhook payloads (future)
  - Progress export as JSON/CSV via client-side download
  - Notebook export as `.ipynb` format

---

## 9. Open Source Stack
- **PostgreSQL + Supabase**
  - Relational DB engine, PostgREST, pgvector extension, RLS policies
  - Role: Curriculum, user data, progress tracking, embeddings storage

- **Next.js 16 + React 19**
  - Full-stack JavaScript framework with App Router
  - Role: Frontend UI, server actions, API routes, auth middleware

- **TypeScript**
  - Type-safe client/server code, schema validation
  - Role: Data integrity, developer confidence, IDE support

- **Tailwind CSS + shadcn**
  - Utility-first CSS framework + component library
  - Role: Responsive UI, accessible components

- **Pyodide (Python in WASM)**
  - In-browser Python interpreter
  - Role: Real Jupyter notebook execution (no backend needed)

- **Playwright**
  - Browser automation library (in deps, extensible for web scraping)
  - Role: Future data acquisition, automated testing

- **Vercel AI SDK + Anthropic/OpenAI clients**
  - Unified AI inference interface
  - Role: LLM calls, streaming responses, model routing

- **next-intl**
  - i18n framework for multi-language support (English + Bengali)
  - Role: Localized curriculum, UI text, AI responses

---

## 10. Quality, Governance & Observability
- **Data Quality** ✓
  - Lesson completion validation (requires active enrollment)
  - Progress integrity checks (no future-dated completions)
  - Transcript chunk availability checks before chat

- **Privacy & Compliance** ✓
  - Supabase Row-Level Security (RLS) on all user-scoped tables
  - Auth-required endpoints (no unauthenticated data access)
  - PII handling: email + hashed passwords via Supabase Auth
  - GDPR-ready: user deletion cascades through enrollments/progress

- **Lineage & Observability** ✓
  - Audit trail: `progress.created_at`, `progress.updated_at` timestamps
  - User journey tracking: enrollment → lesson → completion → tutor interaction
  - Error logging: AI inference failures with user-facing explanations

- **Cost & Performance** ✓
  - Lazy loading: transcript chunks only fetched when video starts
  - Efficient pgvector queries: IVFFlat index, cosine similarity
  - Caching: sessionStorage for user prefs, browser HTTP cache for static assets
  - BYOA model routing: users choose cost-efficient models (Gemini Flash-Lite for free tier)

---

## 11. Architecture Highlights
- **AI-Native Data Flow**
  - User question → Full transcript context (RAG) → LLM inference → Exact `[ts:MM:SS]` citations
  - Adaptive tutor: cognitive-level persona selection → context-aware responses

- **Real-Time Learning**
  - Video playback position → Transcript segment highlighting
  - Lesson completion → Enrollment % update (visible immediately)

- **Multi-Tier Progression**
  - Data-driven UX: curriculum scope varies by `enrollments.tier`
  - Leaderboard-ready: `enrollments.progress_percent` sortable, comparableone

- **Extensibility**
  - Custom RPC for pgvector: `match_transcript_chunks(query_embedding, match_threshold)`
  - Webhook schema ready: outbound events (completion, quiz submit)
  - MCP-ready: expose data as custom MCP server (future)

---

## Summary
Fixeth demonstrates a **full AI-native data stack** spanning:
- **Sources:** Internal (PostgreSQL), user notebooks, YouTube, AI-generated
- **Acquisition:** APIs, web scraping (Playwright), LLM extraction
- **Storage:** PostgreSQL + pgvector RAG, sessionStorage cache
- **Insights:** LLM+RAG chat-with-video, adaptive tutor, progress analytics
- **Pipelines:** Event-driven (lesson → progress → enrollment %), real-time ready
- **Outbound:** REST API, embedding inference, webhook-ready schema
- **Governance:** RLS-protected, audit trails, GDPR-compliant

**Stack:** PostgreSQL, Supabase, Next.js, React, TypeScript, Pyodide, Vercel AI SDK, Tailwind, next-intl, Playwright
