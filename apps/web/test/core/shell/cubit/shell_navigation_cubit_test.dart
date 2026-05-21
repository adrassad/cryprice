import 'package:bloc_test/bloc_test.dart';
import 'package:cryprice_frontend/core/navigation/app_section.dart';
import 'package:cryprice_frontend/core/shell/cubit/shell_navigation_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShellNavigationCubit', () {
    test('initial selectedSection is priceCalculator', () {
      final cubit = ShellNavigationCubit();
      addTearDown(cubit.close);

      expect(
        cubit.state,
        const ShellNavigationState(selectedSection: AppSection.priceCalculator),
      );
    });

    blocTest<ShellNavigationCubit, ShellNavigationState>(
      'selectSection emits when section changes',
      build: ShellNavigationCubit.new,
      act: (ShellNavigationCubit cubit) {
        cubit.selectSection(AppSection.portfolio);
        cubit.selectSection(AppSection.healthFactorCalculator);
      },
      expect: () => <ShellNavigationState>[
        const ShellNavigationState(selectedSection: AppSection.portfolio),
        const ShellNavigationState(
          selectedSection: AppSection.healthFactorCalculator,
        ),
      ],
    );

    blocTest<ShellNavigationCubit, ShellNavigationState>(
      'selectSection does not emit when section is unchanged',
      build: ShellNavigationCubit.new,
      seed: () => const ShellNavigationState(selectedSection: AppSection.portfolio),
      act: (ShellNavigationCubit cubit) {
        cubit.selectSection(AppSection.portfolio);
      },
      expect: () => <ShellNavigationState>[],
    );
  });
}
