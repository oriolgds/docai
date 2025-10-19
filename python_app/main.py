import json
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs
from gradio_client import Client
import threading

class DokyHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        params = json.loads(post_data.decode('utf-8'))
        
        message = params.get('message', '')
        history = params.get('history', [])
        sys_prompt = params.get('sys_prompt', '')
        temp = float(params.get('temperature', 0.7))
        
        self.send_response(200)
        self.send_header('Content-type', 'text/event-stream')
        self.send_header('Cache-Control', 'no-cache')
        self.end_headers()
        
        try:
            client = Client("oriolgds/doky-opus")
            
            job = client.submit(
                message=message,
                history=history,
                sys_prompt=sys_prompt,
                max_tok=512,
                temp=temp,
                api_name="/send_message"
            )
            
            last_response = ""
            
            for output in job:
                if output:
                    chatbot_history, _ = output
                    
                    if chatbot_history and len(chatbot_history) > 0:
                        _, assistant_msg = chatbot_history[-1]
                        
                        new_text = assistant_msg[len(last_response):]
                        if new_text:
                            self.wfile.write(f"data: {json.dumps({'text': new_text})}\n\n".encode())
                            self.wfile.flush()
                            last_response = assistant_msg
            
            self.wfile.write(b"data: [DONE]\n\n")
        except Exception as e:
            error_data = json.dumps({'error': str(e)})
            self.wfile.write(f"data: {error_data}\n\n".encode())
    
    def log_message(self, format, *args):
        pass

def run_server():
    port = 8765
    server = HTTPServer(('127.0.0.1', port), DokyHandler)
    print(f"Server running on port {port}")
    server.serve_forever()

if __name__ == "__main__":
    run_server()
