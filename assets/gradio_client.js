// Gradio Client for Flutter
var GRADIO_URL = GRADIO_URL || 'https://oriolgds-doky-opus.hf.space';

async function streamChat(message, history, sysPrompt, maxTok, temp) {
  const payload = {
    data: [message, history, sysPrompt, maxTok, temp]
  };

  const response = await fetch(`${GRADIO_URL}/call/send_message`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });

  const eventData = await response.json();
  const eventId = eventData.event_id;
  const streamUrl = `${GRADIO_URL}/call/send_message/${eventId}`;
  
  const eventSource = new EventSource(streamUrl);
  let lastResponse = '';
  
  eventSource.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data);
      
      if (data && data[0] && data[0].length > 0) {
        const lastPair = data[0][data[0].length - 1];
        if (lastPair && lastPair[1]) {
          const assistantMsg = lastPair[1];
          const newText = assistantMsg.substring(lastResponse.length);
          if (newText) {
            window.flutter_inappwebview.callHandler('onChunk', newText);
            lastResponse = assistantMsg;
          }
        }
      }
    } catch (e) {
      console.error('Parse error:', e);
    }
  };

  eventSource.onerror = () => {
    eventSource.close();
    window.flutter_inappwebview.callHandler('onDone');
  };
}
