# Generate Hive adapter code and other generated files

dart run build_runner build --delete-conflicting-outputs

# Deploy both edge functions to Supabase

supabase functions deploy daily-challenge-notification --no-verify-jwt
supabase functions deploy daily-challenge-reminder --no-verify-jwt

# If you need to test the functions locally first:

supabase functions serve daily-challenge-notification --env-file .env.local
supabase functions serve daily-challenge-reminder --env-file .env.local

./gradlew --stop
