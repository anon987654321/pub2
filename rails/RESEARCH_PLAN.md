# BRGEN.NO Research Plan
**Systematic Source Code Analysis**

## Approach

Use parallel Task agents to research each component simultaneously, then synthesize findings into implementation specifications.

---

## Research Tasks (Run in Parallel)

### Task 1: Rails 8 & Hotwire Stack
**Agent**: `general-purpose`
**Sources**:
- https://github.com/rails/rails (CHANGELOG, upgrading guides)
- https://github.com/hotwired/turbo-rails
- https://github.com/hotwired/stimulus
- https://turbo.hotwired.dev/
- https://stimulus.hotwired.dev/

**Questions**:
1. What's new in Rails 8 for our use case?
2. Solid Queue vs Sidekiq - which for AI jobs?
3. Solid Cache - Redis still needed?
4. Solid Cable - ActionCable replacement?
5. Turbo 8 morphing - replace StimulusReflex?
6. Authentication changes from Rails 7?
7. Asset pipeline - Propshaft sufficient?

**Output**: `rails8_analysis.md`

---

### Task 2: StimulusReflex & Components
**Agent**: `general-purpose`
**Sources**:
- https://github.com/stimulusreflex/stimulus_reflex
- https://docs.stimulusreflex.com/
- https://www.stimulus-components.com/
- CableReady integration

**Questions**:
1. Is StimulusReflex still maintained?
2. Does Turbo 8 supersede it?
3. Which stimulus-components for our features?
4. Real-time voting implementation pattern?
5. Infinite scroll best practice?
6. File upload with progress?

**Output**: `stimulus_analysis.md`

---

### Task 3: Authentication Stack
**Agent**: `general-purpose`
**Sources**:
- https://github.com/heartcombo/devise
- https://github.com/cbeer/devise-guests
- https://github.com/omniauth/omniauth
- https://developer.vipps.no/
- https://www.bankid.no/en/developer/

**Questions**:
1. Devise Rails 8 compatibility?
2. Devise Guests - guest-to-user upgrade flow?
3. Vipps OAuth - official gem or custom?
4. BankID - integration complexity?
5. Anonymous posting pattern?
6. Multi-tenant user isolation?

**Output**: `auth_analysis.md`

---

### Task 4: Multi-Tenancy
**Agent**: `general-purpose`
**Sources**:
- https://github.com/ErwinM/acts_as_tenant
- https://github.com/influitive/apartment
- Rails subdomain routing patterns

**Questions**:
1. ActsAsTenant performance at scale?
2. Row vs schema tenancy for 40+ cities?
3. Subdomain routing best practice?
4. Tenant data isolation guarantees?
5. Cross-tenant search feasibility?
6. Admin super-tenant pattern?

**Output**: `multitenancy_analysis.md`

---

### Task 5: Solidus Marketplace
**Agent**: `general-purpose`
**Sources**:
- https://edgeguides.solidus.io/
- https://github.com/solidusio/solidus
- Solidus multi-store extension
- Norwegian payment providers

**Questions**:
1. Rails 8 compatibility status?
2. Multi-store for multi-tenancy?
3. Mount at subdomain route - pattern?
4. Vipps payment integration?
5. Klarna for Norway?
6. Shared User model approach?
7. Product catalog per tenant?

**Output**: `solidus_analysis.md`

---

### Task 6: AI & LangChain Stack
**Agent**: `general-purpose`
**Sources**:
- https://github.com/patterns-ai-core/langchainrb
- https://github.com/patterns-ai-core/langchainrb-cli (if exists)
- Related repos: vector DB examples
- https://replicate.com/docs/reference/http
- https://github.com/replicate/replicate-ruby

**Questions**:
1. LangChainRB maturity level?
2. Which LLM providers supported?
3. Vector store integrations?
4. Replicate.com Ruby client quality?
5. Cost estimation for image/video gen?
6. Prompt enhancement patterns?
7. Background job integration?
8. Streaming responses?

**Output**: `ai_langchain_analysis.md`

---

### Task 7: Vector Database Options
**Agent**: `general-purpose`
**Sources**:
- https://github.com/pgvector/pgvector
- https://github.com/neighbor-gem/neighbor (pgvector ActiveRecord)
- https://github.com/pinecone-io/pinecone-ruby-client
- https://github.com/weaviate/weaviate-ruby-client
- https://github.com/qdrant/qdrant-ruby

**Questions**:
1. pgvector sufficient for 40+ tenants?
2. Performance at 100k+ vectors?
3. Index strategy recommendations?
4. OpenBSD compatibility?
5. Embedding model recommendations?
6. Distance metrics for semantic search?
7. Hybrid search (keyword + vector)?

**Output**: `vector_db_analysis.md`

---

### Task 8: Media Processing & Streaming
**Agent**: `general-purpose`
**Sources**:
- Rails Active Storage docs
- ffmpeg best practices
- HLS streaming setup
- ActionCable for live streams
- WebRTC options

**Questions**:
1. Direct upload to S3 vs local on OpenBSD?
2. Video transcoding - background job pattern?
3. HLS streaming setup for TV channels?
4. Live streaming infrastructure?
5. Audio streaming (SoundCloud-like)?
6. Image optimization with libvips?
7. CDN requirements?

**Output**: `media_streaming_analysis.md`

