import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_users_app/appInfo/app_info.dart';
import 'package:uber_users_app/global/global_var.dart';
import 'package:uber_users_app/methods/common_methods.dart';
import 'package:uber_users_app/models/prediction_model.dart';
import 'package:uber_users_app/widgets/prediction_place_ui.dart';

class SearchDestinationPlace extends StatefulWidget {
  const SearchDestinationPlace({super.key});

  @override
  State<SearchDestinationPlace> createState() => _SearchDestinationPlaceState();
}

class _SearchDestinationPlaceState extends State<SearchDestinationPlace> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController destinationTextEditingController =
      TextEditingController();

  List<PredictionModel> dropOffPredictionsPlacesList = [];

  // ✅ Get predictions based on user input
  Future<void> searchLocation(String locationName) async {
    if (locationName.length > 1) {
      String apiPlacesUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$locationName&key=$googleMapKey&components=country:pk";

      var responseFromPlacesAPI = await CommonMethods.sendRequestToAPI(
        apiPlacesUrl,
      );

      if (responseFromPlacesAPI == "error") return;

      if (responseFromPlacesAPI["status"] == "OK") {
        var predictionsResultsInJson = responseFromPlacesAPI["predictions"];
        var predictionsList = (predictionsResultsInJson as List)
            .map(
              (eachPlacePrediction) =>
                  PredictionModel.fromJson(eachPlacePrediction),
            )
            .toList();

        setState(() {
          dropOffPredictionsPlacesList = predictionsList;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // ✅ Pre-fill pickup address from Provider
    final pickUpAddress = Provider.of<AppInfoClass>(
      context,
      listen: false,
    ).pickUpLocation?.humanReadableAddress;

    if (pickUpAddress != null && pickUpAddress.isNotEmpty) {
      pickUpTextEditingController.text = pickUpAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(
            context,
          ).unfocus(); // Hide keyboard when tapping outside
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Top search card
                Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // back
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                            ),
                            const Center(
                              child: Text(
                                "Set Drop-off Location",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Pickup field (read-only)
                        Row(
                          children: [
                            Image.asset(
                              "assets/images/initial.png",
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: TextField(
                                  controller: pickUpTextEditingController,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                    hintText: "Pickup Address",
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Destination field
                        Row(
                          children: [
                            Image.asset(
                              "assets/images/final.png",
                              height: 16,
                              width: 16,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: TextField(
                                  controller: destinationTextEditingController,
                                  autofocus: true,
                                  onChanged: (value) {
                                    searchLocation(value);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Destination Address",
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 9,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Predictions List
                if (dropOffPredictionsPlacesList.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    itemCount: dropOffPredictionsPlacesList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final prediction = dropOffPredictionsPlacesList[index];

                      return Card(
                        elevation: 2,
                        child: PredictionPlaceUI(
                          predictedPlaceData: prediction,
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
