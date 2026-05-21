import 'package:cryprice_frontend/core/navigation/app_section.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Shell tab selection. Titles are resolved in widgets via [AppLocalizations].
class ShellNavigationState {
  const ShellNavigationState({required this.selectedSection});

  final AppSection selectedSection;

  ShellNavigationState copyWith({AppSection? selectedSection}) {
    return ShellNavigationState(
      selectedSection: selectedSection ?? this.selectedSection,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ShellNavigationState &&
            selectedSection == other.selectedSection;
  }

  @override
  int get hashCode => selectedSection.hashCode;
}

class ShellNavigationCubit extends Cubit<ShellNavigationState> {
  ShellNavigationCubit()
      : super(
          const ShellNavigationState(
            selectedSection: AppSection.priceCalculator,
          ),
        );

  void selectSection(AppSection section) {
    if (state.selectedSection == section) {
      return;
    }
    emit(state.copyWith(selectedSection: section));
  }
}
