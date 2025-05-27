# Fantavacanze App - League Feature

## Overview

Fantavacanze is a social competition app where users can challenge friends in "leagues" to earn points through various activities. The app is built using:

- **Architecture**: Clean Architecture
- **Framework**: Flutter
- **Database**: Supabase

## Project Structure

The project follows Clean Architecture principles with three main layers:

### 1. Data Layer (`lib/core/data`)

Contains implementations of repositories, data sources, and models that map to domain entities.

#### Data Sources
- **`league_remote_data_source.dart`**: Handles all Supabase API calls
- **`league_local_data_source.dart`**: Manages local data caching using Hive

#### Models
- **`league_model.dart`**: Core model representing a league
- **`event_model.dart`**: Represents challenges/objectives that users complete to earn points
- **`rule_model.dart`**: Defines the rules established during league creation
- **`participant_model.dart`**: Base class for participants, with two implementations:
  - **`individual_participant_model.dart`**: Individual users participating directly
  - **`team_participant_model.dart`**: Teams of users with a captain (team creator)
- **`simple_participant_model.dart`**: Used for team members
- **`memory_model.dart`**: Represents photo memories shared during the vacation
- **`note_model.dart`**: Temporary notes saved in cache as reminders
- **`daily_challenge_model.dart`**: Daily challenges for users to complete
- **`notification_model.dart`**: System notifications, especially for challenge approvals

#### Repository Implementation
- **`league_repository_impl.dart`**: Implements the repository interface with offline support using `ConnectionChecker`

### 2. Domain Layer (`lib/core/domain`)

Contains business logic, entities, and abstract definitions.

#### Entities
Pure data classes without platform-specific dependencies:
- `League`, `Event`, `Rule`, `Participant`, etc.

#### Repository Interface
- **`league_repository.dart`**: Defines all operations that can be performed

#### Use Cases
Single-responsibility classes for each operation:
- `CreateLeague`, `JoinLeague`, `GetUserLeagues`, etc.
- `GetDailyChallenges`, `MarkChallengeAsCompleted`, etc.
- `GetNotifications`, `ApproveChallenge`, etc.

### 3. Presentation Layer (`lib/core/presentation`)

Manages UI, state, and user interactions.

#### BLoC Pattern
- **`league_bloc.dart`**: Main BLoC handling all operations
- **`league_event.dart`**: Events that can be dispatched
- **`league_state.dart`**: Possible states of the UI

#### Pages and Widgets
- Dashboard section with league information
- Team management screens
- Memory sharing pages
- Challenge and notification interfaces

## Core Module (`/lib/core`)

Contains app-wide utilities and shared components:

### Cubits
- **`app_league_cubit.dart`**: Manages selected league state
- **`app_navigation_cubit.dart`**: Handles navigation indices
- **`app_theme_cubit.dart`**: Manages app theme preferences
- **`app_user_cubit.dart`**: Provides access to current user data

### Utils and Widgets
- `show_snackbar.dart`, `image_picker.dart`
- Common widgets like `loader.dart`, `info_container.dart`

### Theme
- `colors.dart`, `sizes.dart`, `theme.dart`
- Extensions: `context_extension.dart`, `colors_extension.dart`

## Dependency Injection

Uses GetIt for dependency injection:
- `init_dependencies.main.dart`: Initializes dependencies
- `init_dependencies.dart`: Imports required paths

## Database Schema

### 1. daily_challenges
```sql
CREATE TABLE IF NOT EXISTS daily_challenges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  points DOUBLE PRECISION NOT NULL,
);
```
Stores challenge templates with name and point values.

### 2. user_daily_challenges
```sql
CREATE TABLE IF NOT EXISTS user_daily_challenges (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  challenge_id UUID NOT NULL REFERENCES daily_challenges(id),
  is_completed BOOLEAN DEFAULT FALSE,
  is_refreshed BOOLEAN DEFAULT FALSE,
  refreshed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  
  UNIQUE(user_id, challenge_id, refreshed_at)
);
```
Tracks user-specific daily challenges and their status.

