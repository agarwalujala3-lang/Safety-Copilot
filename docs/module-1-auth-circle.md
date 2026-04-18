# Module 1: Auth + Trusted Circle

This module is the foundation for your safety app.

You are learning two tracks:

1. `simple-version`: easiest mental model
2. `real-version`: better team/project structure

---

## What we are building in Module 1

1. Register user
2. Login user
3. Get current logged-in profile
4. Create trusted circle (example: Family)
5. Add member to circle (by phone)
6. View all circles where current user is a member

---

## API flow in plain language

1. User registers with `name + phone + password`.
2. Password is hashed before storage.
3. User logs in and receives a token.
4. Client sends `Authorization: Bearer <token>` for protected routes.
5. User creates a circle.
6. Circle owner adds members using phone number.

---

## Test quickly with curl (Simple version on port 4001)

### 1) Register

```bash
curl -X POST http://localhost:4001/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Akshya\",\"phone\":\"9991112222\",\"password\":\"Pass@123\"}"
```

### 2) Login

```bash
curl -X POST http://localhost:4001/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"phone\":\"9991112222\",\"password\":\"Pass@123\"}"
```

Copy the token from response.

### 3) Create circle

```bash
curl -X POST http://localhost:4001/api/circles ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN" ^
  -d "{\"name\":\"Family\"}"
```

### 4) Add member

```bash
curl -X POST http://localhost:4001/api/circles/CIRCLE_ID/members ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN" ^
  -d "{\"phone\":\"8887776666\",\"label\":\"Brother\"}"
```

### 5) List circles

```bash
curl http://localhost:4001/api/circles/my ^
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Rebuild exercise (important)

Do this in your own copy:

1. Recreate the `register` route without looking.
2. Recreate password hash and verify functions.
3. Recreate `create circle` route and ensure only logged-in users can access it.
4. Add one validation rule: circle name must be at least 3 chars.

If you can do these 4 tasks, you are not copying; you are learning.

---

## What comes next in Module 2

1. Start trip with destination
2. Store live location points
3. Auto-arrival detection with geofence radius
4. Notify trusted members on arrival
