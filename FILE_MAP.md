# VS Code File Map

- `client/` = customer website
- `admin/` = separate admin application
- `backend/` = API, authentication, business rules and database access
- `backend/schema.sql` = relational database schema
- `backend/database/seeds/seed.js` = admin + 10 plans + default payment settings
- `.env.example` files = environment templates
- `docs/` = architecture, setup/reference material

Important entry points:

- Client: `client/src/main.js`
- Admin: `admin/src/main.js`
- Backend: `backend/server.js`
