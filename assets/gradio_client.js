// Gradio Client for Flutter using official @gradio/client library
var GRADIO_SPACE = GRADIO_SPACE || 'oriolgds/doky-opus';

async function waitForGradio() {
  let attempts = 0;
  while (!window.gradio && attempts < 50) {
    await new Promise(resolve => setTimeout(resolve, 100));
    attempts++;
  }
  if (!window.gradio) {
    throw new Error('Gradio library failed to load');
  }
}

async function streamChat(message, history, sysPrompt, maxTok, temp) {
  try {
    console.log('Waiting for Gradio library...');
    await waitForGradio();
    
    console.log('Connecting to Gradio space:', GRADIO_SPACE);
    
    const { Client } = window.gradio;
    const client = await Client.connect(GRADIO_SPACE);
    
    console.log('Connected, sending message...');
    
    const result = await client.predict('/send_message', {
      message: message,
      history: history,
      sys_prompt: sysPrompt,
      max_tok: maxTok,
      temp: temp
    });
    
    console.log('Received result:', result);
    
    if (result && result.data) {
      const responseData = result.data;
      
      // Extract assistant response from the result
      if (Array.isArray(responseData) && responseData.length > 0) {
        const lastPair = responseData[responseData.length - 1];
        if (Array.isArray(lastPair) && lastPair.length > 1) {
          const assistantMsg = lastPair[1];
          if (assistantMsg) {
            window.flutter_inappwebview.callHandler('onChunk', assistantMsg);
          }
        }
      }
    }
    
    window.flutter_inappwebview.callHandler('onDone');
  } catch (error) {
    console.error('Gradio client error:', error);
    window.flutter_inappwebview.callHandler('onChunk', 'Error: ' + error.message);
    window.flutter_inappwebview.callHandler('onDone');
  }
}
