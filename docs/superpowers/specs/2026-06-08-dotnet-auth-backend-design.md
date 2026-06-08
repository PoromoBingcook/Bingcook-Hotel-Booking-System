# .NET Auth Backend Design

## Scope

Add a .NET 8 Web API backend for BingCook registration and login. The backend
uses the existing PostgreSQL schema from `BookingDB.sql`, especially the
`"User"` table, and does not change the current Flutter presentation flow yet.

## Architecture

- Create a focused backend project under `backend/BingCook.Api`.
- Use ASP.NET Core Web API on .NET 8.
- Use Npgsql with a small repository layer for PostgreSQL access.
- Keep authentication logic in an `AuthService`.
- Keep JWT creation in a separate `JwtTokenService`.
- Use BCrypt password hashes in the existing `"User"."Password"` column.
- Do not introduce ASP.NET Core Identity because the provided schema already
  defines the user table and the required behavior is small.

## API

`POST /api/auth/register`

- Accepts `fullName`, `email`, `phone`, and `password`.
- Requires full name, email, phone, and password.
- Rejects invalid email format.
- Rejects passwords shorter than 8 characters.
- Rejects duplicate email or phone.
- Creates a `Customer` user with a BCrypt password hash.
- Returns the created user summary and JWT.

`POST /api/auth/login`

- Accepts `identity` and `password`.
- Allows `identity` to be either email or phone.
- Finds the user by normalized email or phone.
- Verifies the BCrypt password hash.
- Returns the user summary and JWT on success.
- Returns a safe generic error for invalid credentials.

## Data Flow

Controllers validate request shape and call `AuthService`. `AuthService`
normalizes input, enforces auth rules, hashes or verifies passwords, and calls
`UserRepository`. `UserRepository` is the only code that reads or writes the
`"User"` table. `JwtTokenService` creates signed tokens containing user id,
email, phone, full name, and role claims.

## Error Handling

- Duplicate email or phone returns HTTP 409.
- Invalid register input returns HTTP 400.
- Invalid login credentials return HTTP 401.
- Unexpected database failures return HTTP 500 without exposing secrets.
- Passwords and JWT values are never logged.

## Testing

Add backend tests for:

- Successful registration hashes the password and returns a token.
- Registration rejects duplicate email or phone.
- Login accepts email as identity.
- Login accepts phone as identity.
- Login rejects wrong password.

Run `dotnet test` for backend verification after implementation.
