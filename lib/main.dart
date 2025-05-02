import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSM Location App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyLocationMap(),
    );
  }
}

class MyLocationMap extends StatefulWidget {
  const MyLocationMap({Key? key}) : super(key: key);

  @override
  State<MyLocationMap> createState() => _MyLocationMapState();
}

class _MyLocationMapState extends State<MyLocationMap> with OSMMixinObserver {
  late MapController mapController;
  bool isMapReady = false;

  @override
  void initState() {
    super.initState();

    // Initialize map controller with user tracking option
    mapController = MapController.withUserPosition(
      trackUserLocation: UserTrackingOption(
        enableTracking: true,
        unFollowUser: false,
      ),
    );

    // Add this widget as an observer to get map events
    mapController.addObserver(this);
  }

  @override
  Future<void> mapIsReady(bool isReady) async {
    // This is called when the map is initialized and ready
    if (isReady) {
      setState(() {
        isMapReady = true;
      });

      // Once map is ready, request current location and zoom to it
      try {
        // This will zoom to the user's current location
        await mapController.currentLocation();
        await mapController.setZoom(zoomLevel: 16);

        // Optionally, you can also get the location as a GeoPoint
        GeoPoint myLocation = await mapController.myLocation();
        print(
            "Current location: ${myLocation.latitude}, ${myLocation.longitude}");
      } catch (e) {
        print("Error getting current location: $e");
      }
    }
  }

  @override
  void onLocationChanged(GeoPoint userLocation) {
    // This is called whenever the user's location changes
    print(
        "Location updated: ${userLocation.latitude}, ${userLocation.longitude}");
    // You can implement additional logic here if needed
  }

  @override
  void dispose() {
    // Properly dispose of the controller
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Location Map'),
        actions: [
          // Button to re-center on user location
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              if (isMapReady) {
                await mapController.currentLocation();
                await mapController.setZoom(zoomLevel: 16);
              }
            },
          ),
        ],
      ),
      body: OSMFlutter(
        controller: mapController,
        osmOption: OSMOption(
          userTrackingOption: UserTrackingOption(
            enableTracking: true,
            unFollowUser: false,
          ),
          zoomOption: ZoomOption(
            initZoom: 16,
            minZoomLevel: 4,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          userLocationMarker: UserLocationMaker(
            personMarker: MarkerIcon(
              icon: Icon(
                Icons.location_history_rounded,
                color: Colors.red,
                size: 48,
              ),
            ),
            directionArrowMarker: MarkerIcon(
              icon: Icon(
                Icons.double_arrow,
                size: 48,
                color: Colors.blue,
              ),
            ),
          ),
          roadConfiguration: RoadOption(
            roadColor: Colors.blueAccent,
          ),
        ),
        mapIsLoading: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Zoom in button
          FloatingActionButton(
            heroTag: "zoomIn",
            onPressed: () async {
              if (isMapReady) {
                await mapController.zoomIn();
              }
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          // Zoom out button
          FloatingActionButton(
            heroTag: "zoomOut",
            onPressed: () async {
              if (isMapReady) {
                await mapController.zoomOut();
              }
            },
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
