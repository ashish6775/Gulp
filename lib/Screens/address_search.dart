import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shop_app/Screens/new_address_screen.dart';
import 'package:shop_app/Screens/place_service.dart';
import 'package:geocoder/geocoder.dart';

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  void newAddressScreen(BuildContext ctx, coordinates1, screen) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) {
          return NewAddressScreen(
              LatLng(
                coordinates1.latitude,
                coordinates1.longitude,
              ),
              screen);
        },
      ),
    );
  }

  final sessionToken;
  PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        //Navigator.of(context).pop();
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      height: 1,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == "" ? null : apiClient.fetchSuggestions(query),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Enter your address',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    leading: Icon(Icons.location_on_outlined),
                    title: Text(
                      (snapshot.data[index] as Suggestion)
                          .description
                          .split(",")[0],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () async {
                      var addresses = await Geocoder.local
                          .findAddressesFromQuery(
                              (snapshot.data[index] as Suggestion).description);
                      var first = addresses.first;
                      close(context, null);

                      newAddressScreen(context, first.coordinates, "One");
                    },
                    subtitle: Text((snapshot.data[index] as Suggestion)
                        .description
                        .split(",")
                        .sublist(1)
                        .join(",")),
                  ),
                  itemCount: snapshot.data.length,
                )
              : Container(child: Text('Loading...')),
    );
  }
}
