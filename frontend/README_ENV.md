# Environment Variables Setup

## Securing Supabase Credentials

This app uses environment variables to securely store Supabase credentials. The `.env` file is gitignored and will never be committed to version control.

## Setup Instructions

### 1. Create your `.env` file

Copy the example file:
```bash
cp .env.example .env
```

### 2. Add your Supabase credentials

Open `.env` and replace the placeholder values with your actual Supabase credentials:

```env
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### 3. Where to find your Supabase credentials

1. Go to your Supabase project dashboard: https://app.supabase.com
2. Select your project
3. Go to **Settings** → **API**
4. Copy the **Project URL** (this is your `SUPABASE_URL`)
5. Copy the **anon/public** key (this is your `SUPABASE_ANON_KEY`)

## Security Notes

✅ **DO:**
- Keep your `.env` file local only
- Share `.env.example` (it contains no secrets)
- Add `.env` to `.gitignore` (already done)
- Use the anon key (it's safe for client-side apps)

❌ **DON'T:**
- Commit `.env` to version control
- Share your `.env` file publicly
- Use your service_role key in the app (server-side only)

## File Structure

```
frontend/
├── .env              # Your actual credentials (gitignored)
├── .env.example      # Template file (committed to git)
└── lib/
    └── main.dart     # Loads credentials from .env
```

## Verification

After setting up your `.env` file, the app will:
1. Load credentials on startup
2. Throw an error if credentials are missing
3. Initialize Supabase with your credentials

If you see an error about missing credentials, check that:
- Your `.env` file exists in the `frontend/` directory
- The variable names are correct: `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- There are no extra spaces around the `=` sign


