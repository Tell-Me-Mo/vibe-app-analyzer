# Notification Service Documentation

## Overview

The `NotificationService` is a modern, elegant centralized notification system that replaces custom snackbars throughout the application. It follows modern UI/UX best practices and provides a responsive design that works seamlessly on both mobile and desktop platforms.

## Key Features

### 🎨 Modern Design
- **Glass morphism effects** with subtle borders and glows
- **Gradient accents** that match notification type (success, error, warning, info)
- **Smooth animations** with slide-in from top and fade effects
- **Responsive layout** that adapts to mobile and desktop screen sizes

### 🎯 UX Best Practices
- **Smart duration calculation** based on message length:
  - Up to 10 words: 5 seconds
  - 10-20 words: 6 seconds
  - 20+ words: 8 seconds
- **Manual dismissal** via close button (always available)
- **Position optimization**: top-center for both mobile and desktop
- **Maximum 3 lines** of text with ellipsis overflow
- **Tap support** for custom actions

### ♿ Accessibility
- High contrast text and icons
- Clear visual hierarchy with titles and messages
- Color-coded with semantic meaning (not relying on color alone)
- Icons reinforce notification type

## Usage

### Basic Usage

```dart
import '../services/notification_service.dart';

// Success notification
NotificationService.showSuccess(
  context,
  message: 'Operation completed successfully!',
);

// With title
NotificationService.showSuccess(
  context,
  title: 'Success',
  message: 'Your changes have been saved.',
);

// Error notification
NotificationService.showError(
  context,
  title: 'Error',
  message: 'Failed to process request.',
);

// Warning notification
NotificationService.showWarning(
  context,
  title: 'Warning',
  message: 'You are running low on credits.',
);

// Info notification
NotificationService.showInfo(
  context,
  title: 'New Feature',
  message: 'Check out our latest updates!',
);
```

### Advanced Usage

```dart
// Custom duration
NotificationService.showSuccess(
  context,
  message: 'Custom duration message',
  duration: Duration(seconds: 10),
);

// With tap action
NotificationService.showInfo(
  context,
  title: 'Update Available',
  message: 'Tap to learn more',
  onTap: () {
    // Navigate to update page
    context.push('/updates');
  },
);

// Dismiss all notifications programmatically
NotificationService.dismissAll();
```

## Migration from SnackBar

### Before (Old SnackBar)
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Success message'),
    backgroundColor: Colors.green,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 3),
  ),
);
```

### After (New NotificationService)
```dart
NotificationService.showSuccess(
  context,
  message: 'Success message',
);
```

## Notification Types

### 1. Success (Green)
- Icon: ✓ check circle
- Use for: Completed actions, confirmations
- Examples: "Item saved", "Payment successful"

### 2. Error (Red)
- Icon: ⚠ error circle
- Use for: Failed operations, critical issues
- Examples: "Network error", "Invalid input"

### 3. Warning (Orange/Amber)
- Icon: ⚠ warning triangle
- Use for: Cautionary messages, low priority issues
- Examples: "Low credits", "Session expiring soon"

### 4. Info (Blue)
- Icon: ℹ info circle
- Use for: Informational messages, updates
- Examples: "New features available", "Tip of the day"

## Design Specifications

### Colors (from AppColors)
- **Success**: Emerald gradient (#10B981 → #14B8A6)
- **Error**: Red gradient (#EF4444 → #F97316)
- **Warning**: Amber gradient (#F59E0B → #F97316)
- **Info**: Indigo gradient (#6366F1 → #8B5CF6)

### Layout
- **Max width (desktop)**: 420px
- **Min width (desktop)**: 360px
- **Border radius**: 16px
- **Padding**: 16px
- **Icon size**: 20px
- **Close button size**: 16px

### Animation
- **Duration**: 350ms
- **Curve**: easeOutCubic
- **Entry**: Slide from top + fade in
- **Exit**: Reverse slide + fade out

## Best Practices

### ✅ Do
- Use appropriate notification type for the message
- Keep messages concise and actionable
- Provide context with titles for important messages
- Use success notifications for confirmations
- Use error notifications for failures

### ❌ Don't
- Show multiple notifications simultaneously (they will stack)
- Use notifications for critical information that requires user action
- Make messages too long (3 lines max)
- Rely solely on color to convey meaning
- Use for permanent/persistent information

## Responsive Behavior

### Mobile (< 600px width)
- Full width with 16px horizontal margins
- Positioned at top-center
- Single column layout

### Desktop (≥ 600px width)
- Fixed max-width of 420px
- Centered horizontally
- Positioned at top-center
- More spacious padding

## Technical Details

### Architecture
- **Singleton pattern** for service instance
- **Overlay-based** rendering (not part of widget tree)
- **Animation controller** per notification
- **State management** for active notifications

### Performance
- Lightweight overlay entries
- Efficient animation disposal
- Auto-cleanup on dismiss
- No memory leaks

## Testing

A demo page is available at `lib/examples/notification_demo.dart` to test all notification types and configurations.

To use the demo:
1. Import and navigate to `NotificationDemoPage`
2. Test different notification types
3. Verify responsive behavior by resizing window
4. Test multiple notifications stacking
5. Test manual dismissal

## Files Modified

The following files were updated to use the new notification service:

1. `lib/providers/validation_provider.dart` - Validation notifications
2. `lib/pages/results_page.dart` - Copy to clipboard notifications
3. `lib/pages/credits_page.dart` - Purchase success notifications
4. `lib/widgets/results/recommendation_card.dart` - Copy prompt notifications
5. `lib/widgets/results/issue_card.dart` - Copy prompt notifications

## Future Enhancements

Potential improvements for future versions:

- [ ] Queuing system for multiple simultaneous notifications
- [ ] Notification history/log
- [ ] Custom icons per notification
- [ ] Sound effects
- [ ] Vibration feedback (mobile)
- [ ] Position customization (top/bottom)
- [ ] Swipe to dismiss gesture
- [ ] Progress indicator for long operations
- [ ] Action buttons (e.g., "Undo", "Retry")
- [ ] Notification groups/categories
