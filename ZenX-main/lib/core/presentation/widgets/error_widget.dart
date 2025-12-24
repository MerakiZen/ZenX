import 'package:flutter/material.dart';
import '../../errors/failures.dart';

/// Error display widget
class ErrorDisplayWidget extends StatelessWidget {
  final Failure failure;
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({
    super.key,
    required this.failure,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _getErrorMessage(),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getErrorMessage() {
    return failure.when(
      server: (message, statusCode) => 
          'Server Error${statusCode != null ? ' ($statusCode)' : ''}: $message',
      network: (message) => 'Network Error: $message',
      cache: (message) => 'Storage Error: $message',
      validation: (message) => 'Validation Error: $message',
      unknown: (message) => 'Error: $message',
    );
  }
}









