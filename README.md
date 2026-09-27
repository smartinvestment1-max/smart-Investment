# SmartInvestment — Complete Client + Admin + Backend

This project is intentionally split into **three runnable applications**:

1. `client/` — customer-facing SmartInvestment website.
2. `admin/` — separate SmartInvestment Admin Panel.
3. `backend/` — secure Node.js + Express API connected to MySQL.

The client and admin never share a page. They communicate only through the backend API and shared database.

## Visual direction

The Admin Panel follows the supplied reference: dark navy/black interface, cyan/teal highlights, compact typography, left sidebar, top navigation, rounded cards, data tables, status badges, charts, quick summary cards and responsive layouts.

## Main admin modules

- Admin Login
- Dashboard / Overview
- Users Management
- Deposit Verification
- Withdrawal Management
- Investment Plans (10 plans)
- Payment Settings
- Transaction History
- Referral Management
- Settings & Security
- Audit logs

## Main customer modules

- Register / Login
- Dashboard
- Investment Plans
- Deposit
- My Investments
- Withdrawal
- Transactions
- Referrals
- Profile / Password change

## Backend security model

- Password hashing with bcryptjs
- JWT authentication
- Separate user/admin roles
- Server-side authorization for admin routes
- Server-side validation
- Database transactions for deposits, withdrawals and investments
- Duplicate transaction protection
- Audit logs for admin actions
- Environment variables for secrets
- Payment screenshots stored outside the frontend

## Database

Run `backend/schema.sql` in MySQL first. It creates:

- admins
- users
- investment_plans
- payment_settings
- deposits
- investments
- withdrawals
- transactions
- referrals
- referral_rewards
- notifications
- audit_logs
- platform_settings

## Local setup

### 1. Requirements

- Node.js 20+
- MySQL 8+
- VS Code

### 2. Database

Create/import the database schema:

```sql
SOURCE backend/schema.sql;
```

Or open `backend/schema.sql` in MySQL Workbench and execute it.

### 3. Backend environment

Copy:

```text
backend/.env.example -> backend/.env
```

Set your MySQL password and a strong `JWT_SECRET`.

### 4. Install dependencies

From the project root:

```bash
npm install
npm install --prefix backend
npm install --prefix client
npm install --prefix admin
```

### 5. Seed admin, 10 plans and payment settings

```bash
npm run seed --prefix backend
```

Default seed admin is controlled by `.env`:

```text
Username: admin
Email: admin@smartinvestment.local
Password: Admin@12345
```

Change this before any real deployment.

### 6. Start everything

Option A — separate terminals:

```bash
npm run dev --prefix backend
npm run dev --prefix client
npm run dev --prefix admin
```

URLs:

- Client: http://localhost:5173
- Admin: http://localhost:5174
- API: http://localhost:4000

Option B — root command after installing `concurrently`:

```bash
npm install
npm run dev
```

## Important financial workflow

Deposit:

Customer → Deposit request → Backend → Database → Admin review → Approve/Reject.

On approval, the backend transactionally updates the user's verified balance, deposit status and transaction ledger, then records an audit entry.

Investment:

Customer selects a plan → backend locks/checks balance → creates investment using a snapshot of the plan's rate/duration → deducts balance → creates transaction.

If an admin later changes a plan, existing investments retain the original stored terms.

Withdrawal:

Customer submits request → pending/processing → admin completes or rejects. The backend rechecks balance and deducts funds only when the withdrawal is completed.

Payment settings:

Admin changes EasyPaisa/JazzCash/Bank details → database → backend → client Deposit page. Payment details are not hard-coded in the client.

## Deployment note

This is a complete development foundation. Before production use, configure HTTPS, a strong secret, restricted CORS, secure hosting, database backups, monitoring, proper payment verification procedures, legal/compliance requirements for the jurisdiction, and a production-grade file-storage strategy.
