# Graph Report - zenit  (2026-09-28)

## Corpus Check
- 149 files · ~374,255 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 58 file(s) not represented in the graph (top: (none) 13, .xcconfig 8, .xml 7)

## Summary
- 1311 nodes · 1653 edges · 117 communities (70 shown, 47 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 17 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `245c83be`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- Win32Window
- GeneratedPluginRegistrant.swift
- report_creation_screen.dart
- package:flutter_test/flutter_test.dart
- complaint.dart
- geo_utils.dart
- my_application.cc
- municipality_profile_screen.dart
- app_constants.dart
- municipality.dart
- mock_municipality_repository.dart
- main_nav_screen.dart
- complaintRepositoryProvider
- complaint_detail_screen.dart
- app_colors.dart
- string
- 20260927000000_create_seffaf_schema.sql
- map_screen.dart
- offline_sync_controller.dart
- mock_complaint_repository.dart
- feed_controller.dart
- complaint_card.dart
- supabase_complaint_repository.dart
- profile_screen.dart
- leaderboard_screen.dart
- onboarding_screen.dart
- app_theme.dart
- mock_auth_repository.dart
- What You Must Do When Invoked
- login_screen.dart
- complaint_repository.dart
- register_screen.dart
- supabase_auth_repository.dart
- Supabase
- category_defaults.dart
- supabase_config.dart
- auth_repository.dart
- manifest.json
- windows/flutter/generated_plugin_registrant.cc
- providers.dart
- package:flutter/material.dart
- ConsumerState
- StatelessWidget
- MaterialPageRoute
- seffaf_logo.dart
- empty_state_widget.dart
- authRepositoryProvider
- 20260928000000_auto_confirm_users.sql
- Changelog
- main.dart
- seffaf_image.dart
- MainActivity.kt
- Changelog
- Writing Guidelines for Postgres References
- home_samet_projeler_zenit_ios_runner_generatedpluginregistrant_h
- String?
- ✨ Temel Özellikler
- Section Definitions
- graphify reference: extra exports and benchmark
- 🧠 AGENTS.md — Proje Hafızası ve Geliştirici Kılavuzu
- graphify reference: query, path, explain
- Supabase Postgres Best Practices
- date_formatter.dart
- graphify reference: add a URL and watch a folder
- graphify reference: commit hook and native CLAUDE.md integration
- graphify reference: incremental update and cluster-only
- graphify reference: GitHub clone and cross-repo merge
- graphify reference: transcribe video and audio
- rules/graphify.md
- extraction-spec.md
- advanced-full-text-search.md
- advanced-jsonb-indexing.md
- conn-idle-timeout.md
- conn-limits.md
- conn-pooling.md
- conn-prepared-statements.md
- data-batch-inserts.md
- data-n-plus-one.md
- data-pagination.md
- data-upsert.md
- lock-advisory.md
- lock-deadlock-prevention.md
- lock-short-transactions.md
- lock-skip-locked.md
- monitor-explain-analyze.md
- monitor-pg-stat-statements.md
- monitor-vacuum-analyze.md
- query-composite-indexes.md
- query-covering-indexes.md
- query-index-types.md
- query-missing-indexes.md
- query-partial-indexes.md
- schema-constraints.md
- schema-data-types.md
- schema-foreign-key-indexes.md
- schema-lowercase-identifiers.md
- schema-partitioning.md
- schema-primary-keys.md
- security-privileges.md
- security-rls-basics.md
- security-rls-performance.md
- _template.md
- workflows/graphify.md
- LaunchImage.imageset/README.md
- feed_screen.dart
- comment.dart
- full_screen_image_viewer.dart
- status_badge.dart
- ComplaintCard
- package:flutter_riverpod/flutter_riverpod.dart
- ComplaintRepository

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 24 edges
2. `complaintRepositoryProvider` - 24 edges
3. `currentUserProvider` - 20 edges
4. `feedControllerProvider` - 13 edges
5. `What You Must Do When Invoked` - 12 edges
6. `MessageHandler` - 12 edges
7. `public.complaints` - 11 edges
8. `authRepositoryProvider` - 11 edges
9. `/graphify` - 10 edges
10. `FlutterWindow` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Win32Window::Win32Window()` --calls--> `Destroy`  [INFERRED]
  windows/runner/win32_window.cpp → windows/runner/win32_window.h
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows/runner/main.cpp → windows/runner/utils.cpp
- `OnCreate` --calls--> `RegisterPlugins()`  [INFERRED]
  windows/runner/flutter_window.h → windows/flutter/generated_plugin_registrant.cc
- `build` --references--> `themeModeProvider`  [EXTRACTED]
  lib/features/profile/presentation/profile_screen.dart → lib/main.dart
- `_ProfileScreenState` --references--> `themeModeProvider`  [EXTRACTED]
  lib/features/profile/presentation/profile_screen.dart → lib/main.dart

## Import Cycles
- None detected.

## Communities (117 total, 47 thin omitted)

### Community 0 - "Win32Window"
Cohesion: 0.05
Nodes (59): dwmapi, FlutterViewController, generated_plugin_registrant, optional, RECT, unique_ptr, DartProject, HWND (+51 more)

### Community 1 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.05
Nodes (35): Any, app_links, Cocoa, connectivity_plus, file_selector_macos, Flutter, flutter_image_compress_macos, FlutterAppDelegate (+27 more)

### Community 2 - "report_creation_screen.dart"
Cohesion: 0.07
Nodes (28): ../../../core/network/offline_manager.dart, _address, build, _buildStep1PhotosAndCategory, _buildStep2LocationAndMunicipality, _buildStep3Details, _buildStep4PreviewAndSubmit, _buildStepIndicator (+20 more)

### Community 3 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.15
Nodes (13): package:flutter_test/flutter_test.dart, package:seffaf/core/utils/geo_utils.dart, package:seffaf/core/utils/scoring_calculator.dart, package:seffaf/data/models/complaint.dart, package:seffaf/data/models/complaint_status.dart, package:seffaf/data/repositories/mock_municipality_repository.dart, package:seffaf/features/auth/presentation/login_screen.dart, package:seffaf/features/auth/presentation/register_screen.dart (+5 more)

### Community 4 - "complaint.dart"
Cohesion: 0.05
Nodes (38): complaint_status.dart, address, anonymousUserId, anonymousUserName, averageRating, categoryId, commentCount, confirmCount (+30 more)

### Community 5 - "geo_utils.dart"
Cohesion: 0.05
Nodes (36): ../constants/app_constants.dart, ../constants/category_defaults.dart, dart:convert, dart:math, ../../../data/models/complaint.dart, ../../data/repositories/complaint_repository.dart, getDraftComplaints, isConnected (+28 more)

### Community 6 - "my_application.cc"
Cohesion: 0.08
Nodes (28): file_selector_plugin, FlPluginRegistry, flutter_linux, FlView, GApplication, gboolean, gchar, gdkx (+20 more)

### Community 7 - "municipality_profile_screen.dart"
Cohesion: 0.08
Nodes (26): class, double get, Municipality, _buildStatBox, createState, dispose, initState, isDark (+18 more)

### Community 8 - "app_constants.dart"
Cohesion: 0.07
Nodes (29): AppConstants, appName, appTagline, baseMunicipalityScore, defaultLatitude, defaultLongitude, defaultZoom, keyComplaintRatings (+21 more)

### Community 9 - "municipality.dart"
Cohesion: 0.05
Nodes (39): int?, copyWith, createdComplaintIds, displayName, email, followedMunicipalityIds, fromJson, id (+31 more)

### Community 10 - "mock_municipality_repository.dart"
Cohesion: 0.08
Nodes (25): core/config/supabase_config.dart, ../../../core/utils/geo_utils.dart, _cachedMunicipalities, _cachedProvinces, _ensureLoaded, getLeaderboard, getMunicipalities, getMunicipalityById (+17 more)

### Community 11 - "main_nav_screen.dart"
Cohesion: 0.14
Nodes (13): ../../../core/network/offline_sync_controller.dart, ../feed/presentation/feed_screen.dart, ../leaderboard/presentation/leaderboard_screen.dart, build, _buildCenterActionButton, _buildNavItem, createState, _lastBackPressTime (+5 more)

### Community 12 - "complaintRepositoryProvider"
Cohesion: 0.11
Nodes (28): offlineSyncProvider, syncNow, complaintRepositoryProvider, currentUserProvider, build, _loadComments, _rateComplaint, _sendComment (+20 more)

### Community 13 - "complaint_detail_screen.dart"
Cohesion: 0.08
Nodes (24): ../../../core/utils/date_formatter.dart, ../../../data/models/comment.dart, ../../feed/application/feed_controller.dart, _activePhotoIndex, _buildActionBar, _buildBeforeAfterComparison, _buildMunicipalityResponse, _buildSatisfactionRating (+16 more)

### Community 14 - "app_colors.dart"
Cohesion: 0.08
Nodes (24): accent, accentDark, accentLight, AppColors, backgroundDark, backgroundLight, borderDark, borderLight (+16 more)

### Community 15 - "string"
Cohesion: 0.12
Nodes (19): dart_project, flutter_view_controller, flutter_windows, functional, _In_, _In_opt_, io, iostream (+11 more)

### Community 16 - "20260927000000_create_seffaf_schema.sql"
Cohesion: 0.15
Nodes (19): public, idx_comments_complaint, idx_complaints_author, idx_complaints_created_at, idx_complaints_municipality, idx_complaints_status, idx_disputes_complaint, idx_municipalities_province (+11 more)

### Community 17 - "map_screen.dart"
Cohesion: 0.10
Nodes (20): _allComplaints, build, _buildMapFilterChip, createState, initState, _isLoading, _mapController, MapScreen (+12 more)

### Community 18 - "offline_sync_controller.dart"
Cohesion: 0.11
Nodes (19): dart:async, data/repositories/providers.dart, ../../features/feed/application/feed_controller.dart, build, copyWith, _init, isOnline, isSyncing (+11 more)

### Community 19 - "mock_complaint_repository.dart"
Cohesion: 0.11
Nodes (18): addComment, _cachedComplaints, _commentsByComplaintId, createComplaint, deleteComplaint, _disputes, _ensureLoaded, getComments (+10 more)

### Community 20 - "feed_controller.dart"
Cohesion: 0.11
Nodes (18): build, complaints, copyWith, errorMessage, FeedController, FeedState, hasMore, isLoading (+10 more)

### Community 21 - "complaint_card.dart"
Cohesion: 0.12
Nodes (15): Complaint, build, complaint, createState, icon, iconColor, _isExpanded, label (+7 more)

### Community 22 - "supabase_complaint_repository.dart"
Cohesion: 0.11
Nodes (17): addComment, _applyLocalStateToList, _applyLocalStateToSingle, createComplaint, deleteComplaint, _fallbackRepo, getComments, getComplaintById (+9 more)

### Community 23 - "profile_screen.dart"
Cohesion: 0.12
Nodes (16): ../../../data/models/anonymous_user.dart, ../../../data/models/municipality.dart, ../../feed/presentation/widgets/complaint_card.dart, _buildAuthBanner, _buildOfflineDraftsCard, _buildUserCard, createState, _followedMunicipalities (+8 more)

### Community 24 - "leaderboard_screen.dart"
Cohesion: 0.10
Nodes (20): municipalityRepositoryProvider, _buildRankBadge, createState, dispose, initState, _isLoading, LeaderboardScreen, _LeaderboardScreenState (+12 more)

### Community 25 - "onboarding_screen.dart"
Cohesion: 0.12
Nodes (15): ../../auth/presentation/login_screen.dart, build, color, _completeOnboarding, createState, _currentIndex, description, icon (+7 more)

### Community 26 - "app_theme.dart"
Cohesion: 0.06
Nodes (32): @immutable, AppTheme, bg, _build, categories, copyWith, dark, _darkScheme (+24 more)

### Community 27 - "mock_auth_repository.dart"
Cohesion: 0.13
Nodes (14): addCreatedComplaintId, _cachedUser, clearUserData, getCurrentUser, resetPassword, saveUser, signInWithEmail, signOut (+6 more)

### Community 28 - "What You Must Do When Invoked"
Cohesion: 0.08
Nodes (24): For /graphify add and --watch, For /graphify query, For the commit hook and native CLAUDE.md integration, For --update and --cluster-only, /graphify, Honesty Rules, Interpreter guard for subcommands, Part A - Structural extraction for code files (+16 more)

### Community 29 - "login_screen.dart"
Cohesion: 0.13
Nodes (14): FormState, createState, dispose, _emailController, _errorMessage, _formKey, _isLoading, isModal (+6 more)

### Community 30 - "complaint_repository.dart"
Cohesion: 0.13
Nodes (14): addComment, createComplaint, deleteComplaint, getComments, getComplaintById, getComplaintsByMunicipality, getComplaintsByUser, getFeed (+6 more)

### Community 31 - "register_screen.dart"
Cohesion: 0.13
Nodes (14): build, _confirmPasswordController, createState, dispose, _emailController, _errorMessage, _formKey, _isLoading (+6 more)

### Community 32 - "supabase_auth_repository.dart"
Cohesion: 0.12
Nodes (16): AuthRepository, MockAuthRepository, addCreatedComplaintId, clearUserData, _fallbackRepo, getCurrentUser, resetPassword, saveUser (+8 more)

### Community 33 - "Supabase"
Cohesion: 0.11
Nodes (15): Fix suggestion, Source, What happened, Skill Feedback, Steps, Core Principles, Debugging, Making and Committing Schema Changes (+7 more)

### Community 34 - "category_defaults.dart"
Cohesion: 0.17
Nodes (11): Color, categories, CategoryDefaults, CategoryItem, color, getById, icon, id (+3 more)

### Community 35 - "supabase_config.dart"
Cohesion: 0.17
Nodes (11): defaultAnonKey, initialize, _isInitialized, projectRef, SupabaseConfig, supabaseUrl, package:flutter/foundation.dart, package:supabase_flutter/supabase_flutter.dart (+3 more)

### Community 36 - "auth_repository.dart"
Cohesion: 0.17
Nodes (11): addCreatedComplaintId, clearUserData, getCurrentUser, resetPassword, saveUser, signInWithEmail, signOut, signUpWithEmail (+3 more)

### Community 37 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 38 - "windows/flutter/generated_plugin_registrant.cc"
Cohesion: 0.20
Nodes (8): app_links_plugin_c_api, connectivity_plus_windows_plugin, file_selector_windows, geolocator_windows, plugin_registry, PluginRegistry, url_launcher_windows, RegisterPlugins()

### Community 39 - "providers.dart"
Cohesion: 0.20
Nodes (9): auth_repository.dart, complaint_repository.dart, AnonymousUser, authRepo, getCurrentUser, ../models/anonymous_user.dart, supabase_auth_repository.dart, supabase_complaint_repository.dart (+1 more)

### Community 40 - "package:flutter/material.dart"
Cohesion: 0.18
Nodes (9): ../../core/constants/category_defaults.dart, build, CategoryBadge, categoryId, showIcon, build, ShimmerCard, package:flutter/material.dart (+1 more)

### Community 41 - "ConsumerState"
Cohesion: 0.27
Nodes (10): ConsumerState, ConsumerStatefulWidget, LoginScreen, _LoginScreenState, RegisterScreen, _RegisterScreenState, MainNavScreen, _MainNavScreenState (+2 more)

### Community 42 - "StatelessWidget"
Cohesion: 0.33
Nodes (6): _ActionButton, EmptyStateWidget, ErrorStateWidget, SeffafImage, SeffafLogo, StatelessWidget

### Community 43 - "MaterialPageRoute"
Cohesion: 0.22
Nodes (9): build, _openImageViewer, _buildFeedContent, build, _onItemTapped, _showComplaintBottomSheet, build, _buildFollowedMunicipalitiesSection (+1 more)

### Community 44 - "seffaf_logo.dart"
Cohesion: 0.25
Nodes (7): Axis, build, orientation, showSubtitle, showText, size, package:seffaf/core/constants/app_colors.dart

### Community 45 - "empty_state_widget.dart"
Cohesion: 0.15
Nodes (12): ../../core/constants/app_colors.dart, IconData, build, buttonText, description, icon, onButtonPressed, title (+4 more)

### Community 46 - "authRepositoryProvider"
Cohesion: 0.29
Nodes (7): authRepositoryProvider, _handleLogin, _handleRegister, _toggleFollow, _confirmSignOut, _showResetDataDialog, _showSmsVerificationModal

### Community 47 - "20260928000000_auto_confirm_users.sql"
Cohesion: 0.40
Nodes (3): auth.users, on_auth_user_auto_confirm, on_auth_user_auto_confirm_update

### Community 48 - "Changelog"
Cohesion: 0.12
Nodes (16): [1.2.0](https://github.com/supabase/agent-skills/compare/v1.1.1...v1.2.0) (2026-06-02), [1.3.0](https://github.com/supabase/agent-skills/compare/v1.2.0...v1.3.0) (2026-06-05), [1.4.0](https://github.com/supabase/agent-skills/compare/v1.3.0...v1.4.0) (2026-07-10), [1.5.0](https://github.com/supabase/agent-skills/compare/supabase-postgres-best-practices-v1.4.0...supabase-postgres-best-practices-v1.5.0) (2026-07-30), [1.6.0](https://github.com/supabase/agent-skills/compare/supabase-postgres-best-practices-v1.5.0...supabase-postgres-best-practices-v1.6.0) (2026-07-30), Bug Fixes, Bug Fixes, Bug Fixes (+8 more)

### Community 49 - "main.dart"
Cohesion: 0.12
Nodes (18): ConsumerWidget, core/constants/app_constants.dart, currentUserProvider, features/auth/presentation/login_screen.dart, features/main_navigation/main_nav_screen.dart, features/onboarding/presentation/onboarding_screen.dart, build, initialize (+10 more)

### Community 50 - "seffaf_image.dart"
Cohesion: 0.12
Nodes (16): BorderRadius?, BoxFit, dart:io, double?, borderRadius, build, _buildFallback, _buildPlaceholder (+8 more)

### Community 52 - "Changelog"
Cohesion: 0.12
Nodes (15): [0.1.3](https://github.com/supabase/agent-skills/compare/v0.1.2...v0.1.3) (2026-06-02), [0.1.4](https://github.com/supabase/agent-skills/compare/v0.1.3...v0.1.4) (2026-06-05), [0.1.5](https://github.com/supabase/agent-skills/compare/v0.1.4...v0.1.5) (2026-07-10), [0.1.6](https://github.com/supabase/agent-skills/compare/v0.1.5...supabase-v0.1.6) (2026-07-30), [0.1.7](https://github.com/supabase/agent-skills/compare/v0.1.6...supabase-v0.1.7) (2026-08-12), Bug Fixes, Bug Fixes, Bug Fixes (+7 more)

### Community 53 - "Writing Guidelines for Postgres References"
Cohesion: 0.12
Nodes (15): 1. Concrete Transformation Patterns, 2. Error-First Structure, 3. Quantified Impact, 4. Self-Contained Examples, 5. Semantic Naming, Code Example Standards, Comments, Impact Level Guidelines (+7 more)

### Community 62 - "✨ Temel Özellikler"
Cohesion: 0.12
Nodes (15): 1. 📢 Şikayet Akışı (Feed), 2. 🗺️ İnteraktif Harita (OpenStreetMap), 3. 📝 Çok Adımlı Bildirim Sihirbazı (Report Creation), 4. 📊 Belediye Karnesi ve Şeffaflık Puanlama Algoritması, 5. 🏆 Belediyeler Sıralaması (Leaderboard), 6. 👤 Misafir Profil & Sistem, Adımlar, Gereksinimler (+7 more)

### Community 63 - "Section Definitions"
Cohesion: 0.20
Nodes (9): 1. Query Performance (query), 2. Connection Management (conn), 3. Security & RLS (security), 4. Schema Design (schema), 5. Concurrency & Locking (lock), 6. Data Access Patterns (data), 7. Monitoring & Diagnostics (monitor), 8. Advanced Features (advanced) (+1 more)

### Community 64 - "graphify reference: extra exports and benchmark"
Cohesion: 0.22
Nodes (8): graphify reference: extra exports and benchmark, Step 6b - Wiki (only if --wiki flag), Step 7 - Neo4j export (only if --neo4j or --neo4j-push flag), Step 7a - FalkorDB export (only if --falkordb or --falkordb-push flag), Step 7b - SVG export (only if --svg flag), Step 7c - GraphML export (only if --graphml flag), Step 7d - MCP server (only if --mcp flag), Step 8 - Token reduction benchmark (only if total_words > 5000)

### Community 65 - "🧠 AGENTS.md — Proje Hafızası ve Geliştirici Kılavuzu"
Cohesion: 0.29
Nodes (6): 🧠 AGENTS.md — Proje Hafızası ve Geliştirici Kılavuzu, 🎯 Gelecek Faz (Faz 21 - Canlı Dağıtım ve Yayın Öncesi), 🏗️ Mimari ve Teknoloji Yığını, 📌 Proje Özeti, 💻 Sistem ve Donanım Kısıtları (ÖNEMLİ), 🚦 Tamamlanan Aşamalar (Faz 1 - Faz 10)

### Community 66 - "graphify reference: query, path, explain"
Cohesion: 0.33
Nodes (5): For /graphify explain, For /graphify path, graphify reference: query, path, explain, Step 0 — Constrained query expansion (REQUIRED before traversal), Step 1 — Traversal

### Community 67 - "Supabase Postgres Best Practices"
Cohesion: 0.33
Nodes (5): How to Use, References, Rule Categories by Priority, Supabase Postgres Best Practices, When to Apply

### Community 68 - "date_formatter.dart"
Cohesion: 0.33
Nodes (5): DateFormatter, formatDate, formatDateTime, formatRelative, package:intl/intl.dart

### Community 69 - "graphify reference: add a URL and watch a folder"
Cohesion: 0.50
Nodes (3): For /graphify add, For --watch, graphify reference: add a URL and watch a folder

### Community 70 - "graphify reference: commit hook and native CLAUDE.md integration"
Cohesion: 0.50
Nodes (3): For git commit hook, For native CLAUDE.md integration, graphify reference: commit hook and native CLAUDE.md integration

### Community 71 - "graphify reference: incremental update and cluster-only"
Cohesion: 0.50
Nodes (3): For --cluster-only, For --update (incremental re-extraction), graphify reference: incremental update and cluster-only

### Community 110 - "feed_screen.dart"
Cohesion: 0.12
Nodes (16): ../application/feed_controller.dart, ../../complaint_detail/presentation/complaint_detail_screen.dart, _buildFilterChip, createState, dispose, FeedScreen, _FeedScreenState, initState (+8 more)

### Community 111 - "comment.dart"
Cohesion: 0.17
Nodes (11): DateTime?, anonymousUserId, anonymousUserName, Comment, complaintId, createdAt, fromJson, id (+3 more)

### Community 112 - "full_screen_image_viewer.dart"
Cohesion: 0.18
Nodes (10): build, createState, _currentIndex, dispose, imageUrls, initialIndex, initState, _pageController (+2 more)

### Community 113 - "status_badge.dart"
Cohesion: 0.25
Nodes (7): ComplaintStatus, ../../core/theme/app_theme.dart, ../../data/models/complaint_status.dart, build, isCompact, status, StatusBadge

### Community 114 - "ComplaintCard"
Cohesion: 0.32
Nodes (8): ComplaintCard, _ComplaintCardState, OnboardingScreen, _OnboardingScreenState, FullScreenImageViewer, _FullScreenImageViewerState, State, StatefulWidget

### Community 115 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.29
Nodes (6): package:flutter_riverpod/flutter_riverpod.dart, package:seffaf/features/profile/presentation/profile_screen.dart, package:seffaf/main.dart, package:shared_preferences/shared_preferences.dart, main, main

### Community 116 - "ComplaintRepository"
Cohesion: 0.67
Nodes (3): ComplaintRepository, MockComplaintRepository, SupabaseComplaintRepository

## Knowledge Gaps
- **710 isolated node(s):** `graphify`, `Usage`, `What graphify is for`, `Step 0 - GitHub repos and multi-path merge (only if a URL or several paths)`, `Step 1 - Ensure graphify is installed` (+705 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 917 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **47 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Win32Window` connect `Win32Window` to `string`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **Why does `OnCreate` connect `Win32Window` to `windows/flutter/generated_plugin_registrant.cc`?**
  _High betweenness centrality (0.022) - this node is a cross-community bridge._
- **Why does `RegisterPlugins()` connect `windows/flutter/generated_plugin_registrant.cc` to `Win32Window`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **What connects `graphify`, `Usage`, `What graphify is for` to the rest of the system?**
  _710 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Win32Window` be split into smaller, more focused modules?**
  _Cohesion score 0.05407925407925408 - nodes in this community are weakly interconnected._
- **Should `GeneratedPluginRegistrant.swift` be split into smaller, more focused modules?**
  _Cohesion score 0.04846938775510204 - nodes in this community are weakly interconnected._
- **Should `report_creation_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06896551724137931 - nodes in this community are weakly interconnected._