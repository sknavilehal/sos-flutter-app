import 'package:flutter/material.dart';
import 'core/services/offline_district_service.dart';

/// Standalone test app for district lookup functionality
/// Run with: flutter run lib/test_district_lookup.dart
void main() {
  runApp(const DistrictTestApp());
}

class DistrictTestApp extends StatelessWidget {
  const DistrictTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'District Lookup Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DistrictTestScreen(),
    );
  }
}

class DistrictTestScreen extends StatefulWidget {
  const DistrictTestScreen({super.key});

  @override
  State<DistrictTestScreen> createState() => _DistrictTestScreenState();
}

class _DistrictTestScreenState extends State<DistrictTestScreen> {
  final _service = OfflineDistrictService.instance;
  bool _isLoading = true;
  String _status = 'Initializing...';
  String? _result;
  
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  
  // Pre-defined test coordinates
  final List<TestLocation> _testLocations = [
    TestLocation('Udupi, Karnataka', 13.3409, 74.7421, 'udupi'),
    TestLocation('Bangalore, Karnataka', 12.9716, 77.5946, 'bengaluru-urban'),
    TestLocation('Mumbai, Maharashtra', 19.0760, 72.8777, 'mumbai'),
    TestLocation('Delhi', 28.6139, 77.2090, 'new-delhi'),
    TestLocation('Chennai, Tamil Nadu', 13.0827, 80.2707, 'chennai'),
    TestLocation('Kolkata, West Bengal', 22.5726, 88.3639, 'kolkata'),
    TestLocation('Hyderabad, Telangana', 17.3850, 78.4867, 'hyderabad'),
    TestLocation('Pune, Maharashtra', 18.5204, 73.8567, 'pune'),
    TestLocation('Mangalore, Karnataka', 12.9141, 74.8560, 'dakshina-kannada'),
    TestLocation('Mysore, Karnataka', 12.2958, 76.6394, 'mysuru'),
  ];

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading district boundaries...';
    });

    try {
      await _service.initialize();
      
      setState(() {
        _isLoading = false;
        _status = '✅ Loaded ${_service.districtCount} districts';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '❌ Failed to load: $e';
      });
    }
  }

  void _lookupDistrict() {
    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);

    if (lat == null || lng == null) {
      setState(() {
        _result = '❌ Invalid coordinates';
      });
      return;
    }

    setState(() {
      _result = 'Looking up...';
    });

    final district = _service.getDistrictFromCoordinates(lat, lng);
    
    setState(() {
      if (district != null) {
        final info = _service.getDistrictInfo(district);
        _result = '''
✅ District Found!
━━━━━━━━━━━━━━━━━━━━━━
District: ${info?.name}
State: ${info?.stateName}
Sanitized: $district
Topic: district-$district
''';
      } else {
        _result = '❌ No district found for these coordinates';
      }
    });
  }

  void _testLocation(TestLocation location) {
    _latController.text = location.latitude.toString();
    _lngController.text = location.longitude.toString();
    _lookupDistrict();
  }

  void _runAllTests() async {
    setState(() {
      _result = 'Running all tests...\n\n';
    });

    int passed = 0;
    int failed = 0;
    String results = '';

    for (final location in _testLocations) {
      final district = _service.getDistrictFromCoordinates(
        location.latitude,
        location.longitude,
      );
      
      final success = district == location.expectedDistrict;
      
      if (success) {
        passed++;
        results += '✅ ${location.name}\n';
        results += '   Expected: ${location.expectedDistrict}\n';
        results += '   Got: $district\n\n';
      } else {
        failed++;
        results += '❌ ${location.name}\n';
        results += '   Expected: ${location.expectedDistrict}\n';
        results += '   Got: ${district ?? "null"}\n\n';
      }
    }

    setState(() {
      _result = '''
Test Results
━━━━━━━━━━━━━━━━━━━━━━
Passed: $passed / ${_testLocations.length}
Failed: $failed / ${_testLocations.length}

$results
''';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('District Lookup Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_status),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _status,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total districts loaded: ${_service.districtCount}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Manual input section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manual Lookup',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _latController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              hintText: '13.3409',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _lngController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              hintText: '74.7421',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _lookupDistrict,
                              child: const Text('Lookup District'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Quick test buttons
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Tests',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _testLocations.map((location) {
                              return ActionChip(
                                label: Text(location.name),
                                onPressed: () => _testLocation(location),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _runAllTests,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Run All Tests'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Results section
                  if (_result != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Results',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                _result!,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
}

class TestLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String expectedDistrict;

  TestLocation(this.name, this.latitude, this.longitude, this.expectedDistrict);
}
