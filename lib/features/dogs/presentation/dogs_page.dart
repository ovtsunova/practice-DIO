import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../data/dog_breed.dart';
import 'dogs_controller.dart';

class DogsPage extends StatefulWidget {
  const DogsPage({super.key});

  @override
  State<DogsPage> createState() => _DogsPageState();
}

class _DogsPageState extends State<DogsPage> {
  late final DogsController controller;
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    controller = sl<DogsController>();
    searchController = TextEditingController();
    controller.init();
  }

  @override
  void dispose() {
    searchController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dog Explorer'),
        centerTitle: false,
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 1100;

              if (compact) {
                return Column(
                  children: [
                    Flexible(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildFiltersCard(context),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildResultsCard(context),
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  SizedBox(
                    width: 340,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildFiltersCard(context),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                      child: _buildResultsCard(context),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFiltersCard(BuildContext context) {
    return Card(
      elevation: 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Фильтры и поиск',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Название породы',
                hintText: 'Например: husky',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: controller.setName,
              onSubmitted: (_) => controller.search(),
            ),
            const SizedBox(height: 16),
            Text(
              'Быстрый поиск',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final breed in const [
                  'husky',
                  'beagle',
                  'poodle',
                  'akita',
                  'chihuahua',
                  'labrador'
                ])
                  ActionChip(
                    label: Text(breed),
                    onPressed: () {
                      searchController.text = breed;
                      controller.quickSearch(breed);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              value: controller.useWeightFilter,
              onChanged: controller.setWeightFilter,
              title: const Text('Фильтр по весу'),
              contentPadding: EdgeInsets.zero,
            ),
            if (controller.useWeightFilter) ...[
              RangeSlider(
                values: controller.weightRange,
                min: 5,
                max: 120,
                divisions: 23,
                labels: RangeLabels(
                  controller.weightRange.start.round().toString(),
                  controller.weightRange.end.round().toString(),
                ),
                onChanged: controller.setWeightRange,
              ),
              Text(
                'Вес: ${controller.weightRange.start.round()} - ${controller.weightRange.end.round()} lb',
              ),
              const SizedBox(height: 16),
            ],
            _buildRatingSelector(
              context: context,
              title: 'Энергия',
              value: controller.energy,
              onChanged: controller.setEnergy,
            ),
            _buildRatingSelector(
              context: context,
              title: 'Обучаемость',
              value: controller.trainability,
              onChanged: controller.setTrainability,
            ),
            _buildRatingSelector(
              context: context,
              title: 'Лай',
              value: controller.barking,
              onChanged: controller.setBarking,
            ),
            _buildRatingSelector(
              context: context,
              title: 'Линька',
              value: controller.shedding,
              onChanged: controller.setShedding,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controller.isLoading ? null : controller.search,
                    icon: const Icon(Icons.travel_explore),
                    label: const Text('Найти'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      searchController.clear();
                      await controller.resetFilters();
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Сброс'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _buildToolbar(context),
            const SizedBox(height: 16),
            Expanded(child: _buildBody(context)),
            if (controller.hasMore && !controller.isLoading)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: FilledButton.icon(
                  onPressed: controller.isLoadingMore ? null : controller.loadMore,
                  icon: controller.isLoadingMore
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.expand_more),
                  label: Text(
                    controller.isLoadingMore ? 'Загрузка...' : 'Загрузить ещё',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Wrap(
      runSpacing: 12,
      spacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          controller.hasSearched
              ? 'Результатов: ${controller.visibleItems.length}'
              : 'Выберите фильтры и начните поиск',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: Text('Только избранное (${controller.favoritesCount})'),
          selected: controller.onlyFavorites,
          onSelected: controller.setOnlyFavorites,
        ),
        DropdownButton<DogSort>(
          value: controller.sort,
          onChanged: (value) {
            if (value != null) controller.setSort(value);
          },
          items: const [
            DropdownMenuItem(
              value: DogSort.name,
              child: Text('Сортировка: имя'),
            ),
            DropdownMenuItem(
              value: DogSort.energyDesc,
              child: Text('Сортировка: энергия'),
            ),
            DropdownMenuItem(
              value: DogSort.lifeDesc,
              child: Text('Сортировка: долгожители'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null && controller.visibleItems.isEmpty) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 12),
              Text(
                controller.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: controller.search,
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (!controller.hasSearched) {
      return const Center(
        child: Text(
          'Введите название породы или используйте фильтры слева.',
          textAlign: TextAlign.center,
        ),
      );
    }

    if (controller.visibleItems.isEmpty) {
      return const Center(
        child: Text(
          'По вашему запросу ничего не найдено.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1250) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 760) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          itemCount: controller.visibleItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.86,
          ),
          itemBuilder: (_, index) {
            final dog = controller.visibleItems[index];
            return _DogCard(
              dog: dog,
              isFavorite: controller.isFavorite(dog),
              onFavoriteTap: () => controller.toggleFavorite(dog),
              onDetailsTap: () => _showDetails(context, dog),
            );
          },
        );
      },
    );
  }

  Widget _buildRatingSelector({
    required BuildContext context,
    required String title,
    required int? value,
    required ValueChanged<int?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Любая'),
                selected: value == null,
                onSelected: (_) => onChanged(null),
              ),
              for (int i = 1; i <= 5; i++)
                ChoiceChip(
                  label: Text('$i'),
                  selected: value == i,
                  onSelected: (_) => onChanged(i),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showDetails(BuildContext context, DogBreed dog) {
    return showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(dog.name),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (dog.imageLink.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        dog.imageLink,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Icon(Icons.pets, size: 48),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  _detailLine('Характер к детям', dog.goodWithChildren),
                  _detailLine('К другим собакам', dog.goodWithOtherDogs),
                  _detailLine('К незнакомцам', dog.goodWithStrangers),
                  _detailLine('Линька', dog.shedding),
                  _detailLine('Груминг', dog.grooming),
                  _detailLine('Слюнотечение', dog.drooling),
                  _detailLine('Игривость', dog.playfulness),
                  _detailLine('Защитные качества', dog.protectiveness),
                  _detailLine('Обучаемость', dog.trainability),
                  _detailLine('Энергия', dog.energy),
                  _detailLine('Лай', dog.barking),
                  _detailLine(
                    'Продолжительность жизни',
                    '${dog.minLifeExpectancy}-${dog.maxLifeExpectancy} лет',
                  ),
                  _detailLine(
                    'Рост (самцы)',
                    '${dog.minHeightMale}-${dog.maxHeightMale} in',
                  ),
                  _detailLine(
                    'Рост (самки)',
                    '${dog.minHeightFemale}-${dog.maxHeightFemale} in',
                  ),
                  _detailLine(
                    'Вес (самцы)',
                    '${dog.minWeightMale}-${dog.maxWeightMale} lb',
                  ),
                  _detailLine(
                    'Вес (самки)',
                    '${dog.minWeightFemale}-${dog.maxWeightFemale} lb',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailLine(String label, Object value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: $value'),
    );
  }
}

class _DogCard extends StatelessWidget {
  final DogBreed dog;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onDetailsTap;

  const _DogCard({
    required this.dog,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: dog.imageLink.isEmpty
                ? Container(
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const Icon(Icons.pets, size: 48),
                  )
                : Image.network(
                    dog.imageLink,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.pets, size: 48),
                    ),
                  ),
          ),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dog.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _statChip('Энергия', dog.energy),
                      _statChip('Лай', dog.barking),
                      _statChip('Трен.', dog.trainability),
                      _statChip(
                        'Жизнь',
                        '${dog.minLifeExpectancy}-${dog.maxLifeExpectancy}',
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: onFavoriteTap,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: onDetailsTap,
                          child: const Text('Подробнее'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, Object value) {
    return Chip(
      label: Text('$label: $value'),
      visualDensity: VisualDensity.compact,
    );
  }
}