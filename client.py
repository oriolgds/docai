import sys
import json
from gradio_client import Client

def main():
    if len(sys.argv) < 5:
        print("Usage: python client.py <message> <history_json> <system_prompt> <temperature>")
        sys.exit(1)
    
    message = sys.argv[1]
    history_json = sys.argv[2]
    sys_prompt = sys.argv[3]
    temp = float(sys.argv[4])
    
    try:
        history = json.loads(history_json) if history_json != "[]" else []
    except:
        history = []
    
    client = Client("oriolgds/doky-opus")
    
    job = client.submit(
        message=message,
        history=history,
        sys_prompt=sys_prompt,
        max_tok=512,
        temp=temp,
        api_name="/send_message"
    )
    
    print("\\response  ", end="", flush=True)
    last_response = ""
    
    for output in job:
        if output:
            chatbot_history, _ = output
            
            if chatbot_history and len(chatbot_history) > 0:
                _, assistant_msg = chatbot_history[-1]
                
                new_text = assistant_msg[len(last_response):]
                if new_text:
                    print(new_text, end="", flush=True)
                    last_response = assistant_msg
    
    print("\n")

if __name__ == "__main__":
    main()
