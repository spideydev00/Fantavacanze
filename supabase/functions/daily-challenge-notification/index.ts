// Import from npm instead of JSR as suggested in error message
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'npm:@supabase/supabase-js@2.49.8'
import { JWT } from 'npm:google-auth-library@9'

// You need to create this file from your Firebase console
// Project Settings > Service Accounts > Generate new private key
import serviceAccount from '../service-account.json' with { type: 'json' }

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Define interfaces for our notification types
interface DailyChallengeNotification {
  id: string
  title: string
  message: string
  created_at: string
  is_read: boolean
  type: string
  user_id: string
  league_id: string
  challenge_id: string
  challenge_name: string
  challenge_points: number
  target_user_ids: string[]
}

interface WebhookPayload {
  type: 'INSERT' | 'UPDATE' | 'DELETE'
  table: string
  record: DailyChallengeNotification
  schema: 'public'
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('Edge function triggered')
    
    // Create a Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    // Parse request body
    let payload: WebhookPayload;
    try {
      payload = await req.json();
      console.log('Parsed payload:', JSON.stringify(payload))
    } catch (e) {
      console.error('Error parsing request body:', e);
      return new Response(
        JSON.stringify({ error: 'Invalid JSON in request body' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      );
    }

    // Get data about the notification
    const record = payload.record;
    
    if (!record) {
      console.error('No record found in payload:', payload);
      return new Response(
        JSON.stringify({ error: 'No notification record in request' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      );
    }
    
    console.log('Received notification record:', JSON.stringify(record, null, 2))

    // Get admin user FCM tokens
    const admins = record.target_user_ids || []
    
    console.log(`Fetching FCM tokens for ${admins.length} admin users`)
    
    // Fetch FCM tokens for all admins
    const { data: usersData, error: usersError } = await supabaseClient
      .from('profiles')
      .select('id, fcm_token, name')
      .in('id', admins)
      .not('fcm_token', 'is', null)
    
    if (usersError) {
      console.error('Error fetching user data:', usersError)
      throw usersError
    }

    console.log(`Found ${usersData?.length || 0} admins with FCM tokens`)
    
    if (!usersData || usersData.length === 0) {
      console.log('No valid FCM tokens found')
      return new Response(
        JSON.stringify({ success: true, message: 'No valid FCM tokens found' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    }
    
    const fcmTokens = usersData.map(user => user.fcm_token).filter(Boolean)
    console.log(`Filtered to ${fcmTokens.length} valid FCM tokens`)

    // Get access token for FCM
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    })

    // Send notifications to all valid tokens
    const results = await Promise.all(fcmTokens.map(token => 
      sendFcmMessage({
        token,
        title: record.title || 'Nuova sfida completata',
        body: record.message || 'Un utente ha completato una sfida giornaliera',
        data: {
          type: 'daily_challenge',
          challenge_id: record.challenge_id,
          notification_id: record.id,
          league_id: record.league_id,
          created_at: record.created_at,
        },
        accessToken,
        projectId: serviceAccount.project_id
      })
    ))
    
    console.log(`Sent ${results.filter(r => r.success).length} notifications successfully`)

    return new Response(
      JSON.stringify({ 
        success: true, 
        sent_to: results.filter(r => r.success).length,
        errors: results.filter(r => !r.success).length
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      },
    )
  }
})

// Helper function to get OAuth access token
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

// Helper function to send FCM message using fetch and v1 API
async function sendFcmMessage({
  token,
  title,
  body,
  data,
  accessToken,
  projectId
}) {
  try {
    console.log(`Sending FCM message to token: ${token.substring(0, 10)}...`)
    
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${accessToken}`
        },
        body: JSON.stringify({
          message: {
            token: token,
            notification: {
              title,
              body,
            },
            data
          }
        })
      }
    );
    
    if (!response.ok) {
      const errorText = await response.text();
      console.error('FCM send error:', errorText);
      return { success: false, error: errorText };
    }
    
    const responseData = await response.json();
    console.log('FCM response:', JSON.stringify(responseData));
    return { success: true, response: responseData };
  } catch (error) {
    console.error('Error sending FCM message:', error);
    return { success: false, error: error.message };
  }
}