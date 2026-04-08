import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dog_breed.dart';
import '../data/dogs_repository.dart';

enum DogSort { name, energyDesc, lifeDesc }

class DogsController extends ChangeNotifier {
  final DogsRepository _repository;
  final SharedPreferences _prefs;

  DogsController(this._repository, this._prefs);

  static const _favoritesKey = 'favorite_dog_names';

  final Set<String> _favorites = <String>{};
  final List<DogBreed> _items = <DogBreed>[];

  String name = '';
  bool useWeightFilter = false;
  RangeValues weightRange = const RangeValues(10, 80);
  int? energy;
  int? barking;
  int? trainability;
  int? shedding;

  bool onlyFavorites = false;
  DogSort sort = DogSort.name;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasSearched = false;
  bool hasMore = false;

  String? errorMessage;
  int _offset = 0;

  UnmodifiableListView<DogBreed> get visibleItems =>
      UnmodifiableListView(_buildVisibleItems());

  int get favoritesCount => _favorites.length;

  Future<void> init() async {
    _favorites
      ..clear()
      ..addAll(_prefs.getStringList(_favoritesKey) ?? const []);
    notifyListeners();
  }

  bool isFavorite(DogBreed dog) => _favorites.contains(dog.name);

  void setName(String value) {
    name = value;
  }

  void setWeightFilter(bool value) {
    useWeightFilter = value;
    notifyListeners();
  }

  void setWeightRange(RangeValues value) {
    weightRange = value;
    notifyListeners();
  }

  void setEnergy(int? value) {
    energy = value;
    notifyListeners();
  }

  void setBarking(int? value) {
    barking = value;
    notifyListeners();
  }

  void setTrainability(int? value) {
    trainability = value;
    notifyListeners();
  }

  void setShedding(int? value) {
    shedding = value;
    notifyListeners();
  }

  void setOnlyFavorites(bool value) {
    onlyFavorites = value;
    notifyListeners();
  }

  void setSort(DogSort value) {
    sort = value;
    notifyListeners();
  }

  Future<void> quickSearch(String breed) async {
    name = breed;
    await search();
  }

  Future<void> resetFilters() async {
    name = '';
    useWeightFilter = false;
    weightRange = const RangeValues(10, 80);
    energy = null;
    barking = null;
    trainability = null;
    shedding = null;
    onlyFavorites = false;
    sort = DogSort.name;
    errorMessage = null;
    hasSearched = false;
    hasMore = false;
    _offset = 0;
    _items.clear();
    notifyListeners();
  }

  Future<void> search() async {
    final params = _currentParams();

    if (!params.hasAnyFilter) {
      errorMessage = 'Введите название породы или выберите хотя бы один фильтр.';
      hasSearched = false;
      _items.clear();
      notifyListeners();
      return;
    }

    isLoading = true;
    isLoadingMore = false;
    errorMessage = null;
    hasSearched = true;
    hasMore = false;
    _offset = 0;
    _items.clear();
    notifyListeners();

    try {
      final result = await _repository.searchDogs(params, offset: 0);
      _items.addAll(result);
      _offset = result.length;
      hasMore = result.length == 20;
    } catch (e) {
      errorMessage = _mapError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.searchDogs(
        _currentParams(),
        offset: _offset,
      );

      final existing = _items.map((e) => e.name).toSet();
      for (final dog in result) {
        if (!existing.contains(dog.name)) {
          _items.add(dog);
        }
      }

      _offset += result.length;
      hasMore = result.length == 20;
    } catch (e) {
      errorMessage = _mapError(e);
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(DogBreed dog) async {
    if (_favorites.contains(dog.name)) {
      _favorites.remove(dog.name);
    } else {
      _favorites.add(dog.name);
    }

    await _prefs.setStringList(_favoritesKey, _favorites.toList());
    notifyListeners();
  }

  DogSearchParams _currentParams() {
    return DogSearchParams(
      name: name,
      useWeightFilter: useWeightFilter,
      minWeight: weightRange.start.round(),
      maxWeight: weightRange.end.round(),
      energy: energy,
      barking: barking,
      trainability: trainability,
      shedding: shedding,
    );
  }

  List<DogBreed> _buildVisibleItems() {
    var list = List<DogBreed>.from(_items);

    if (onlyFavorites) {
      list = list.where((dog) => _favorites.contains(dog.name)).toList();
    }

    switch (sort) {
      case DogSort.name:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case DogSort.energyDesc:
        list.sort((a, b) => b.energy.compareTo(a.energy));
        break;
      case DogSort.lifeDesc:
        list.sort((a, b) => b.maxLifeExpectancy.compareTo(a.maxLifeExpectancy));
        break;
    }

    return list;
  }

  String _mapError(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;

      if (statusCode == 401) {
        return 'Ошибка 401. Проверьте API key.';
      }

      if (statusCode == 400) {
        return 'Ошибка 400. Проверьте параметры поиска.';
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Превышено время ожидания ответа от сервера.';
      }

      return 'Сетевая ошибка: ${error.message}';
    }

    return 'Не удалось загрузить данные.';
  }
}