---

### Task 9: Real-Time & WebSockets
**Agent**: `general-purpose`
**Sources**:
- ActionCable documentation
- Turbo Streams
- Hotwire discussions on real-time
- WebRTC implementations

**Questions**:
1. ActionCable scaling on OpenBSD?
2. Redis or Solid Cable?
3. Turbo Streams vs ActionCable when?
4. Presence channels pattern?
5. Video call - self-hosted WebRTC?
6. Live notifications implementation?
7. Chat system architecture?

**Output**: `realtime_analysis.md`

---

### Task 10: OpenBSD Integration
**Agent**: `general-purpose`
**Sources**:
- pub2/openbsd.sh (our existing script)
- Falcon async server docs
- relayd configuration examples
- PostgreSQL on OpenBSD best practices

**Questions**:
1. How to integrate new brgen app with openbsd.sh?
2. Port assignment strategy for subdomains?
3. Database pooling for multi-tenant?
4. Redis configuration for multiple apps?
5. Falcon deployment pattern?
6. Log aggregation approach?
7. Backup strategy?

**Output**: `openbsd_integration_analysis.md`

---

## Synthesis Phase

After all research tasks complete:

### Task 11: Architecture Synthesis
**Agent**: `general-purpose`
**Input**: All 10 analysis documents
**Output**: `brgen_technical_spec.md`

**Contents**:
1. Technology stack decisions
2. Database schema (migrations)
3. Model relationships
4. Controller structure
5. Route organization
6. JavaScript architecture
7. Background job queues
8. Deployment configuration
9. Performance considerations
10. Security measures

---

### Task 12: Implementation Plan
**Agent**: `general-purpose`
**Input**: Technical spec
**Output**: `brgen_implementation_plan.md`

**Contents**:
1. Development phases with timelines
2. Dependency order (what builds on what)
3. Testing strategy per phase
4. Deployment milestones
5. Rollback procedures
6. Monitoring setup
7. Cost projections
8. Risk mitigation

---

### Task 13: Code Generation
**Agent**: `general-purpose`
**Input**: Technical spec + Implementation plan
**Output**: Working code in `rails/brgen/`

**Generate**:
1. Rails 8 app initialization
2. Core models with migrations
3. Controllers with actions
4. Views with Hotwire
5. Stimulus controllers
6. Background jobs
7. Configuration files
8. OpenBSD deployment script updates
9. Tests (minimal but present)
10. README with setup instructions

---

## Execution Strategy

### Step 1: Parallel Research (Est: 2-3 hours)
Launch Tasks 1-10 simultaneously using multiple agent invocations in a single message.

### Step 2: Review Findings (Est: 30 minutes)
Read all analysis documents, identify gaps, run follow-up tasks if needed.

### Step 3: Architecture Synthesis (Est: 1 hour)
Run Task 11 with all inputs to create technical specification.

### Step 4: Implementation Planning (Est: 1 hour)
Run Task 12 to create detailed implementation roadmap.

### Step 5: Code Generation (Est: 2-3 hours)
Run Task 13 to generate working Rails 8 application code.

### Step 6: Integration & Testing (Est: 2-4 hours)
- Integrate with openbsd.sh
- Test on OpenBSD VM
- Verify multi-tenancy
- Test one feature from each category

---

## Success Criteria

- [ ] All 10 research tasks complete with evidence
- [ ] Technical spec covers all BRGEN.NO features
- [ ] Implementation plan has realistic timelines
- [ ] Generated code follows Rails 8 + Hotwire conventions
- [ ] Multi-tenancy works for 3+ test cities
- [ ] One feature from each category works end-to-end:
  - Social: Post with voting
  - Marketplace: Product listing
  - Media: Upload and play audio
  - Dating: User profiles
  - AI: Generate one image
- [ ] Deploys successfully to OpenBSD
- [ ] Vipps OAuth works in test mode
- [ ] Performance: <200ms response time for 90% of requests

---

## Risk Mitigation

**Risk 1**: Rails 8 incompatibility with gems
**Mitigation**: Check compatibility, use forks if needed, fallback options

**Risk 2**: Vipps/BankID OAuth complexity
**Mitigation**: Start with standard OAuth2, add Vipps later if needed

**Risk 3**: AI generation costs
**Mitigation**: Rate limiting, user quotas, cost estimation before gen

**Risk 4**: Multi-tenancy performance
**Mitigation**: Database indexing, caching strategy, load testing

**Risk 5**: Real-time scaling
**Mitigation**: Redis Cluster, ActionCable optimization, monitoring

---

## Cost Estimation

**Development Time**:
- Research: 2-3 hours
- Planning: 2 hours
- Code generation: 2-3 hours
- Integration: 2-4 hours
- Testing: 2-3 hours
- **Total**: 10-15 hours for MVP

**Infrastructure** (monthly):
- OpenBSD VM: $40-80
- Database storage: $10-20
- Media storage: $50-100
- AI generation (Replicate): $50-500 (usage-based)
- **Total**: $150-700/month

**Third-party Services**:
- Vipps: Transaction fees
- BankID: Per-authentication cost
- CDN (if needed): $20-100/month

---

**Status**: Ready to execute. Awaiting approval to launch 10 parallel research agents.

**Next Command**: Launch Tasks 1-10 in parallel, then proceed with synthesis.