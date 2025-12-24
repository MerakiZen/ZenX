import 'package:share_plus/share_plus.dart';

/// Share service for sharing content across the app
/// Uses native share sheet with options like WhatsApp, Facebook, copy link, etc.
class ShareService {
  ShareService._();
  
  static ShareService? _instance;
  
  factory ShareService() {
    _instance ??= ShareService._internal();
    return _instance!;
  }
  
  ShareService._internal();

  /// Share text content using native share sheet
  /// This will show all available sharing options on the device
  /// including WhatsApp, Facebook, Twitter, Email, Messages, Copy, etc.
  Future<void> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      // Handle error silently or show error message
      rethrow;
    }
  }

  /// Share workout post
  Future<void> shareWorkout({
    required String workoutName,
    required String authorName,
    String? workoutUrl,
  }) async {
    final text = _buildWorkoutShareText(
      workoutName: workoutName,
      authorName: authorName,
      workoutUrl: workoutUrl,
    );

    await shareText(
      text: text,
      subject: 'Check out this workout: $workoutName',
    );
  }

  /// Share workout from discover/home feed
  Future<void> shareWorkoutPost({
    required String workoutName,
    required String authorName,
    String? workoutUrl,
  }) async {
    await shareWorkout(
      workoutName: workoutName,
      authorName: authorName,
      workoutUrl: workoutUrl,
    );
  }

  /// Share analytics report
  Future<void> shareReport({
    required String reportTitle,
    required String reportContent,
  }) async {
    final text = _buildReportShareText(
      reportTitle: reportTitle,
      reportContent: reportContent,
    );

    await shareText(
      text: text,
      subject: reportTitle,
    );
  }

  /// Build workout share text
  String _buildWorkoutShareText({
    required String workoutName,
    required String authorName,
    String? workoutUrl,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('💪 Workout: $workoutName');
    buffer.writeln('By: $authorName');
    
    if (workoutUrl != null && workoutUrl.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('View workout: $workoutUrl');
    }
    
    buffer.writeln('');
    buffer.writeln('Shared from ZenX');

    return buffer.toString();
  }

  /// Build report share text
  String _buildReportShareText({
    required String reportTitle,
    required String reportContent,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📊 $reportTitle');
    buffer.writeln('');
    buffer.writeln(reportContent);
    buffer.writeln('');
    buffer.writeln('Shared from ZenX');

    return buffer.toString();
  }
}

