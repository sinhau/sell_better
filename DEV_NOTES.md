# SellBetter Development Notes

## Project Overview
SellBetter is a Flutter application that helps users polish product photos for online listings using AI image enhancement.

## Running the Application

### Web Development
```bash
flutter run -d chrome
```

### iOS Simulator
```bash
flutter run -d ios
```

### Android Emulator
```bash
flutter run -d android
```

### Build for Production

#### Web
```bash
flutter build web --release
```

#### iOS
```bash
flutter build ios --release
```

#### Android
```bash
flutter build apk --release
```

## Configuration

### API Proxy Setup
The app expects a proxy server URL to mint short-lived tokens for fal.ai. Set the environment variable:
```bash
flutter run --dart-define=FAL_PROXY_URL=https://your-proxy-url.com
```

### Feature Flags
Edit `assets/flags.json` to toggle features without code changes:
- `categorySelection`: Enable/disable category selection
- `watermark`: Add watermark to exported images
- `aiBadge`: Show AI-edited badge on results
- `batchProcessing`: Process multiple photos at once (future feature)
- `history`: Local history of processed photos (future feature)

## Project Structure

```
lib/
├── main.dart           # Entry point
├── app.dart            # App configuration
├── routes.dart         # Navigation routes
├── screens/            # UI screens
│   ├── landing_screen.dart
│   ├── picker_screen.dart
│   ├── processing_screen.dart
│   ├── result_screen.dart
│   └── about_screen.dart
├── widgets/            # Reusable UI components
│   ├── before_after_slider.dart
│   ├── photo_tile.dart
│   └── action_bar.dart
├── state/              # State management
│   ├── providers.dart
│   └── models.dart
├── services/           # Business logic
│   ├── fal_service.dart    # AI processing service
│   ├── image_utils.dart    # Image manipulation
│   └── storage.dart        # Local storage
└── prompts/            # AI prompt templates
    ├── base.json
    ├── furniture.json
    ├── shoes.json
    ├── electronics.json
    └── cars.json
```

## Key Features Implemented

1. **Photo Selection**: Camera and gallery integration
2. **Category Selection**: Optimized prompts for different product types
3. **AI Processing**: Integration with fal.ai for image enhancement
4. **Before/After Slider**: Interactive comparison widget
5. **Export Options**: Save to device or share
6. **AI Transparency**: Optional badge and "What Changed?" information
7. **State Management**: Riverpod for reactive state handling
8. **Routing**: go_router for navigation

## Testing

### Run Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test
```

## Debugging

### View Logs
```bash
flutter logs
```

### DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

## Environment Variables

- `FAL_PROXY_URL`: Proxy server URL for fal.ai token generation
- Development proxy: `https://api.example.com` (replace with actual)

## Mock/Stub Implementation

Currently, the `FalService.polishImage()` method is stubbed to return the original image after a simulated delay. To implement actual AI processing:

1. Set up a proxy server that mints short-lived JWT tokens for fal.ai
2. Update the `FAL_PROXY_URL` environment variable
3. Ensure the fal.ai endpoint is correctly configured in `fal_service.dart`

## Deployment Checklist

- [ ] Update `FAL_PROXY_URL` to production proxy
- [ ] Enable analytics in `assets/flags.json`
- [ ] Set up crash reporting
- [ ] Configure app signing for iOS/Android
- [ ] Test on multiple device sizes
- [ ] Verify image processing on low-memory devices
- [ ] Review and update privacy policy
- [ ] Submit to app stores

## Performance Considerations

- Images are resized to max 3072px for processing
- Export size limited to 1536px for marketplace compatibility
- Sequential processing for low-memory devices
- 15-minute cache for processed images

## Security Notes

- Never commit API keys to the repository
- Use short-lived tokens (25-30 minutes)
- Strip GPS EXIF data on export
- Photos processed locally, not stored on servers