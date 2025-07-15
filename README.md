# Prequ ✨ - Your Cozy Requirement Prioritizer

A friendly Flutter app designed to make prioritizing requirements simple, intuitive, and maybe even a little fun. We use a bubble sort approach to help you focus on what's most important, one decision at a time.

## Our Vision: Cozy & Performant

Our goal is to create an experience that feels like a warm conversation rather than a sterile tool. This means:
- **Friendly UI**: Soft colors, gentle animations, and clear, encouraging language. We recommend a warm pastel color palette and a friendly font like `Nunito` or `Lato` from Google Fonts.
- **Lag-Free Experience**: Performance is a key feature. The app should feel responsive and smooth, never getting in the way of your workflow.
- **Simplicity**: Focusing on the core task of prioritization without unnecessary clutter.

## The "Prioritize" Button

As the main action of the app, the "Prioritize" button should be special. We suggest making it a prominent `ElevatedButton` with the following characteristics:

```dart
ElevatedButton.icon(
  icon: Icon(Icons.swap_vert_rounded),
  label: Text('Prioritize'),
  onPressed: () {
    // Start the bubble sort logic
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.deepPurple[300], // A friendly, warm color
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    textStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
)