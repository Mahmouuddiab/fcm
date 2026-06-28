import 'package:flutter/material.dart';

class BookingDetailScreen extends StatefulWidget {
  final String? bookingId;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _bookingData;
  String? _errorMessage;

  @override
  void sendNotificationsInit() {
    super.initState();
    _fetchBookingDetails();
  }

  @override
  void initState() {
    super.initState();
    _fetchBookingDetails();
  }

  // Simulates an API call fetching your booking details using the ID from the notification
  Future<void> _fetchBookingDetails() async {
    if (widget.bookingId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Invalid or missing Booking ID.";
      });
      return;
    }

    try {
      // Simulate network request latency
      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

      // Mock Data payload response
      setState(() {
        _bookingData = {
          "id": widget.bookingId,
          "title": "Weekend Desert Safari Tour",
          "date": "Friday, July 10, 2026",
          "time": "04:30 PM",
          "status": "Confirmed",
          "price": "SR 250.00",
          "location": "Al-Thumama Desert, Riyadh",
          "reference": "TKT-${widget.bookingId?.toUpperCase()}"
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load booking details. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details #${widget.bookingId ?? ""}'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _fetchBookingDetails();
                },
                child: const Text("Retry"),
              )
            ],
          ),
        ),
      );
    }

    // Main view layout once data maps resolve successfully
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card Header
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary, size: 32),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _bookingData?['status'] ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text("Ref: ${_bookingData?['reference'] ?? ''}"),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Main Information Details Card
          const Text(
            "Reservation Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow(Icons.event, "Activity", _bookingData?['title']),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.calendar_month, "Date", _bookingData?['date']),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.access_time, "Time", _bookingData?['time']),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.location_on, "Location", _bookingData?['location']),
                  const Divider(height: 24),
                  _buildDetailRow(Icons.payments, "Total Paid", _bookingData?['price']),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                // Handle ticket action or maps directions
              },
              icon: const Icon(Icons.map),
              label: const Text("Get Directions"),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(
                value ?? 'N/A',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}