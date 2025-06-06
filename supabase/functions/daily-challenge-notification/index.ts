import { createClient } from 'npm:@supabase/supabase-js@2'
import { JWT } from 'npm:google-auth-library@9'
import serviceAccount from '../service-account.json' with { type: 'json' }

interface DailyChallengeNotification {
  id: string
  title: string
  message: string
  user_id: string
  league_id: string
  challenge_id: string
  target_user_ids: string[]
}

interface WebhookPayload {
  type: 'INSERT'
  table: string
  record: DailyChallengeNotification
  schema: 'public'
}

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

Deno.serve(async (req) => {
  try {
    console.log('🔔 Edge function triggered at', new Date().toISOString());

    // Parse the webhook payload
    const payload: WebhookPayload = await req.json();
    const record = payload.record;

    if (!record) {
      throw new Error('No notification record in request');
    }

    console.log('Received notification record:', JSON.stringify(record, null, 2));

    // Get admin user FCM tokens
    const admins = record.target_user_ids || [];
    console.log(`Fetching FCM tokens for ${admins.length} admin users`);

    // Fetch FCM tokens for all admins
    const { data: usersData, error: usersError } = await supabase
      .from('profiles')
      .select('id, fcm_token, name')
      .in('id', admins)
      .not('fcm_token', 'is', null);

    if (usersError) {
      throw usersError;
    }

    if (!usersData || usersData.length === 0) {
      console.log('No valid FCM tokens found');
      return new Response(
        JSON.stringify({ success: true, message: 'No valid FCM tokens found' }),
        { headers: { 'Content-Type': 'application/json' } }
      );
    }

    const fcmTokens = usersData.map(user => user.fcm_token).filter(Boolean);
    console.log(`Filtered to ${fcmTokens.length} valid FCM tokens`);

    // Get access token for FCM
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    });

    // Send notifications to all valid tokens
    const results = await Promise.all(fcmTokens.map(async (token) => {
      try {
        const res = await fetch(
          `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${accessToken}`,
            },
            body: JSON.stringify({
              message: {
                token: token,
                notification: {
                  title: record.title || 'Nuova sfida completata',
                  body: record.message || 'Un utente ha completato una sfida giornaliera',
                },
                data: {
                  id: record.id,
                  type: 'daily_challenge',
                  challenge_id: record.challenge_id,
                  league_id: record.league_id,
                  title: record.title || 'Nuova sfida completata',
                  message: record.message || 'Un utente ha completato una sfida giornaliera',
                  user_id: record.user_id || '',
                  challenge_name: record.challenge_name || '',
                  challenge_points: record.challenge_points?.toString() || '0',
                  created_at: record.created_at || new Date().toISOString(),
                  is_read: 'false',
                  target_user_ids: Array.isArray(record.target_user_ids)
                    ? record.target_user_ids.join(',')
                    : typeof record.target_user_ids === 'string'
                      ? record.target_user_ids
                      : ''
                }
              }
            })
          }
        );

        if (!res.ok) {
          const errorText = await res.text();
          console.error('FCM send error:', errorText);
          return { success: false };
        }

        return { success: true };
      } catch (error) {
        console.error('Error sending FCM message:', error);
        return { success: false };
      }
    }));

    const successCount = results.filter(r => r.success).length;
    console.log(`Sent ${successCount} notifications successfully`);

    return new Response(
      JSON.stringify({
        success: true,
        sent_to: successCount
      }),
      { headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error) {
    console.error('Error:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { 'Content-Type': 'application/json' },
        status: 500
      }
    );
  }
});

const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string
  privateKey: string
}): Promise<string> => {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err)
        return
      }
      resolve(tokens!.access_token!)
    })
  })
}