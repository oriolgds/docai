from gradio_client import Client, handle_file
import os

# Configura tu token de HuggingFace
HF_TOKEN = os.getenv("HF_TOKEN")  # Reemplaza con tu token

# Inicializar el cliente con autenticación
client = Client("warshanks/medgemma-27b-it", hf_token=HF_TOKEN)

SYSTEM_PROMPT = "You are a helpful medical expert."
MAX_TOKENS = 2048

def chat_with_model(message, image_path=None):
    try:
        if image_path and os.path.exists(image_path):
            result = client.predict(
                message={"text": message, "files": [handle_file(image_path)]},
                param_2=SYSTEM_PROMPT,
                param_3=MAX_TOKENS,
                api_name="/chat"
            )
        else:
            result = client.predict(
                message={"text": message, "files": []},
                param_2=SYSTEM_PROMPT,
                param_3=MAX_TOKENS,
                api_name="/chat"
            )
        return result
    except Exception as e:
        return f"Error: {str(e)}"

def main():
    print("=" * 60)
    print("Conversación con MedGemma-27B")
    print("=" * 60)
    print("\nComandos:")
    print("  - Escribe tu mensaje")
    print("  - '/imagen <ruta>' para añadir imagen")
    print("  - '/salir' para terminar\n")
    
    image_path = None
    
    while True:
        try:
            user_input = input("\n🧑 Tú: ").strip()
            
            if not user_input:
                continue
            
            if user_input.lower() == '/salir':
                print("\n👋 ¡Hasta luego!")
                break
            
            elif user_input.lower().startswith('/imagen '):
                image_path = user_input.split(' ', 1)[1]
                if os.path.exists(image_path):
                    print(f"\n📷 Imagen cargada: {image_path}")
                else:
                    print(f"\n❌ No se encontró: {image_path}")
                    image_path = None
                continue
            
            print("\n🤖 MedGemma: Pensando...")
            response = chat_with_model(user_input, image_path)
            print(f"\n🤖 MedGemma: {response}")
            
            if image_path:
                image_path = None
                
        except KeyboardInterrupt:
            print("\n\n👋 ¡Hasta luego!")
            break
        except Exception as e:
            print(f"\n❌ Error: {str(e)}")

if __name__ == "__main__":
    main()
