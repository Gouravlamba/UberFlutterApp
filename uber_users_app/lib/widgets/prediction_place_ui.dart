import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/models/prediction_model.dart';
import 'package:uber_users_app/models/address_models.dart'; // ✅ Use AddressModel here

class PredictionPlaceUI extends StatelessWidget {
  final PredictionModel predictedPlaceData;

  const PredictionPlaceUI({super.key, required this.predictedPlaceData});

  Future<void> getPlaceDetailsAndSaveToApp(
    BuildContext context,
    String placeId,
  ) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleMapKey";

    var response = await CommonMethods.sendRequestToAPI(url);

    if (response == "error") return;

    if (response["status"] == "OK") {
      final result = response["result"];

      // ✅ Convert result to AddressModel instead of PlaceDetailModel
      final dropOffAddress = AddressModel(
        humanReadableAddress: result["formatted_address"],
        placeName: result["name"],
        latitudePosition: result["geometry"]["location"]["lat"],
        longitudePosition: result["geometry"]["location"]["lng"],
      );
      // ✅ Save drop-off address to provider
      Provider.of<AppInfoClass>(
        context,
        listen: false,
      ).updateDropOffLocation(dropOffAddress);

      // ✅ Close screen and return success
      Navigator.pop(context, "placeSelected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_pin, color: Colors.grey),
      title: Text(
        predictedPlaceData.mainText ?? "",
        style: const TextStyle(fontSize: 16),
      ),
      subtitle: Text(
        predictedPlaceData.secondaryText ?? "",
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: () {
        getPlaceDetailsAndSaveToApp(context, predictedPlaceData.placeId!);
      },
    );
  }
}
