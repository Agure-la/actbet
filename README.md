# Actbet

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# 🎯 ActBet - Minimal Betting System MVP

ActBet is a simple, production-ready betting system MVP built using the Elixir Phoenix Framework and MySQL. It focuses on football game betting with role-based access control (RBAC) for both regular users and admins.

---

## 📌 Project Purpose

This system allows users to place bets on football matches, with flexible odds and bet selections. It supports:

- Regular users placing and tracking bets.
- Admins managing user activity.
- Superadmins configuring games, managing admins, and triggering bet result evaluations.

---

## 📌 Features

### ✅ User Features (Frontend Users)

- Register and log in using phone number and password.
- View available football games.
- Place bets on football games.
- Cancel placed bets (if not yet resolved).
- View bet history.
- View a summary of personal winnings and losses.

### ✅ Admin Features

- View any user's profile and their betting history.
- Soft-delete users and all associated data.
- View the platform's total profit (sum of all lost bets).

### ✅ Superuser Admin Features

- Add or configure new sport games.
- Update game results and mark them as finished.
- Grant or revoke admin access from other users.
- Send out emails for bet wins or losses.

---

## 🗄️ Database Highlights

- **Tables**: `users`, `roles`, `permissions`, `roles_permissions`, `games`, `bets`, `bet_selections`
- **Constraints**:
  - Users can only bet on a game once per bet
  - A bet can contain multiple selections
  - A bet is marked as *won* only if **all** selections match the game's final result

---

## ⏲️ Background Job

A background job runs periodically and performs:

- For each completed game, match user selections against the result
- Mark bets as `won` or `lost` based on selections
- Send an **email** to winners

---

## 🚀 Technology Stack

- **Backend**: Elixir + Phoenix
- **Database**: MySQL
- **Authentication**: JWT (stored in `Authorization` header as `Bearer <token>`)
- **RBAC**: Role-based access via `roles` and `permissions`

---

## 🔐 Authentication

- JWT-based authentication system.
- All authenticated API endpoints require the `Authorization: Bearer <token>` header.

---

## 🔧 API Endpoints

### 📂 Non-authenticated APIs

| Method | Endpoint         | Description         |
|--------|------------------|---------------------|
| POST   | `/register`      | Register a new user |
| POST   | `/login`         | Login and get token |

### 📦 Sample Request: Register User

Registers a new user with required credentials.

```json
{
  "user": {
    "first_name": "John",
    "last_name": "Doe",
    "email_address": "john@example.com",
    "msisdn": "254700000124",
    "password": "secretpass"
  }
}
---

### 🔐 Authenticated APIs

**All endpoints below require a valid token**

#### 🧾 Bets

| Method | Endpoint               | Description             |
|--------|------------------------|-------------------------|
| POST   | `/api/bets`            | Place a new bet         |
| GET    | `/api/bets`            | View own bet history    |
| PUT    | `/api/bets/:id/cancel` | Cancel an existing bet  |

### 📦 Sample Request: Place Bet

Place a new bet.

```json
{
  "bet": {
    "amount": "1000",
    "selections": [
      {
        "game_id": 6,
        "choice": "home"
      },
      {
        "game_id": 5,
        "choice": "draw"
      }
    ]
  }
}
#### 💰 Profits

| Method | Endpoint              | Description            |
|--------|-----------------------|------------------------|
| GET    | `/api/total_profit`   | View total platform profit (admin only) |

#### 🏟️ Games

| Method | Endpoint                     | Description               |
|--------|------------------------------|---------------------------|
| GET    | `/api/games`                 | List all active games     |
| GET    | `/api/games/:id`             | View specific game details |
| POST   | `/api/games`                 | Add a new game (superuser) |
| PUT    | `/api/games/:id/result`      | Set game result (superuser) |
| PATCH  | `/api/games/:id/finish`      | Finalize game (superuser) |

### 📦 Sample Request: Create Game

Create a new game.

```json
{
  "game": {
    "home_team": "Liver",
    "away_team": "postmouth",
    "start_time": "2025-07-21T12:00:00Z",
    "status": "active",
    "bet_odds": {
      "home": 1.69,
      "away": 4.2,
      "draw": 3.00,
      "gg": 1.40,
      "ng": 2.6,
      "ov2.5": 1.56,
      "un2.5": 2.07,
      "1x": 1.03,
      "2x": 3.6
    }
  }
}

update game result.

```json
{
  "result": "home"
}
#### 👤 Users

| Method | Endpoint                     | Description                          |
|--------|------------------------------|--------------------------------------|
| GET    | `/api/users_with_bets`       | View users and their bets (admin)    |
| PUT    | `/api/users/:id`             | Soft-delete a user (admin)           |
| PUT    | `/api/users/:id/role`        | Grant/Revoke admin rights (superuser) |

---

## 🏗️ Setup Instructions

### 1. Clone the Repository

```bash
git clone repo
cd actbet

