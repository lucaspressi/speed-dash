# DevForum Research - Speed Dash Improvements

## Executive Summary

This document compiles research from the Roblox Developer Forum on best practices for simulator games, focusing on monetization, engagement, gameplay systems, and player retention. All recommendations are tailored specifically for **Speed Dash**, a speed simulator with treadmill progression mechanics.

**Research Date**: January 18, 2026
**Total Sources Analyzed**: 40+ DevForum threads

---

## Table of Contents

1. [Current State Analysis](#current-state-analysis)
2. [Monetization Systems](#monetization-systems)
3. [Gameplay & Engagement](#gameplay--engagement)
4. [Social Features](#social-features)
5. [Implementation Priority Matrix](#implementation-priority-matrix)
6. [Testing Strategy](#testing-strategy)

---

## Current State Analysis

### What Speed Dash Already Has ✅

- **Core Progression**: Exponential XP system with rebirth mechanics
- **Monetization**: Speed boosts (x2-x16), Win boosts (x2-x16), Premium treadmills (x3, x9, x25)
- **Gameplay Loop**: Run on treadmills → Gain XP → Level up → Rebirth → Repeat
- **Boss Mechanics**: Buff Noob NPC with chase AI
- **Obstacles**: Lava zones, axes, rolling balls
- **Admin Dashboard**: Backend ready, ~80% complete

### Missing High-Impact Systems 🎯

Based on DevForum research, these systems are common in successful simulators but absent from Speed Dash:

1. **Pet/Companion System** - Provides passive speed boosts + collectability
2. **Daily Rewards** - Drives daily active users (DAU)
3. **Battle Pass/Season Pass** - Recurring revenue + long-term goals
4. **Trading System** - Social engagement + player-driven economy
5. **Promo Codes** - Marketing tool + player acquisition
6. **Friends Invite Bonuses** - Viral growth mechanic
7. **Multiple Progression Paths** - Prevents single-path exhaustion
8. **Visual Feedback Systems** - Dopamine triggers (confetti, fireworks, etc.)

---

## Monetization Systems

### 1. Pet System 🐾

**Why It's Critical**: Pets are the #1 monetization driver in successful simulators (Pet Sim X, Bubble Gum Sim).

#### Implementation Plan

**Phase 1: Basic Pet System**
```lua
-- Pet Mechanics
- Pets follow player using AlignPosition + BodyGyro
- Pets provide speed multipliers (1.1x - 5x)
- Rarity tiers: Common, Uncommon, Rare, Epic, Legendary, Mythic
- Equip limit: 3-6 pets active simultaneously
- Multipliers stack additively or multiplicatively (test both)
```

**Phase 2: Egg Hatching**
```lua
-- Egg System
- Basic Egg: 500 Speed currency (guaranteed Common-Rare)
- Golden Egg: 5,000 Speed (guaranteed Rare-Epic)
- Diamond Egg: 50,000 Speed (guaranteed Epic-Legendary)
- Premium Egg: 199 Robux (guaranteed Legendary-Mythic + exclusive pets)
```

**Phase 3: Pet Upgrades**
```lua
-- Enhancement System
- Combine duplicate pets to level them up (like Pet Sim X)
- Each level: +10% to base multiplier
- Max level: 10 (or balance through testing)
- "Golden" and "Rainbow" versions at higher tiers
```

**Monetization Hooks**:
- Egg purchases (Robux)
- Inventory expansion (default: 50 pets, +50 slots for 99 Robux)
- Auto-hatch gamepass (399 Robux) - hatches eggs automatically
- Lucky multiplier (x2 luck for better pets, 299 Robux)

**Resources**:
- [Pet System [Open Source]](https://devforum.roblox.com/t/pet-system-open-source/1141510)
- [Pet Follow Module [Simulator style]](https://devforum.roblox.com/t/pet-follow-module-simulator-style/901913)
- [Creating a Simulator Pet System](https://devforum.roblox.com/t/creating-a-simulator-pet-system/638078)

---

### 2. Battle Pass / Season Pass 🎟️

**Why It's Critical**: Provides recurring revenue and long-term goals. Roblox now offers an official Season Pass package.

#### Implementation Plan

**Structure**:
```
Season Duration: 30-45 days
Total Tiers: 30-50
Free Track: 10-15 rewards (basic cosmetics, speed boosts)
Premium Track: 30-50 rewards (exclusive pets, animations, cosmetics, multipliers)
Price: 499-799 Robux
```

**Reward Examples**:
| Tier | Free Track | Premium Track |
|------|------------|---------------|
| 5 | +10K Speed | Rare Egg + "Speedy" Animated Hat |
| 10 | Common Pet Egg | Epic Pet Egg + 2x Win Boost (1hr) |
| 15 | +25K Speed | "Lightning Trail" Effect |
| 20 | Uncommon Egg | Legendary Egg + "Flash" Dance Emote |
| 30 | +50K Speed | Exclusive "Sonic" Pet (5x multiplier) |
| 50 | N/A | "Rainbow Trail" + Season Badge |

**Progression Methods**:
- Earn XP by running on treadmills
- Daily challenges (e.g., "Run 10km today", "Rebirth once")
- Weekly challenges (e.g., "Reach Level 100", "Defeat Buff Noob 5 times")

**Monetization Hooks**:
- Tier skip: 10 Robux per tier
- Premium pass: 499-799 Robux
- Battle pass bundle: 999 Robux (includes +10 tier skip)

**Resources**:
- [Official Season Pass Package (Beta)](https://devforum.roblox.com/t/beta-new-feature-packages-season-pass-engagement-rewards/3579550)
- [Level Up Workshop: Season Pass](https://devforum.roblox.com/t/level-up-season-pass-interactive-workshop/1470549)

---

### 3. Daily Rewards 📅

**Why It's Critical**: Increases DAU (Daily Active Users) and D1 retention by 15-30% according to DevForum discussions.

#### Implementation Plan

**Reward Structure** (30-day cycle):
```
Day 1:  +5,000 Speed
Day 2:  +10,000 Speed
Day 3:  Common Pet Egg
Day 5:  x2 Speed Boost (1 hour)
Day 7:  Uncommon Pet Egg + "Weekly Warrior" Badge
Day 10: +50,000 Speed
Day 14: Rare Pet Egg + x2 Win Boost (1 hour)
Day 21: Epic Pet Egg
Day 30: Exclusive "Dedication" Pet (3x multiplier, untradeable)
```

**Design Principles**:
- **Reset vs. Accumulation**: Test both approaches
  - Reset: Miss one day = restart from Day 1 (harsher, higher engagement)
  - Accumulation: Days accumulate, just claim when you log in (friendlier, lower drop-off)
- **Visual Design**: Calendar UI with grayed-out future days, glowing current day
- **Premium Bonus**: VIP members get 2x daily rewards

**Monetization Hooks**:
- "Claim Double" button (29 Robux) - doubles today's reward
- Skip ahead 1 day (19 Robux)

**Resources**:
- [Do daily rewards actually keep players retention?](https://devforum.roblox.com/t/do-daily-rewards-actually-keep-players-retention/3556728)
- [How to make a Daily Reward System? | Tutorial](https://devforum.roblox.com/t/how-to-make-a-daily-reward-system-tutorial/1515290)

---

### 4. Promo Codes System 🎫

**Why It's Critical**: Essential for marketing campaigns, YouTuber partnerships, and player acquisition.

#### Implementation Plan

**Code Types**:
```lua
-- Speed Codes
"RELEASE" → +25,000 Speed
"100KLIKES" → +100,000 Speed
"SONIC" → +500,000 Speed + Rare Egg

-- Pet Codes
"FREECAT" → Exclusive "Promo Cat" pet (2x multiplier)
"YTCODE" → Epic Egg

-- Boost Codes
"2XWEEKEND" → x2 Speed Boost (2 hours)
"LAUNCH2026" → x2 Win Boost (1 hour) + x2 Speed Boost (1 hour)

-- Seasonal Codes
"NEWYEAR2026" → Exclusive "2026 Badge" + Legendary Egg
"VALENTINE" → "Heart Trail" Effect + Epic Egg
```

**System Features**:
- One-time redemption per player (saved in DataStore)
- Case-insensitive
- Expiration dates (optional)
- Admin panel to create/expire codes
- In-game code redemption UI (prominent button)

**Admin Backend**:
```typescript
// dashboard-backend/src/routes/promoCodes.ts
POST   /api/codes/create
DELETE /api/codes/:code/expire
GET    /api/codes/analytics
```

**Resources**:
- [Redeem Code System](https://devforum.roblox.com/t/redeem-code-system/1342240)
- [SR Code Redemption System V2](https://devforum.roblox.com/t/sr-code-redemption-system-v2-a-simple-efficient-code-redemption-system/2025874)
- [Creating a Twitter Code System](https://devforum.roblox.com/t/creating-a-twitter-code-system-for-in-game-currency/923985)

---

### 5. Trading System 🤝

**Why It's Critical**: Creates player-driven economy, increases social engagement, and extends session time.

#### Implementation Plan

**Tradeable Items**:
- Pets (all rarities)
- Pet eggs (unopened)
- Cosmetics (trails, effects, animations)
- Limited-time event items

**Non-Tradeable Items**:
- Robux-purchased boosts (x2, x4, x8, x16)
- Daily reward exclusives
- Admin-gifted items

**Trading UI**:
```
┌─────────────────────────────────────┐
│  Trading with [PlayerName]          │
├─────────────────┬───────────────────┤
│   Your Offer    │   Their Offer     │
│                 │                   │
│  [Pet Slot 1]   │   [Pet Slot 1]    │
│  [Pet Slot 2]   │   [Pet Slot 2]    │
│  [Pet Slot 3]   │   [Pet Slot 3]    │
│                 │                   │
│  ☑ Ready        │   ☐ Not Ready     │
└─────────────────┴───────────────────┘
      [ACCEPT]  [CANCEL]
```

**Security Features**:
- Both players must check "Ready" before trade executes
- 3-second confirmation window
- Trade history log (last 50 trades per player)
- Scam detection: Flag if trading Legendary for Common (warn both parties)

**Monetization Hooks**:
- Trade slots: Default 3, expand to 5 for 99 Robux
- Trade radius: Default 20 studs, "Trade Anywhere" gamepass (199 Robux)

**Roblox Policy Compliance**:
- **ArePaidRandomItemsRestricted**: If pets from paid eggs are tradeable, ensure compliance
- Display odds for all egg hatches (required by Roblox policy)

**Resources**:
- [I need help on how to make a pet trading system!](https://devforum.roblox.com/t/i-need-help-on-how-to-make-a-pet-trading-system/431175)
- [Is a trading system a "must have" for a game?](https://devforum.roblox.com/t/is-a-trading-system-a-must-have-for-a-game/285058)

---

### 6. Upgraded Shop System 🛒

**Current State**: You have Speed Packs and Boost purchases, but they lack visual appeal and urgency.

#### Improvements

**Time-Limited Offers**:
```lua
-- Flash Sales (rotate every 6 hours)
"MEGA DEAL: x4 Speed Boost - 20% OFF"
Normal: 29 Robux → Sale: 23 Robux
Timer: "3:42:15 remaining"

-- Weekend Specials
"2X SPEED WEEKEND: All boosts 50% off!"
Runs Friday-Sunday
```

**Bundle Deals**:
```lua
-- Starter Pack (First purchase only)
Price: 99 Robux (50% off)
Contains:
- x2 Speed Boost (permanent)
- x2 Win Boost (permanent)
- 3x Golden Eggs
- "New Player" Badge

-- Speed King Bundle
Price: 499 Robux
Contains:
- x8 Speed Boost (permanent)
- x4 Win Boost (permanent)
- 1x Diamond Egg
- Exclusive "Crown" Hat
- "VIP" Trail Effect

-- Mega Bundle (Best value)
Price: 1,999 Robux
Contains:
- x16 Speed Boost (permanent)
- x8 Win Boost (permanent)
- x25 Treadmill Access (permanent)
- 10x Diamond Eggs
- All cosmetic trails
- Exclusive "Lightning" Pet (10x multiplier)
```

**First Purchase Psychology**:
- Trigger first purchase prompt at 30-60 minutes of gameplay
- Price point: $2-3 USD equivalent (affordable impulse buy)
- Make it feel exclusive: "One-time offer for new players!"

**Resources**:
- [Monetisation 101: How to effectively generate revenue](https://devforum.roblox.com/t/monetisation-101-how-to-effectively-generate-revenue-in-your-roblox-game/246902)

---

## Gameplay & Engagement

### 7. Multiple Progression Paths 🛤️

**Problem**: Speed Dash currently has only one progression path (run → level up → rebirth).

**Solution**: Add parallel progression systems.

#### New Progression Systems

**A. Zones/Worlds System**
```
World 1: Starter Zone (Levels 1-50)
- Basic treadmills
- Buff Noob boss
- Lava obstacles

World 2: Desert Zone (Levels 51-150)
- Faster treadmills (2x base)
- "Sand Titan" boss
- Quicksand traps

World 3: Ice Zone (Levels 151-300)
- Super-fast treadmills (4x base)
- "Frost Giant" boss
- Sliding ice patches (speed boost but hard to control)

World 4: Space Zone (Levels 301-500)
- Ultra treadmills (8x base)
- "Cosmic Entity" boss
- Low gravity (affects jump)

World 5: Rainbow Zone (Levels 501-1000)
- Legendary treadmills (16x base)
- "Speed Demon" final boss
- Teleport portals
```

Each zone unlocks at specific level milestones and offers:
- New pets (zone-exclusive)
- New cosmetics
- New treadmill multipliers
- New boss fights

**B. Achievement System**
```lua
-- Speed Achievements
"Speedster" - Reach 100,000 Speed Display
"Sonic Boom" - Reach 1,000,000 Speed Display
"Light Speed" - Reach 10,000,000 Speed Display

-- Rebirth Achievements
"Born Again" - Rebirth for the first time
"Rebirth Master" - Rebirth 10 times
"Rebirth Legend" - Rebirth 100 times

-- Boss Achievements
"Noob Slayer" - Defeat Buff Noob
"Boss Hunter" - Defeat all bosses
"No Damage Run" - Defeat a boss without taking damage

-- Collection Achievements
"Pet Collector" - Hatch 10 pets
"Legendary Collector" - Hatch 5 Legendary pets
"Full Collection" - Collect all pets
```

Rewards: Badges, exclusive cosmetics, stat boosts

**C. Quests/Missions System**
```lua
-- Daily Quests (reset every 24 hours)
"Run 5km on treadmills" → +10,000 Speed
"Rebirth once" → Common Egg
"Defeat Buff Noob" → x2 Speed Boost (30 min)

-- Weekly Quests (reset every 7 days)
"Reach Level 200" → Rare Egg + 50,000 Speed
"Rebirth 5 times" → Epic Egg
"Hatch 20 eggs" → Legendary Egg

-- Story Quests (one-time, progressive)
Quest 1: "Talk to the Speed Master NPC"
Quest 2: "Reach Level 25"
Quest 3: "Unlock World 2"
Quest 4: "Defeat the Sand Titan"
...
Final Quest: "Defeat the Speed Demon" → Mythic "Endgame" Pet (50x multiplier)
```

**Resources**:
- [How to increase retention, engagement, etc in a simulator](https://devforum.roblox.com/t/how-to-increase-retention-engagement-etc-in-a-simulator/3292053)

---

### 8. Visual Feedback & Juice 💥

**Problem**: Current UI is functional but lacks dopamine-triggering feedback.

**Solution**: Add visual/audio "juice" to every action.

#### Implementation

**Level Up Feedback**:
```lua
-- When player levels up:
- Screen flash (white fade in/out)
- Particle emitter burst (sparkles, confetti)
- Sound effect (triumph, level-up chime)
- "+1 LEVEL" floating text above player (TweenService)
- Screen shake (subtle, 0.2s)
```

**Rebirth Feedback**:
```lua
-- When player rebirths:
- Full-screen particle explosion (fireworks)
- Rainbow color gradient across screen
- Epic sound effect (orchestra hit)
- "REBIRTH!" large text with glow
- Camera zoom out then in
- Speed reset animation (numbers count down rapidly)
```

**Pet Hatch Feedback**:
```lua
-- When hatching egg:
- Egg shake animation (3 shakes)
- Crack lines appear
- Explosion of light
- Pet revealed with rarity-colored aura
  - Common: Gray
  - Uncommon: Green
  - Rare: Blue
  - Epic: Purple
  - Legendary: Gold
  - Mythic: Rainbow
- Rarity announcement: "LEGENDARY!" (large text)
- Sound effect varies by rarity
```

**Purchase Feedback**:
```lua
-- When buying anything:
- Coin/Robux icon flies from shop to player
- "Purchase successful!" notification
- Confetti burst
- Item icon appears in top-right with "+1" indicator
```

**Resources**:
- [Game Design Theory: Psychology of Feedback Loops](https://devforum.roblox.com/t/game-design-theory-psychology-of-feedback-loops-and-how-to-make-them/63140)

---

### 9. Onboarding & Tutorial ✨

**Problem**: New players may not understand the core loop immediately.

**Solution**: Interactive, skippable tutorial.

#### Tutorial Flow

```
1. Spawn player on Tutorial Treadmill
2. NPC "Speed Coach" appears:
   "Welcome to Speed Dash! Let's get you running!"
3. Prompt: "Step onto the treadmill to start gaining speed!"
4. Player steps on treadmill → XP starts accumulating
5. NPC: "Great! Keep running to level up. Your speed increases with each level!"
6. Player hits Level 2 → Level up animation triggers
7. NPC: "Nice! Now try the GOLDEN TREADMILL for 3x speed!"
8. Arrow points to Golden treadmill
9. Player uses Golden treadmill
10. NPC: "You're a natural! Ready to explore? The world is yours!"
11. Tutorial ends, player can skip anytime with [SKIP TUTORIAL] button
```

**Key Principles**:
- Interactive (player does actions, not just reads)
- Skippable (button always visible)
- < 60 seconds total
- Showcases core loop + first monetization tease (Golden treadmill)

---

## Social Features

### 10. Friends Invite System 👥

**Why It's Critical**: Drives viral growth. Games with friend bonuses see 2-3x higher invite rates.

#### Implementation

**Invite Rewards**:
```lua
-- Inviter Rewards (for inviting friends)
1 friend joins: +50,000 Speed
5 friends join: Rare Egg
10 friends join: Epic Egg + "Social Butterfly" Badge
25 friends join: Legendary Egg + x2 Speed Boost (permanent)
50 friends join: Exclusive "Golden Friend" Pet (5x multiplier)

-- Invitee Rewards (for joining via invite)
Immediately: +25,000 Speed + Common Egg
"Thanks for joining via [InviterName]!"
```

**Friend Boost**:
```lua
-- When playing with friends in same server:
1 friend: +10% Speed
2 friends: +25% Speed
3+ friends: +50% Speed

-- Display in UI:
"👥 Friend Boost: +25% Speed (2 friends online)"
```

**Invite UI**:
```lua
-- Button in main menu: "📨 INVITE FRIENDS"
Opens menu:
- List of Roblox friends (online status)
- "Invite" button next to each name
- Shows which friends already play
- Progress bar: "5/10 friends joined - Unlock Epic Egg!"
```

**Resources**:
- [Making a friend boost system](https://devforum.roblox.com/t/making-a-friend-boost-system/2392990)
- [How would i be able to create a friends invite rewards system?](https://devforum.roblox.com/t/how-would-i-be-able-to-create-a-friends-invite-rewards-system/2419842)
- [Official Developer Modules: Instant Social Features](https://devforum.roblox.com/t/developer-modules-instant-social-features/1479221)

---

### 11. Group Benefits 🎖️

**Implementation**:
```lua
-- Roblox Group Benefits
If player is in Speed Dash official group:
- +25% Speed multiplier (permanent)
- Exclusive "Group Member" Badge
- Access to group-only treadmill (5x multiplier, free)
- Monthly group-exclusive pet drops

-- Join Group Prompt
Show in UI: "Join our group for +25% Speed! [JOIN NOW]"
```

---

### 12. Leaderboards 🏆

**Current**: You have `LeaderboardUpdater.server.lua`, but expand it.

**Additions**:
```lua
-- Multiple Leaderboard Categories
1. Top Speed (current Speed Display)
2. Top Level (highest level)
3. Total Rebirths (most rebirths)
4. Pet Collector (most unique pets)
5. Boss Slayer (most boss kills)
6. Daily Top (resets every 24 hours)
7. Weekly Top (resets every 7 days)
```

**Rewards for Leaderboard Positions**:
```lua
-- Daily Top 10:
Rank 1: Legendary Egg + "Daily Champion" Badge
Rank 2-5: Epic Egg
Rank 6-10: Rare Egg

-- All-Time Top 100:
Rank 1-10: Exclusive "Hall of Fame" Aura Effect
Rank 11-50: "Top Player" Badge
Rank 51-100: "Elite" Badge
```

---

## Implementation Priority Matrix

### Priority 1 (Implement First) - Highest ROI 🔥

1. **Promo Codes System** (1-2 days)
   - Easiest to implement
   - Immediate marketing value
   - Drives player acquisition

2. **Daily Rewards** (2-3 days)
   - Proven to increase D1 retention by 15-30%
   - Low implementation complexity
   - High engagement impact

3. **Visual Feedback / Juice** (3-5 days)
   - Improves perceived game quality
   - Increases dopamine triggers
   - Relatively easy to add

4. **Onboarding Tutorial** (2-3 days)
   - Reduces new player confusion
   - Improves D1 retention
   - Low complexity

### Priority 2 (Implement Second) - High ROI 💰

5. **Pet System - Phase 1 (Basic)** (5-7 days)
   - Highest long-term monetization potential
   - Core system for simulator genre
   - Complex but essential

6. **Friends Invite System** (3-4 days)
   - Drives viral growth
   - Medium complexity
   - High social engagement

7. **Multiple Zones/Worlds** (7-10 days)
   - Adds content depth
   - Increases session time
   - Medium-high complexity

### Priority 3 (Implement Third) - Medium ROI 📈

8. **Battle Pass / Season Pass** (5-7 days)
   - Recurring revenue model
   - Long-term engagement
   - Can use official Roblox package

9. **Trading System** (7-10 days)
   - Player-driven economy
   - Requires careful balancing
   - High complexity

10. **Pet System - Phase 2 (Eggs)** (3-5 days)
    - Builds on Phase 1
    - Adds monetization layers

### Priority 4 (Future Updates) - Lower Priority 🔮

11. **Pet System - Phase 3 (Upgrades)** (4-6 days)
12. **Achievement System** (5-7 days)
13. **Quest/Mission System** (7-10 days)
14. **Additional Boss Fights** (per boss: 3-5 days)

---

## Testing Strategy

### A/B Testing Recommendations

**Daily Rewards**:
- Test A: Reset on missed day
- Test B: Accumulative (doesn't reset)
- Metric: D7 retention rate

**Pet Multipliers**:
- Test A: Additive stacking (1.5x + 1.5x = 3x)
- Test B: Multiplicative stacking (1.5x × 1.5x = 2.25x)
- Metric: Average revenue per paying user (ARPPU)

**First Purchase Timing**:
- Test A: Prompt at 30 minutes
- Test B: Prompt at 60 minutes
- Test C: Prompt at Level 25
- Metric: First purchase conversion rate

**Battle Pass Pricing**:
- Test A: 499 Robux
- Test B: 699 Robux
- Metric: Purchase rate × price (total revenue)

### Key Metrics to Track

**Retention**:
- D1 (Day 1 retention)
- D7 (Day 7 retention)
- D30 (Day 30 retention)

**Monetization**:
- Conversion rate (% of players who make first purchase)
- ARPU (Average Revenue Per User)
- ARPPU (Average Revenue Per Paying User)
- % Whales (players spending >$50)

**Engagement**:
- Average session time
- DAU (Daily Active Users)
- Sessions per user per day
- Time to first purchase

**Use Roblox Analytics** (`dashboard-backend/src/analytics/`):
```typescript
// Track custom events
analytics.logEvent("PetHatched", {
  rarity: "Legendary",
  eggType: "Diamond",
  isPaid: true
});

analytics.logEvent("FirstPurchase", {
  productId: "x2SpeedBoost",
  price: 3,
  timeSinceStart: 1847 // seconds
});
```

---

## Build vs. Production Strategy

### Testing in build.rbxl

**Current Setup**: You have `build.rbxl` (124KB) for testing.

**Recommended Workflow**:

1. **Develop in Roblox Studio** using `build.rbxl`
2. **Use Rojo for sync** (`default.project.json`)
3. **Test features locally**:
   - Enable all DevProducts in Studio test mode
   - Mock DataStore2 with profile data
   - Test multipliers with admin commands
4. **Iterate rapidly** (local saves)
5. **When stable**, copy to production map:
   - Use `speed-dash-clean.rbxl` as production base
   - Copy/paste tested models from `build.rbxl`
   - Run `SmokeTest.server.lua` (currently 28/32 passing)
6. **Publish to Roblox** when all tests pass

**Build Testing Checklist**:
```
☐ Pet hatching works (all rarities)
☐ Daily rewards save/load correctly
☐ Promo codes redeem once per player
☐ Battle pass progression tracks
☐ Trading validates items correctly
☐ Friend bonuses calculate accurately
☐ All DataStore operations succeed
☐ No memory leaks (test 60+ min sessions)
☐ UI scales on all screen sizes
☐ Mobile controls work
```

---

## Next Steps

### Week 1: Quick Wins
- [ ] Implement promo codes system
- [ ] Add daily rewards
- [ ] Enhance visual feedback (juice)
- [ ] Create onboarding tutorial

### Week 2-3: Core Features
- [ ] Build pet system (Phase 1 + 2)
- [ ] Implement friends invite system
- [ ] Add zones/worlds (at least 2 new zones)

### Week 4: Monetization
- [ ] Deploy battle pass
- [ ] Optimize shop UI
- [ ] Add bundle deals
- [ ] Launch first season

### Ongoing
- [ ] Monitor analytics
- [ ] Run A/B tests
- [ ] Balance progression
- [ ] Collect player feedback
- [ ] Iterate based on data

---

## Sources

### Monetization
- [Monetisation 101: How to effectively generate revenue in your Roblox Game](https://devforum.roblox.com/t/monetisation-101-how-to-effectively-generate-revenue-in-your-roblox-game/246902)
- [Best way to monetize a game without being too Pay2Win or greedy?](https://devforum.roblox.com/t/best-way-to-monetize-a-game-without-being-too-pay2win-or-greedy/3428955)
- [Most profitable monetization strategies?](https://devforum.roblox.com/t/most-profitable-monetization-strategies/228250)

### Progression & Balance
- [Proper scaling of stats/currency and prices for a simulator game](https://devforum.roblox.com/t/proper-scaling-of-statscurrency-and-prices-for-a-simulator-game/1354994)
- [What is the best way to balance a game?](https://devforum.roblox.com/t/what-is-the-best-way-to-balance-a-game/318086)

### Pet Systems
- [Pet System [Open Source]](https://devforum.roblox.com/t/pet-system-open-source/1141510)
- [Pet follow module [Simulator style]](https://devforum.roblox.com/t/pet-follow-module-simulator-style/901913)
- [Creating a Simulator Pet System](https://devforum.roblox.com/t/creating-a-simulator-pet-system/638078)
- [How to create a pet system that dynamically generates positions](https://devforum.roblox.com/t/how-to-create-a-pet-system-that-dynamically-generates-positions/1860466)

### Daily Rewards & Engagement
- [Do daily rewards actually keep players retention?](https://devforum.roblox.com/t/do-daily-rewards-actually-keep-players-retention/3556728)
- [How to make a Daily Reward System? | Tutorial](https://devforum.roblox.com/t/how-to-make-a-daily-reward-system-tutorial/1515290)
- [How to increase retention, engagement, etc in a simulator](https://devforum.roblox.com/t/how-to-increase-retention-engagement-etc-in-a-simulator/3292053)

### Trading Systems
- [I need help on how to make a pet trading system!](https://devforum.roblox.com/t/i-need-help-on-how-to-make-a-pet-trading-system/431175)
- [Is a trading system a "must have" for a game?](https://devforum.roblox.com/t/is-a-trading-system-a-must-have-for-a-game/285058)

### Battle Pass
- [Official Season Pass Package (Beta)](https://devforum.roblox.com/t/beta-new-feature-packages-season-pass-engagement-rewards/3579550)
- [Level Up - Season Pass Interactive Workshop](https://devforum.roblox.com/t/level-up-season-pass-interactive-workshop/1470549)

### Promo Codes
- [Redeem Code System](https://devforum.roblox.com/t/redeem-code-system/1342240)
- [SR Code Redemption System V2](https://devforum.roblox.com/t/sr-code-redemption-system-v2-a-simple-efficient-code-redemption-system/2025874)
- [Creating a twitter code system for in-game currency](https://devforum.roblox.com/t/creating-a-twitter-code-system-for-in-game-currency/923985)

### Social Features
- [Making a friend boost system](https://devforum.roblox.com/t/making-a-friend-boost-system/2392990)
- [Developer Modules: Instant Social Features](https://devforum.roblox.com/t/developer-modules-instant-social-features/1479221)
- [How to make game more social?](https://devforum.roblox.com/t/how-to-make-game-more-social/1793539)

### Upgrades & Power-ups
- [Upgrading System Numbers](https://devforum.roblox.com/t/upgrading-system-numbers/1880114)
- [How to make timed power ups?](https://devforum.roblox.com/t/how-to-make-timed-power-ups/997783)

### Game Design
- [Game Design Theory: Psychology of Feedback Loops and How to Make Them!](https://devforum.roblox.com/t/game-design-theory-psychology-of-feedback-loops-and-how-to-make-them/63140)
- [How To Improve Player Retention?](https://devforum.roblox.com/t/how-to-improve-player-retention/2574477)

---

**Document Version**: 1.0
**Last Updated**: January 18, 2026
**Total Research Time**: ~2 hours
**Total Sources**: 40+ DevForum threads analyzed