### 3. notifications
```sql
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_read BOOLEAN DEFAULT FALSE,
  type TEXT NOT NULL, -- 'challengeCompletion', 'teamInvite', etc.
  
  -- Challenge related fields
  challenge_id UUID REFERENCES user_daily_challenges(id) ON DELETE SET NULL,
  challenge_name TEXT,
  challenge_points DOUBLE PRECISION,
  
  -- League reference
  league_id UUID REFERENCES leagues(id) ON DELETE CASCADE,
  
  -- User references
  user_id UUID, -- The user who performed the action
  target_user_id UUID NOT NULL -- The recipient
);
```

### 4. profiles
```sql
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  name TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  is_onboarded BOOLEAN DEFAULT FALSE,
  is_adult BOOLEAN DEFAULT FALSE,
  is_terms_accepted BOOLEAN DEFAULT FALSE
);
```
Stores user profile information including premium status and onboarding state.

Example:
```
id: 05ae046e-e861-45eb-aed1-9ca09be8dd5d
updated_at: 2025-05-20 15:18:06.35343+00
name: Alex
is_premium: false
is_onboarded: true
is_adult: true
is_terms_accepted: true
```

### 5. leagues
```sql
CREATE TABLE IF NOT EXISTS leagues (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_team_based BOOLEAN DEFAULT FALSE,
  invite_code TEXT UNIQUE,
  admins JSONB DEFAULT '[]',
  rules JSONB DEFAULT '[]',
  participants JSONB DEFAULT '[]',
  events JSONB DEFAULT '[]',
  memories JSONB DEFAULT '[]'
);
```
Stores league information including members, rules, events, and shared memories.

Example:
```
id: 11516d9d-dc5b-48ec-9cbe-1794cc962cd4
name: Fanta Ios A Squadre
description: Kalimeraa
created_at: 2025-05-20 17:33:57.885409+00
is_team_based: true
invite_code: d7655626-3...
admins: [...]
rules: [...]
participants: [...]
events: [...]
memories: [...]
```

### 6. auth.users (automatically created)
```
Columns:
- UID
- Display Name
- Email
- Phone (not used in the app)
- Providers
- Provider Type
- Created At
- Last Sign In At
```
Managed by Supabase authentication system.

## Storage

The application uses Supabase Storage for:
- Team logos
- League memory images

## RLS Policies

The application implements the following Row Level Security policies:

1. **League Operations**
   - Only league members can perform operations within the league
   - This ensures data privacy and prevents unauthorized access to league data

2. **Profile Operations**
   - Users can only perform operations on their own profile
   - This protects user information and prevents unauthorized profile changes

## Daily Challenges and Notifications System

### Component Interactions

#### Challenge Completion Flow
1. User views daily challenges on homepage ()
2. User marks a challenge as completed via the UI
3. App calls `markChallengeAsCompleted` in `LeagueBloc`
4. This updates the database record in `user_daily_challenges` and also locally and
if the user is an admin of the league it directly adds the event using `addEvent`. If the user is not an admin creates a new object in `notifications` (this will be sent to the admins, here I need your HELP...)

#### Notification Viewing Flow (TO BE IMPLEMENTED)
HELP ME!


#### Challenge Approval Flow (TO BE IMPLEMENTED - Just an Idea)
1. Admin receives a challenge completion notification (or views it in-app)
2. Admin taps "Approve" button
3. `ApprovalDialog` appears showing:
   - List of participants that can be selected
   - Option to divide points among participants or to apply the "points amount" to each participant
4. On confirmation, app calls method `approveChallenge`
5. This calls the `approve_challenge` function which:
   - Calls `addMultiParticipantEvent` to create events for selected users (can be just one)
   - Adds points to participants (single user, divided among multiple users equally or enitre points added to each member)
   - Deletes the notification

### Premium vs Free Users

The system manages different experiences for premium and free users:

- Free users see all three challenges, but only the first is interactive
- Premium users can interact with all three challenges
- The UI visually indicates locked challenges for free users