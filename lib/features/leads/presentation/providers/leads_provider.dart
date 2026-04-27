import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/lead_model.dart';
import '../../../../services/leads_service.dart';

class LeadsState {
  final bool isLoading;
  final List<LeadModel> leads;
  final String? error;
  final LeadModel? selectedLead;

  LeadsState({
    this.isLoading = false,
    this.leads = const [],
    this.error,
    this.selectedLead,
  });

  LeadsState copyWith({
    bool? isLoading,
    List<LeadModel>? leads,
    String? error,
    LeadModel? selectedLead,
  }) {
    return LeadsState(
      isLoading: isLoading ?? this.isLoading,
      leads: leads ?? this.leads,
      error: error,
      selectedLead: selectedLead ?? this.selectedLead,
    );
  }
}

final leadsProvider = StateNotifierProvider<LeadsNotifier, LeadsState>((ref) {
  final leadsService = ref.watch(leadsServiceProvider);
  return LeadsNotifier(leadsService);
});

class LeadsNotifier extends StateNotifier<LeadsState> {
  final LeadsService _leadsService;

  LeadsNotifier(this._leadsService) : super(LeadsState()) {
    fetchLeads();
  }

  Future<void> fetchLeads() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final leads = await _leadsService.fetchAssignedLeads();
      state = state.copyWith(isLoading: false, leads: leads);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateLeadStage(String leadId, String newStageId) async {
    try {
      final updatedLead = await _leadsService.updateLeadStage(leadId, newStageId);
      
      final updatedLeads = state.leads.map((lead) {
        return lead.id == leadId ? updatedLead : lead;
      }).toList();

      state = state.copyWith(leads: updatedLeads, selectedLead: updatedLead);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void selectLead(String leadId) {
    try {
      final lead = state.leads.firstWhere((l) => l.id == leadId);
      state = state.copyWith(selectedLead: lead);
    } catch (e) {
      // Handle if not found
    }
  }

  Future<void> assignLead(String leadId, String assigneeId) async {
    try {
      final updatedLead = await _leadsService.assignLead(leadId, assigneeId);
      
      final updatedLeads = state.leads.map((lead) {
        return lead.id == leadId ? updatedLead : lead;
      }).toList();

      state = state.copyWith(leads: updatedLeads, selectedLead: updatedLead);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> createLead(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newLead = await _leadsService.createLead(data);
      state = state.copyWith(
        isLoading: false,
        leads: [newLead, ...state.leads],
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
