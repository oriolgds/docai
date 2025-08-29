DocAI - Your Personal AI Doctor
DocAI is a mobile application built with Flutter that acts as a personal AI-powered doctor. It features a smart chat interface (using a ChatGPT wrapper), chat history, predefined health presets (e.g., medications, natural remedies), a profile page for subscription management, and a minimalist login screen. This README provides instructions to set up, install, and run the app on your local machine.
Prerequisites
Before you begin, ensure you have the following installed:

Flutter SDK (version 3.0 or higher)
Install from flutter.dev.
Run flutter doctor to verify setup.


Dart (included with Flutter)
Android Studio or VS Code with Flutter and Dart plugins
Android Emulator or physical Android device (for Android)
Xcode (for iOS, macOS only)
Node.js and npm (for potential future web builds, optional)
Git (for cloning the repository)
Accounts and API keys:
Supabase account (supabase.com)
OpenAI API Key (openai.com)



Installation
1. Clone the Repository
git clone https://github.com/yourusername/docai.git
cd docai

2. Install Dependencies
Run the following command to fetch all required packages:
flutter pub get

3. Set Up Environment Variables
Create a .env file in the project root and add your API keys:
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
OPENAI_API_KEY=your_openai_api_key


Obtain the Supabase URL and anon key from your Supabase project dashboard.
Get the OpenAI API key from your OpenAI account.

4. Configure Supabase

Create a new project on Supabase.
Enable email authentication in the Supabase dashboard.
Create the following tables:
users (id, email, subscription_level)
chats (id, user_id, timestamp, content)
subscriptions (id, user_id, plan, expiry_date)


Update the Supabase client initialization in lib/main.dart with your project URL and anon key (if not using .env).

5. Set Up Flutter

Ensure an emulator or device is connected:
For Android: Open Android Studio, create a virtual device, and start it.
For iOS: Open Xcode, create a simulator, and start it.


Run flutter devices to list available devices.

Running the App
1. Build and Run
Execute the following command to start the app:
flutter run


Select the desired device from the list if multiple are connected.
The app will launch on the chosen emulator or device.

2. Initial Setup

Upon first launch, the app will display the login screen.
Use a test email (e.g., test@example.com) and password to log in (ensure these are registered in Supabase or modify the auth logic for testing).
The dashboard will appear, allowing access to the chat, history, and profile screens.

3. Testing Features

Chat: Type a health-related query (e.g., "What are the side effects of aspirin?") to test the OpenAI integration.
Presets: Select a preset (e.g., "Medicaments" or "Natural Remedies") to prefill the chat input.
History: View past chats in the history section.
Profile: Manage subscription status (mock data for now unless integrated with a payment provider like Stripe).

Configuration and Customization

Theme: The app uses a black-and-white minimalist theme. Modify lib/theme.dart to adjust colors or styles.
API Endpoints: Update API call URLs in lib/services/api_service.dart if needed.
Supabase Schema: Adjust table structures in Supabase based on additional requirements.

Troubleshooting

Flutter Issues: Run flutter clean and flutter pub get if dependencies fail to load.
API Errors: Verify .env file contents and network connectivity.
Build Errors: Ensure Xcode/Android SDK tools are updated.

Contributing

Fork the repository.
Create a new branch (git checkout -b feature-branch).
Make changes and commit (git commit -m "Add new feature").
Push to the branch (git push origin feature-branch).
Open a pull request.

License
This project is licensed under the MIT License - see the LICENSE.md file for details.
Acknowledgments

Built with Flutter.
Backend powered by Supabase.
AI integration using OpenAI API.
