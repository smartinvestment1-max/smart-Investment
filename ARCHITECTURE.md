# SmartInvestment Architecture

```text
                 MySQL Database
                       ▲
                       │
                Secure Backend API
                 Node + Express
                  ▲           ▲
                  │           │
             Customer UI   Admin UI
              port 5173    port 5174
```

The two interfaces are separate applications. They are not merged into one page and the admin routes are not exposed as customer pages.

## Data authority

The backend/database is authoritative for:

- balances
- deposits
- withdrawals
- investments
- transaction history
- payment settings
- referral rewards
- account status
- admin permissions

The frontend only displays state received from the backend and submits validated requests.
