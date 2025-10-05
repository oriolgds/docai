import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

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
    // Only allow POST requests
    if (req.method !== 'POST') {
      throw new Error('Method not allowed')
    }

    // Get the Authorization header from the request
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Authorization header is required')
    }

    // Parse request body
    const { apiKey, provider = 'openrouter' } = await req.json()
    if (!apiKey || typeof apiKey !== 'string') {
      throw new Error('apiKey is required and must be a string')
    }

    // Verify the API key by making a test request to OpenRouter
    const isValid = await verifyApiKey(apiKey, provider)

    return new Response(
      JSON.stringify({
        success: true,
        valid: isValid
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error verifying API key:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        valid: false
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})

async function verifyApiKey(apiKey: string, provider: string): Promise<boolean> {
  try {
    if (provider === 'openrouter') {
      // Test request to OpenRouter models endpoint (doesn't cost credits)
      const response = await fetch('https://openrouter.ai/api/v1/models', {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
      })

      // If status is 200, the key is valid
      return response.status === 200
    }

    // For other providers, you can add similar verification logic
    throw new Error(`Provider ${provider} not supported for verification`)

  } catch (error) {
    console.error('Error during API key verification:', error)
    return false
  }
}