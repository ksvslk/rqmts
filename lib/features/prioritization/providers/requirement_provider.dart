import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rqmts/features/prioritization/models/prioritization_state.dart';
import 'package:rqmts/features/prioritization/models/requirement_model.dart';

final List<Requirement> _initialRequirements = [];

class PrioritizationNotifier extends StateNotifier<PrioritizationState> {
  PrioritizationNotifier() : super( PrioritizationState(requirements: _initialRequirements));

  void startSorting() {
    state =  PrioritizationState(
      requirements: _initialRequirements,
      isSorting: true,
    );
  }

  void cancelSorting() {
    state =  PrioritizationState(requirements: _initialRequirements);
  }

  void userMadeChoice(Requirement chosenRequirement) {
    if (!state.isSorting) return;

    final currentList = List<Requirement>.from(state.requirements);
    final i = state.pass;
    final j = state.comparison;

    final item1 = currentList[j];
    final item2 = currentList[j + 1];

    // If the user chose the second item, it means it's higher priority,
    // so we perform a swap to "bubble it up".
    if (chosenRequirement.id == item2.id) {
      currentList[j] = item2;
      currentList[j + 1] = item1;
    }

    // --- Advance to the next step of the bubble sort ---
    int nextComparison = j + 1;
    int nextPass = i;

    // If we've reached the end of the inner loop (comparison loop)
    if (nextComparison >= currentList.length - i - 1) {
      nextPass++; // Start the next pass
      nextComparison = 0; // Reset comparison index
    }

    // If we've reached the end of the outer loop (pass loop)
    if (nextPass >= currentList.length - 1) {
      // Sorting is complete!
      state = state.copyWith(
        requirements: currentList,
        isSorting: false,
        isFinished: true,
      );
    } else {
      // Continue to the next comparison
      state = state.copyWith(
        requirements: currentList,
        pass: nextPass,
        comparison: nextComparison,
      );
    }
  }
}

final prioritizationProvider =
    StateNotifierProvider<PrioritizationNotifier, PrioritizationState>((ref) {
  return PrioritizationNotifier();
});