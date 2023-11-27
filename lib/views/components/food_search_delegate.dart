import 'package:final_project/models/SearchResultFood.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:final_project/models/SearchResult.dart';

class FoodSearchDelegate extends SearchDelegate {
  List<String> searchResults = [
    'Cheddar Cheese',
    'Milk',
    'Bacon',
    'Eggs',
    'White Rice',
    'Blueberries',
  ];
  String urlSearch = 'https://api.nal.usda.gov/fdc/v1/foods/search?api_key=';
  String apiKey = '5Zwsmg1lLYSeaQ9Yx0T1rbstPEIjdQJjA6T56vzn';
  String queryBase = '&query=';

  Future<String> _search() async {
    try {
      final response =
          await http.get(Uri.parse('$urlSearch$apiKey$queryBase"$query"&dataType=Branded'));
      return response.body;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  List<Widget> foodDetails(SearchResultFood food) {
    final nutrients = food.foodNutrient;
    var details = <Widget>[];
    if (nutrients != null) {
      for(var nutrient in nutrients){
        final number = nutrient.number;
        final name = nutrient.name;
        final amount = nutrient.amount;
        final unitName = nutrient.unitName;
        final derivationCode = nutrient.derivationCode;
        final derivationDescription = nutrient.derivationDescription;
        final line = Text('$number, $name, $amount, $unitName, $derivationCode, $derivationDescription');
        if (amount! > 0){
          details.add(line);
        }
      }
    }
    return details;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            if (query.isEmpty) {
              close(context, null);
            } else {
              query = '';
            }
          },
          icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: FutureBuilder(
          future: _search(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final jsonData = snapshot.data!;
              final parsedJson = jsonDecode(jsonData);
              final searchResult = SearchResult.fromJson(parsedJson);
              final foods = searchResult.foods;
              if (foods != null) {
                return ListView.builder(
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ExpansionTile(
                          title: Text(foods[index].description),
                          children: foodDetails(foods[index]),
                        ),
                      );
                    });
              } else {
                return Text('No foods match this $query');
              }
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = searchResults.where((searchResults) {
      final result = searchResults.toLowerCase();
      final input = query.toLowerCase();
      return result.contains(input);
    }).toList();

    return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          var suggestion = suggestions[index];
          return ListTile(
            title: Text(suggestion),
            onTap: () {
              query = suggestion;
              showResults(context);
            },
          );
        });
  }
}
