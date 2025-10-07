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

    // Parse request body with better error handling
    let body: any
    try {
      const bodyText = await req.text()
      if (!bodyText || bodyText.trim() === '') {
        throw new Error('Request body is empty')
      }
      body = JSON.parse(bodyText)
    } catch (parseError) {
      console.error('JSON parsing error:', parseError)
      throw new Error('Invalid JSON in request body')
    }

    const { apiKey, provider = 'openrouter' } = body

    // Validate apiKey more thoroughly
    if (!apiKey) {
      throw new Error('apiKey is required')
    }
    
    if (typeof apiKey !== 'string') {
      throw new Error('apiKey must be a string')
    }
    
    const trimmedApiKey = apiKey.trim()
    if (trimmedApiKey === '') {
      throw new Error('apiKey cannot be empty')
    }

    // Validate API key format for OpenRouter
    if (provider === 'openrouter' && !isValidOpenRouterKeyFormat(trimmedApiKey)) {
      throw new Error('Invalid API key format. OpenRouter keys should start with "sk-or-" or "sk-"')
    }

    console.log(`Verifying API key for provider: ${provider}`)

    // Verify the API key by making a test request to OpenRouter
    const isValid = await verifyApiKey(trimmedApiKey, provider)

    return new Response(
      JSON.stringify({
        success: true,
        valid: isValid,
        provider: provider
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error verifying API key:', error)

    // Determine appropriate status code
    let statusCode = 400
    if (error.message.includes('Rate limit')) {
      statusCode = 429
    } else if (error.message.includes('Authorization')) {
      statusCode = 401
    }

    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
        valid: false
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: statusCode,
      }
    )
  }
})

function isValidOpenRouterKeyFormat(apiKey: string): boolean {
  // OpenRouter API keys should start with sk-or- or sk- and be at least 20 characters
  return apiKey.length >= 20 && (apiKey.startsWith('sk-or-') || apiKey.startsWith('sk-'))
}

async function verifyApiKey(apiKey: string, provider: string): Promise<boolean> {
  try {
    if (provider === 'openrouter') {
      console.log('Making test request to OpenRouter API')
      
      // Create abort controller for timeout
      const controller = new AbortController()
      const timeoutId = setTimeout(() => controller.abort(), 10000) // 10 second timeout
      
      try {
        // Test request to OpenRouter models endpoint (doesn't cost credits)
        const response = await fetch('https://openrouter.ai/api/v1/models', {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${apiKey}`,
            'Content-Type': 'application/json',
            'HTTP-Referer': 'https://docai.app',
            'X-Title': 'DocAI App'
          },
          signal: controller.signal
        })
        
        clearTimeout(timeoutId)
        
        console.log(`OpenRouter API response: ${response.status} - ${response.statusText}`)
        
        // If status is 200, the key is valid
        if (response.status === 200) {
          console.log('API key is valid')
          return true
        }
        
        // Check for specific error responses
        if (response.status === 401) {
          console.log('API key is invalid (401 Unauthorized)')
          return false
        }
        
        if (response.status === 429) {
          throw new Error('Rate limit exceeded. Please try again later.')
        }
        
        // For other non-200 responses, try to get more details
        if (response.status >= 400) {
          try {
            const errorData = await response.json()
            console.log('Error response data:', errorData)
            if (errorData.error && errorData.error.message) {
              throw new Error(`OpenRouter API error: ${errorData.error.message}`)
            }
          } catch (jsonError) {
            // If we can't parse JSON, just use status text
            console.log('Could not parse error response as JSON')
          }
          
          throw new Error(`OpenRouter API returned status ${response.status}: ${response.statusText}`)
        }
        
        return false
        
      } catch (fetchError) {
        clearTimeout(timeoutId)
        
        if (fetchError.name === 'AbortError') {
          throw new Error('Request timeout. Please check your connection and try again.')
        }
        
        throw fetchError
      }
    }

    // For other providers, you can add similar verification logic
    throw new Error(`Provider ${provider} not supported for verification`)

  } catch (error) {
    console.error('Error during API key verification:', error)
    
    // Re-throw specific errors that should be shown to the user
    if (error.message.includes('Rate limit') || 
        error.message.includes('timeout') ||
        error.message.includes('OpenRouter API error')) {
      throw error
    }
    
    // For other errors, return false (invalid key) rather than throwing
    // This prevents network errors from being confused with invalid keys
    console.log('Treating verification error as invalid key:', error.message)
    return false
  }
}