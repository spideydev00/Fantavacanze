import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'npm:@supabase/supabase-js@2.49.8'
import { JWT } from 'npm:google-auth-library@9'

// Import Firebase service account (must be created in your Firebase console)
import serviceAccount from '../service-account.json' with { type: 'json' }

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('Daily challenge reminder function triggered')
    
    // Create a Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )
    
    // Get current date in Italian timezone (Rome)
    const now = new Date()
    const options = { timeZone: 'Europe/Rome' }
    const italianTime = now.toLocaleString('en-US', options)
    const italianDate = new Date(italianTime)
    
    // Calculate the start of today in Italian time
    const startOfDay = new Date(italianDate)
    startOfDay.setHours(0, 0, 0, 0)
    
    console.log(`Current time in Italy: ${italianDate.toISOString()}`)
    console.log(`Start of day in Italy: ${startOfDay.toISOString()}`)
    
    // Get all active users with FCM tokens
    const { data: activeUsers, error: usersError } = await supabaseClient
      .from('profiles')
      .select('id, name, fcm_token')
      .not('fcm_token', 'is', null)
    
    if (usersError) {
      console.error('Error fetching user data:', usersError)
      throw usersError
    }

    console.log(`Found ${activeUsers?.length || 0} users with FCM tokens`)
    
    if (!activeUsers || activeUsers.length === 0) {
      console.log('No users to check')
      return new Response(
        JSON.stringify({ success: true, message: 'No users to check' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    }
    
    // For each user, check if they have daily challenges for today
    const usersToNotify = []
    
    for (const user of activeUsers) {
      // Check if the user has any daily challenges created today
      const { data: challenges, error: challengesError } = await supabaseClient
        .from('user_daily_challenges')
        .select('id')
        .eq('user_id', user.id)
        .gte('created_at', startOfDay.toISOString())
        .limit(1)
      
      if (challengesError) {
        console.error(`Error checking challenges for user ${user.id}:`, challengesError)
        continue
      }
      
      // If no challenges found, user hasn't logged in today
      if (!challenges || challenges.length === 0) {
        usersToNotify.push(user)
      }
    }
    
    console.log(`Found ${usersToNotify.length} users who need a reminder`)
    
    if (usersToNotify.length === 0) {
      return new Response(
        JSON.stringify({ success: true, message: 'All users have challenges generated' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      )
    }

    // Get access token for FCM
    const accessToken = await getAccessToken({
      clientEmail: serviceAccount.client_email,
      privateKey: serviceAccount.private_key,
    })

    // Send notifications to all users who haven't logged in
    const results = await Promise.all(usersToNotify.map(user => 
      sendFcmMessage({
        token: user.fcm_token,
        title: 'Obiettivi Giornalieri',
        body: `Hey ${user.name || 'utente'}, i tuoi obiettivi giornalieri ti aspettano!!`,
        data: {
          type: 'login_reminder',
          created_at: new Date().toISOString(),
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
