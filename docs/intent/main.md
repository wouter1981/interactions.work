# interactions.work — Intent

## Why This Exists

Most tools for team collaboration focus on *what* teams produce — tasks, tickets, deliverables. They treat people as resources and relationships as overhead. The tools that do focus on people (employee recognition platforms, HR feedback systems) are locked into the corporate world: they require company emails, org charts, and manager hierarchies.

But the teams that matter most to people aren't always companies. They're the volunteer group you show up for on Saturdays. The sports team that pushes you to be better. The open source project where strangers became collaborators. The cross-organization task force with no shared Slack.

These groups have no HR department. No performance review cycle. No Slack workspace with a kudos bot. Yet they need the same things every team needs: shared values, appreciation, honest feedback, and goals to grow toward.

**interactions.work exists to serve any group of humans that wants to be intentional about how they work together.** Not just companies. Not just developers. Any group — professional, community, volunteer, or something in between.

## The Problem

1. **Enterprise recognition tools don't serve non-corporate teams.** Kudos, Bonusly, and Matter require corporate infrastructure. A sports team can't use them. A volunteer group shouldn't need to.

2. **Retrospective tools are Agile-only.** Retrium and Parabol serve scrum teams. They don't help a community group reflect on how they're doing.

3. **Gratitude apps are solo.** The gratitude journal apps (Gratitude, Orca, 5 Minute Journal) are personal. They have no team dimension. Appreciation happens *between* people, not inside a diary.

4. **OKR tools are corporate performance management.** Betterworks, Quantive, and Engagedly are about company KPIs. Personal development tied to shared values? Not their thing.

5. **Team manifestos live in forgotten documents.** Teams write values on a wiki page or a Notion doc. Nobody reads it after week one. Values need to be embedded in daily actions to stay alive.

**The gap:** No mobile-native app combines shared values with interpersonal interactions (kudos, feedback) and personal development goals — especially for groups that aren't a company.

## Core Beliefs

### The interactions are the product, not the team type

A football team and a consulting firm have different contexts, but the human dynamics are the same: people need to feel appreciated, heard, and challenged to grow. The app serves the universal case.

### Focus on the positive, don't hide from the hard parts

The default mode is appreciation — sending kudos should feel as easy as sending a text. But real growth requires honest feedback too, and sometimes apologies. The app should make both natural, not just the comfortable parts.

### A manifesto is only alive if it's used daily

Values written in a document rot within weeks. By tying kudos directly to manifesto values ("Thanks for showing *Trust* 🤝"), the values become part of daily language. They stop being abstract and start being actionable.

### Private by default, intentional sharing

Personal goals are private. Feedback is private. Sharing is always a conscious choice. The app never exposes something the user didn't explicitly choose to share. This creates the psychological safety needed for honest growth.

### Your data is yours

The device holds the data. The server is a relay, not a repository. End-to-end encryption means even the relay can't read what passes through it. This isn't just a privacy feature — it's a trust statement. We don't want your data. We want you to trust the tool enough to be honest in it.

### Soft skills over hard metrics

Progress on a key result is self-assessed. There are no dashboards showing who got the most kudos. No leaderboards. No gamification. The app measures growth through self-reflection and peer input, not competitive metrics.

## Who It's For

**Primary:** Any group of humans that wants to be intentional about how they work together.

**Use cases:**
- Small professional teams (startups, agencies, consultancies) who care about culture but don't want enterprise HR software
- Sports teams and clubs that want to strengthen team spirit
- Volunteer groups and community organizations
- Open source project teams
- Cross-organization collaborations with no shared infrastructure

**Not for:** Large enterprises looking for performance management. HR departments that need compliance reporting. Anyone who wants to gamify human relationships.

## Pricing Intent

**Free forever, unlimited.** No walls, no limits, no "upgrade to add your 6th team member." The free tier is the real product, not a trial.

**Pro at €10/month flat.** Not per-user. A team of 5 and a team of 50 pay the same. This is a deliberate rejection of the per-seat pricing model that punishes growth. The flat fee makes it predictable and fair.

**Volunteer and community groups: €0 Pro.** If you're not making money from your team, we're not making money from you. Teams self-declare their type. We trust them.

## Privacy Intent

The architecture is device-first and end-to-end encrypted not because it's trendy, but because the content of this app is deeply personal. People sharing feedback, expressing vulnerability, setting personal growth goals — this data is sensitive. It deserves the strongest possible protection.

**What the server knows:** email addresses (for auth), team IDs (for invite links), and that encrypted blobs passed through. That's it.

**What the server never sees:** interaction content, manifesto text, OKR details, who sent kudos to whom.

**GDPR compliance is table stakes, not a feature.** EU-hosted (Hetzner, Germany), minimal data footprint, right to erasure, data portability. We process the minimum needed and retain it only as long as necessary.

## Design Principles

1. **Quick in, quick out.** The core loop is: open, appreciate someone, check your goals, close. Should take 30 seconds to send kudos, 2 minutes to reflect on goals. This is not an app you live in — it's an app that makes your real interactions better.

2. **No account creation friction.** Email and a magic link. No passwords, no social login (unless we add it later for convenience), no onboarding questionnaire. You should be sending your first kudos within 2 minutes of installing.

3. **Native, not cross-platform.** The app handles E2E encryption, WebSocket sync, push notifications, and offline-first data. These are areas where native APIs matter. SwiftUI on iOS, Jetpack Compose on Android. Each app should feel like it belongs on its platform.

4. **Protocol-driven development.** Two native codebases implementing the same spec. The spec is the contract. This enables parallel development and ensures interoperability without coupling the implementations.

5. **The server is deliberately dumb.** The less the server knows, the less can go wrong. Zero-knowledge architecture isn't just privacy — it's operational simplicity. No content moderation decisions, no data breach liability, no complex access control. The server is a pipe.

## Evolution Log

- 2026-03-22: Created during project redesign. Previous git-based architecture scrapped in favor of device-first native apps with E2E encrypted relay sync.
