class DogBreed {
  final String name;
  final String imageLink;

  final int goodWithChildren;
  final int goodWithOtherDogs;
  final int goodWithStrangers;
  final int shedding;
  final int grooming;
  final int drooling;
  final int coatLength;
  final int playfulness;
  final int protectiveness;
  final int trainability;
  final int energy;
  final int barking;

  final int minLifeExpectancy;
  final int maxLifeExpectancy;

  final int minHeightMale;
  final int maxHeightMale;
  final int minHeightFemale;
  final int maxHeightFemale;

  final int minWeightMale;
  final int maxWeightMale;
  final int minWeightFemale;
  final int maxWeightFemale;

  DogBreed({
    required this.name,
    required this.imageLink,
    required this.goodWithChildren,
    required this.goodWithOtherDogs,
    required this.goodWithStrangers,
    required this.shedding,
    required this.grooming,
    required this.drooling,
    required this.coatLength,
    required this.playfulness,
    required this.protectiveness,
    required this.trainability,
    required this.energy,
    required this.barking,
    required this.minLifeExpectancy,
    required this.maxLifeExpectancy,
    required this.minHeightMale,
    required this.maxHeightMale,
    required this.minHeightFemale,
    required this.maxHeightFemale,
    required this.minWeightMale,
    required this.maxWeightMale,
    required this.minWeightFemale,
    required this.maxWeightFemale,
  });

  factory DogBreed.fromJson(Map<String, dynamic> json) {
    return DogBreed(
      name: _asString(json['name']),
      imageLink: _asString(json['image_link']),
      goodWithChildren: _asInt(json['good_with_children']),
      goodWithOtherDogs: _asInt(json['good_with_other_dogs']),
      goodWithStrangers: _asInt(json['good_with_strangers']),
      shedding: _asInt(json['shedding']),
      grooming: _asInt(json['grooming']),
      drooling: _asInt(json['drooling']),
      coatLength: _asInt(json['coat_length']),
      playfulness: _asInt(json['playfulness']),
      protectiveness: _asInt(json['protectiveness']),
      trainability: _asInt(json['trainability']),
      energy: _asInt(json['energy']),
      barking: _asInt(json['barking']),
      minLifeExpectancy: _asInt(json['min_life_expectancy']),
      maxLifeExpectancy: _asInt(json['max_life_expectancy']),
      minHeightMale: _asInt(json['min_height_male']),
      maxHeightMale: _asInt(json['max_height_male']),
      minHeightFemale: _asInt(json['min_height_female']),
      maxHeightFemale: _asInt(json['max_height_female']),
      minWeightMale: _asInt(json['min_weight_male']),
      maxWeightMale: _asInt(json['max_weight_male']),
      minWeightFemale: _asInt(json['min_weight_female']),
      maxWeightFemale: _asInt(json['max_weight_female']),
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final asInt = int.tryParse(value);
      if (asInt != null) return asInt;
      final asDouble = double.tryParse(value);
      if (asDouble != null) return asDouble.round();
    }
    return 0;
  }

  static String _asString(dynamic value) {
    return value?.toString() ?? '';
  }
}

class DogSearchParams {
  final String name;
  final bool useWeightFilter;
  final int minWeight;
  final int maxWeight;
  final int? energy;
  final int? barking;
  final int? trainability;
  final int? shedding;

  const DogSearchParams({
    required this.name,
    required this.useWeightFilter,
    required this.minWeight,
    required this.maxWeight,
    this.energy,
    this.barking,
    this.trainability,
    this.shedding,
  });

  bool get hasAnyFilter =>
      name.trim().isNotEmpty ||
      useWeightFilter ||
      energy != null ||
      barking != null ||
      trainability != null ||
      shedding != null;

  Map<String, dynamic> toQuery({required int offset}) {
    final query = <String, dynamic>{};

    if (name.trim().isNotEmpty) {
      query['name'] = name.trim();
    }

    if (useWeightFilter) {
      query['min_weight'] = minWeight;
      query['max_weight'] = maxWeight;
    }

    if (energy != null) query['energy'] = energy;
    if (barking != null) query['barking'] = barking;
    if (trainability != null) query['trainability'] = trainability;
    if (shedding != null) query['shedding'] = shedding;

    query['offset'] = offset;
    return query;
  }
}