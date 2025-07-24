# Actbet

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# 🎯 ActBet - Minimal Betting System MVP

ActBet is a simple, production-ready betting system MVP built using the Elixir Phoenix Framework and MySQL. It focuses on football game betting with role-based access control (RBAC) for both regular users and admins.

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

---

### 🔐 Authenticated APIs

**All endpoints below require a valid token**

#### 🧾 Bets

| Method | Endpoint               | Description             |
|--------|------------------------|-------------------------|
| POST   | `/api/bets`            | Place a new bet         |
| GET    | `/api/bets`            | View own bet history    |
| PUT    | `/api/bets/:id/cancel` | Cancel an existing bet  |

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

