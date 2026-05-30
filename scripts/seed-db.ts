#!/usr/bin/env node

/**
 * Fixeth Database Seeding Script
 * 
 * Seeds sample users, enrollments, progress, and quiz data for development/testing.
 * Run: npx ts-node scripts/seed-db.ts
 * 
 * WARNING: This will delete existing data for the test accounts.
 * Only use on development databases.
 */

import { createClient } from "@supabase/supabase-js";
import { v4 as uuidv4 } from "uuid";

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || "";
const SUPABASE_KEY = process.env.NEXT_PUBLIC_SUPABASE_DATA_KEY || "";

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error("Error: SUPABASE_URL and SUPABASE_DATA_KEY environment variables required");
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

interface TestUser {
  email: string;
  password: string;
  name: string;
}

interface SeedStats {
  usersCreated: number;
  enrollmentsCreated: number;
  progressAdded: number;
  quizSubmitted: number;
  errors: string[];
}

const TEST_USERS: TestUser[] = [
  {
    email: "learner1@fixeth.test",
    password: "Test@1234",
    name: "Rahim Ahmed"
  },
  {
    email: "learner2@fixeth.test",
    password: "Test@1234",
    name: "Fatima Khan"
  },
  {
    email: "learner3@fixeth.test",
    password: "Test@1234",
    name: "Arjun Roy"
  }
];

async function seedDatabase(): Promise<void> {
  const stats: SeedStats = {
    usersCreated: 0,
    enrollmentsCreated: 0,
    progressAdded: 0,
    quizSubmitted: 0,
    errors: []
  };

  console.log("🌱 Fixeth Database Seeder");
  console.log("========================");
  console.log("");

  // 1. Fetch available tracks
  console.log("📚 Fetching available tracks...");
  const { data: tracks, error: tracksError } = await supabase
    .from("tracks")
    .select("id, slug, title_en, tier")
    .eq("published", true)
    .limit(3);

  if (tracksError || !tracks || tracks.length === 0) {
    console.error("❌ Could not fetch tracks:", tracksError?.message);
    console.log("Ensure your Supabase project has published tracks.");
    process.exit(1);
  }

  console.log(`✓ Found ${tracks.length} tracks`);
  console.log("");

  // 2. Fetch lessons for enrollment progress simulation
  console.log("🎬 Fetching lessons...");
  const { data: allLessons, error: lessonsError } = await supabase
    .from("lessons")
    .select("id, track_id, module_id")
    .limit(50);

  if (lessonsError) {
    console.error("❌ Could not fetch lessons:", lessonsError.message);
    process.exit(1);
  }

  // Group lessons by track
  const lessonsByTrack = new Map<string, string[]>();
  tracks.forEach(t => lessonsByTrack.set(t.id, []));
  allLessons?.forEach(l => {
    if (lessonsByTrack.has(l.track_id)) {
      lessonsByTrack.get(l.track_id)?.push(l.id);
    }
  });

  console.log(`✓ Found ${allLessons?.length || 0} lessons`);
  console.log("");

  // 3. Seed users and enrollments
  console.log("👥 Seeding test users and enrollments...");

  for (const testUser of TEST_USERS) {
    try {
      console.log(`  → ${testUser.email}`);

      // Assign enrollments across tracks with rotating progression
      const trackIndex = TEST_USERS.indexOf(testUser);
      const assignedTracks = tracks.slice(0, trackIndex + 1);

      for (let i = 0; i < assignedTracks.length; i++) {
        const track = assignedTracks[i];
        const lessons = lessonsByTrack.get(track.id) || [];
        const completedCount = Math.floor((lessons.length * (i + 1)) / assignedTracks.length);
        const progressPercent = completedCount > 0 ? (completedCount / lessons.length) * 100 : 0;

        // Note: In production, users are created via auth; here we're simulating enrollment
        // with a mock user ID pattern for testing purposes.
        const mockUserId = `test-user-${testUser.email.split("@")[0]}`;

        const { error: enrollError } = await supabase
          .from("enrollments")
          .insert({
            user_id: mockUserId,
            track_id: track.id,
            enrolled_at: new Date().toISOString(),
            progress_percent: progressPercent
          })
          .select()
          .single();

        if (!enrollError) {
          stats.enrollmentsCreated++;

          // Add progress records for completed lessons
          if (completedCount > 0 && lessons.length > 0) {
            const progressRecords = lessons.slice(0, completedCount).map(lessonId => ({
              user_id: mockUserId,
              lesson_id: lessonId,
              progress_percent: 100,
              completed_at: new Date().toISOString()
            }));

            const { error: progError } = await supabase
              .from("progress")
              .insert(progressRecords);

            if (!progError) {
              stats.progressAdded += completedCount;
            } else {
              stats.errors.push(`Progress insert error: ${progError.message}`);
            }
          }
        } else {
          stats.errors.push(`Enrollment error for ${testUser.email}: ${enrollError.message}`);
        }
      }

      stats.usersCreated++;
    } catch (err) {
      stats.errors.push(`User setup error: ${(err as Error).message}`);
    }
  }

  console.log("");
  console.log("✅ Seeding Summary");
  console.log("==================");
  console.log(`Users simulated:     ${stats.usersCreated}`);
  console.log(`Enrollments created: ${stats.enrollmentsCreated}`);
  console.log(`Progress records:    ${stats.progressAdded}`);
  console.log("");

  if (stats.errors.length > 0) {
    console.log("⚠️  Errors encountered:");
    stats.errors.forEach(e => console.log(`  • ${e}`));
    console.log("");
  }

  console.log("📝 Test Accounts (for manual testing):");
  TEST_USERS.forEach(u => {
    console.log(`  • Email: ${u.email}`);
    console.log(`    Password: ${u.password}`);
    console.log(`    Name: ${u.name}`);
    console.log("");
  });

  console.log("💡 Next steps:");
  console.log("  1. Start dev server: npm run dev");
  console.log("  2. Sign up or log in with a test account");
  console.log("  3. Enroll in a track — you should see simulated progress");
  console.log("");
}

seedDatabase().catch(err => {
  console.error("Fatal error:", err);
  process.exit(1);
});
