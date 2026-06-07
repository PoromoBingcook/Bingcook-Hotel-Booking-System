# Auth, Success, And Explore Design

## Scope

Implement the approved Figma screens for Login, Login Success, and Explore.
Fix Sign Up field icons so they remain left-aligned. Add reusable bottom
navigation and navigation between the new screens. No backend, authentication,
or remote data logic is included.

## Architecture

- `app/routes/` owns route names and route construction.
- Auth screens remain under `ui/features/auth/`.
- Login Success is a focused auth view with a local animation controller.
- `MainShell` owns bottom-navigation state.
- Explore content remains under `ui/features/explore/`.
- Shared navigation UI lives in `ui/core/widgets/`.
- Static stay data is presentation data; no repository or domain layer is
  created until real data access exists.

## Flow

1. Splash automatically opens Sign Up.
2. Sign Up footer opens Login.
3. Login footer returns to Sign Up.
4. Login button opens Login Success.
5. Login Success animates its progress bar from empty to full.
6. Completed progress replaces the auth flow with the Explore shell.
7. Bottom navigation switches among Explore, Saved, Bookings, and Profile.

## Testing

- Widget test Sign Up prefix icon alignment.
- Widget test Login content and Login-to-Success navigation.
- Widget test Success progress animation and Explore redirect.
- Widget test bottom-navigation selection.
- Existing ViewModel tests remain unchanged.

