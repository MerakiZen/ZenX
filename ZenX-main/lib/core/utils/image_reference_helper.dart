/// Helper class to map Hevypro images to screens
/// This helps track which image corresponds to which screen/feature
class ImageReferenceHelper {
  ImageReferenceHelper._();

  /// Map of image numbers to screen names/features
  /// Update this as you identify what each image shows
  static const Map<String, String> imageToScreenMap = {
    // Example mappings - update based on actual images
    'IMG_3931': 'Login/Splash Screen',
    'IMG_3932': 'Home Screen',
    'IMG_3933': 'Workout List',
    // Add more mappings as images are analyzed
  };

  /// List of all 133 image files for reference
  static List<String> getAllImageFiles() {
    return List.generate(133, (index) => 'IMG_${3931 + index}.JPG');
  }

  /// Get screen name for a specific image
  static String? getScreenForImage(String imageName) {
    final baseName = imageName.replaceAll('.JPG', '').replaceAll('assets/Hevypro/', '');
    return imageToScreenMap[baseName];
  }
}

