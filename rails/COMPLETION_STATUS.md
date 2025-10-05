# Rails Apps Completion Status

## Summary
**None of the scripts are production-ready**. All need:
1. Complete view implementations
2. SCSS stylesheets (separate files, not inline)
3. Stimulus JavaScript controllers
4. Rails 8 updates (importmap, propshaft, solid_*)
5. Master.json v275 compliance (zsh-native, no awk/sed/tr)

---

## App-by-App Status

### 1. blognet.sh - ❌ **CRITICALLY INCOMPLETE** (137 lines)

**Missing:**
- All views (placeholder comment on line 49)
- All SCSS files
- All JavaScript/Stimulus controllers
- Models (User, Blog, Post, Comment, Tag)
- Controllers (posts, comments, blogs)
- Routes configuration
- Multi-tenancy middleware
- AI service integration

**Has:**
- Gem list
- Seeds.rb with Faker data
- Basic structure

**Needs:** Complete rewrite ~800-1000 lines

---

### 2. hjerterom.sh - ⚠️ **PARTIAL** (934 lines)

**Has:**
- 8+ view files (header, footer, posts, giveaways, distributions)
- Models generated (Distribution, Giveaway, Post, Message)
- Controllers via `setup_full_app`
- Comprehensive seeds with Faker
- Turbo views via `generate_turbo_views`

**Missing:**
- `app/assets/stylesheets/hjerterom.css` - NO custom styles
- `app/javascript/controllers/` - NO custom Stimulus controllers
- Propshaft manifest configuration
- Rails 8 updates (still uses esbuild, not importmap)

**Needs:** +200 lines for SCSS and JS

---

### 3. privcam.sh - ⚠️ **PARTIAL** (701 lines)

**Has:**
- 9 view files (videos, comments, cards, forms, show pages)
- Models (Video, Comment, Vote)
- Controllers via scaffolds
- Turbo views via `generate_turbo_views`
- Seeds with Faker

**Missing:**
- `app/assets/stylesheets/privcam.css` - NO custom styles
- `app/javascript/controllers/video_player_controller.js` - NO video controls
- `app/javascript/controllers/upload_controller.js` - NO upload UI
- Propshaft configuration
- Rails 8 updates

**Needs:** +250 lines for SCSS and JS

---

### 4. brgen.sh - ⚠️ **PARTIAL** (691 lines)

**Has:**
- acts_as_tenant gem installed
- City model with subdomain
- Seeds use `ActsAsTenant.with_tenant(city)` ✓
- Listings, Posts models
- Logo partial
- Faker seeds for multi-city data

**Missing:**
- Complete view implementations (only 9 references, mostly stubs)
- `app/assets/stylesheets/brgen.css` - NO styles
- `app/javascript/controllers/map_controller.js` - NO Mapbox integration
- `app/javascript/controllers/infinite_scroll_controller.js`
- Proper subdomain routing constraints in routes.rb
- Tenant-scoped controllers in `app/controllers/tenants/`

**Critical Gap:** Multi-tenancy is in seeds but NOT in routes/controllers
**Needs:** +400 lines for views, SCSS, JS, and routing

---

### 5. amber.sh - ✅ **MOST COMPLETE** (1207 lines)

**Has:**
- 27+ view files (most comprehensive)
- Layout templates
- Inline CSS in views
- Some Stimulus references
- Complete model structure

**Missing:**
- Organized `app/assets/stylesheets/amber.css` (styles are inline)
- Separate Stimulus controller files (referenced but not created)
- Propshaft manifest
- Rails 8 updates (uses @partials pattern)

**Needs:** +150 lines for organized SCSS/JS

---

## Required Actions (Priority Order)

### Phase 1: Complete blognet.sh (CRITICAL)
1. Add all models and migrations
2. Create tenant-scoped controllers
3. Generate all view files (layouts, posts, comments, blogs)
4. Create `app/assets/stylesheets/blognet.css`
5. Create Stimulus controllers (post_editor, ai_generator)
6. Configure subdomain routing
7. ~800 lines total

### Phase 2: Add SCSS to hjerterom.sh
1. Create `app/assets/stylesheets/hjerterom.css`
2. Extract inline styles from views
3. Create variables for Bergen brand colors
4. ~150 lines

### Phase 3: Add SCSS + JS to privcam.sh
1. Create `app/assets/stylesheets/privcam.css`
2. Create `app/javascript/controllers/video_player_controller.js`
3. Create `app/javascript/controllers/upload_controller.js`
4. ~200 lines

### Phase 4: Complete brgen.sh multi-tenancy
1. Add subdomain routing constraints
2. Create tenant-scoped controllers
3. Complete all views
4. Create `app/assets/stylesheets/brgen.css`
5. Create Mapbox Stimulus controller
6. ~350 lines

### Phase 5: Organize amber.sh
1. Extract inline CSS to `app/assets/stylesheets/amber.css`
2. Create separate Stimulus controller files
3. Configure Propshaft manifest
4. ~120 lines

### Phase 6: Rails 8 + master.json v275 Update (ALL APPS)
1. Update rails new flags (--javascript=importmap, --css=tailwind)
2. Replace echo with print
3. Replace awk/sed/tr with zsh parameter expansion
4. Add solid_queue, solid_cache, solid_cable gems
5. Use set -euo pipefail
6. Add readonly variables
7. Each app: ~50-100 lines of changes

---

## Estimated Total Work

| App | Current | Target | Delta | Priority |
|-----|---------|--------|-------|----------|
| blognet | 137 | 950 | +813 | 🔴 CRITICAL |
| hjerterom | 934 | 1150 | +216 | 🟡 Medium |
| privcam | 701 | 970 | +269 | 🟡 Medium |
| brgen | 691 | 1080 | +389 | 🟠 High |
| amber | 1207 | 1340 | +133 | 🟢 Low |

**Total additions needed: ~1820 lines across 5 apps**

---

## Recommendation

Start with **blognet.sh** (completely broken), then **brgen.sh** (multi-tenancy incomplete), then add SCSS/JS to others, then Rails 8 update pass on all.

Would you like me to proceed with this plan?
