# MedGemma Gradio API Integration for Flutter App

## Project Context
You are working on a Flutter medical AI app called "DocAI" that currently uses OpenRouter for chat functionality. The app has:
- Existing chat system with `ChatMessage` model
- Image support capability 
- Medical-focused system prompts
- Supabase backend integration
- Firebase analytics/crashlytics
- Multi-language support (Spanish/English)

## Task: Integrate MedGemma 27B IT Model

Integrate the MedGemma 27B IT model from Hugging Face Spaces into the existing Flutter app to provide medical image analysis capabilities.

### API Details
- **Base URL**: `https://warshanks-medgemma-27b-it.hf.space/gradio_api`
- **Endpoint**: `/call/chat`
- **Method**: POST for initial call, GET for streaming response
- **Model**: MedGemma 27B IT (medical-specialized Gemma model)
- **Capabilities**: Text + Image analysis, medical expertise

### API Call Pattern
1. **Initial POST call** to `/gradio_api/call/chat` returns `{"event_id": "xxx"}`
2. **Streaming GET call** to `/gradio_api/call/chat/{event_id}` returns Server-Sent Events

### Request Format
```json
{
  "data": [
    {
      "text": "User's question about the image",
      "files": [
        {
          "path": "image_url_or_base64",
          "url": "image_url", 
          "orig_name": "filename.jpg",
          "size": null,
          "mime_type": "image/jpeg",
          "is_stream": false,
          "meta": {"_type": "gradio.FileData"}
        }
      ]
    },
    [],  // conversation history (empty for new conversation)
    "You are a helpful medical expert.",  // system prompt
    2048  // max tokens
  ]
}
```

## Implementation Requirements

### 1. Create MedGemma Service Class
Create `lib/services/medgemma_service.dart` with:

```dart
class MedGemmaService {
  static const String baseUrl = 'https://warshanks-medgemma-27b-it.hf.space/gradio_api';
  static const String defaultSystemPrompt = 'You are a helpful medical expert. Analyze medical images and provide detailed, accurate information. Always remind users to consult healthcare professionals for diagnosis and treatment.';
  
  // Methods to implement:
  - Future<String> analyzeImageWithText(File imageFile, String userQuestion)
  - Future<String> analyzeImageFromUrl(String imageUrl, String userQuestion) 
  - Stream<String> streamAnalysis(String eventId)
  - Map<String, dynamic> _createGradioFileData(String imagePath, String mimeType, String originalName)
}
```

### 2. Extend ChatMessage Model
Extend `lib/models/chat_message.dart` to support:

```dart
class ChatMessage {
  // Add new fields:
  final String? imageUrl;
  final String? imageBase64;
  final bool isImageAnalysis;
  final String? analysisProvider; // 'openrouter', 'medgemma'
  
  // Add methods:
  - Map<String, dynamic> toMedGemmaMessage()
  - bool get hasImage
  - static ChatMessage imageAnalysis(String text, String imageData, {String? provider})
}
```

### 3. Update Pubspec Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  image_picker: ^1.0.4    # For image selection
  mime: ^1.0.4            # For MIME type detection
  path: ^1.8.3            # For file path operations
```

### 4. Create Image Analysis Screen
Create `lib/screens/image_analysis_screen.dart` with:
- Image picker (camera/gallery)
- Text input for question
- Provider selection (OpenRouter vs MedGemma)
- Analysis results display
- Save to chat history functionality

### 5. Add Image Analysis Widget
Create `lib/widgets/image_analysis_widget.dart` with:
- Image preview
- Question input field
- Provider toggle
- Analysis button
- Loading states
- Error handling

### 6. Update Chat Screen Integration
Modify existing chat screen to:
- Add image analysis button
- Display image messages with thumbnails
- Show analysis provider badge
- Handle mixed text/image conversations

### 7. Error Handling & Edge Cases
Implement comprehensive error handling for:
- Network connectivity issues
- Invalid image formats
- API rate limits
- Large file sizes
- Streaming interruptions
- CORS issues (if any)

### 8. Configuration Management
Create `lib/config/medgemma_config.dart`:
```dart
class MedGemmaConfig {
  static const String baseUrl = 'https://warshanks-medgemma-27b-it.hf.space/gradio_api';
  static const int maxTokens = 2048;
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const List<String> supportedMimeTypes = ['image/jpeg', 'image/png', 'image/gif'];
  static const String medicalSystemPrompt = '...'; // Medical-specific prompt
}
```

### 9. Localization Support
Add Spanish/English translations for:
- "Analyze Image"
- "Select Image"
- "Take Photo"
- "Choose from Gallery" 
- "Analyzing image..."
- "Image analysis complete"
- "Error analyzing image"
- Medical disclaimer messages

### 10. Analytics Integration
Add Firebase Analytics events for:
- Image analysis requests
- Provider selection (OpenRouter vs MedGemma)
- Analysis completion time
- Error tracking
- User engagement metrics

## Technical Specifications

### Image Processing
- Support JPEG, PNG, GIF formats
- Max file size: 10MB
- Auto-resize if needed
- Base64 encoding for API calls
- Preserve original aspect ratio

### Streaming Response Handling
- Parse Server-Sent Events format
- Handle incomplete chunks
- Implement reconnection logic
- Cancel streams appropriately
- Update UI progressively

### UI/UX Requirements
- Material Design 3 compliance
- Dark/light theme support
- Responsive layout for tablets
- Accessibility features
- Loading indicators
- Error state illustrations

### Performance Considerations
- Image caching strategy
- Memory management for large images
- Background processing
- Debounced user input
- Lazy loading for chat history

### Security & Privacy
- No image storage on device (unless explicitly saved)
- HTTPS-only communication
- User consent for image analysis
- Data retention policies
- Medical data handling compliance

## Integration Points

### Existing Systems
- **Supabase**: Store image analysis results in chat_messages table
- **Firebase**: Track usage analytics and errors
- **OpenRouter**: Fallback option for image analysis
- **SharedPreferences**: User preferences for default provider

### Medical Context
- Use existing medical system prompts
- Integrate with medical disclaimers
- Support multilingual medical terms
- Maintain HIPAA-compliant practices

## Testing Strategy

### Unit Tests
- MedGemmaService API calls
- ChatMessage model extensions
- Image processing utilities
- Configuration management

### Integration Tests
- Full image analysis workflow
- Provider switching functionality
- Chat history persistence
- Error recovery scenarios

### UI Tests
- Image selection flows
- Analysis result display
- Provider toggle behavior
- Accessibility compliance

## Deployment Considerations

### Environment Variables
```env
MEDGEMMA_BASE_URL=https://warshanks-medgemma-27b-it.hf.space/gradio_api
MEDGEMMA_MAX_TOKENS=2048
MEDGEMMA_TIMEOUT_SECONDS=120
```

### Feature Flags
- Enable/disable MedGemma provider
- A/B testing for different system prompts
- Gradual rollout for new users
- Emergency fallback to OpenRouter only

## Documentation Requirements
- API integration guide
- User manual for image analysis
- Medical disclaimer updates
- Privacy policy amendments
- Developer documentation for new service

## Success Metrics
- Image analysis accuracy feedback
- User engagement with image features
- API response times
- Error rates and recovery
- User preference between providers

This implementation should seamlessly integrate MedGemma capabilities into your existing medical AI app while maintaining the current architecture and user experience patterns.