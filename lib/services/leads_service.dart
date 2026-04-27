import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/models/lead_model.dart';

final leadsServiceProvider = Provider<LeadsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LeadsService(apiClient);
});

class LeadsService {
  final ApiClient _apiClient;

  LeadsService(this._apiClient);

  Future<List<LeadModel>> fetchAssignedLeads() async {
    try {
      final response = await _apiClient.dio.get('/leads');
      return (response.data['data'] as List).map((json) => LeadModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch leads: $e');
    }
  }

  Future<LeadModel> updateLeadStage(String leadId, String newStageId) async {
    try {
      final response = await _apiClient.dio.patch('/leads/$leadId/stage', data: {'stageId': newStageId});
      return LeadModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to update lead stage: $e');
    }
  }

  Future<LeadModel> assignLead(String leadId, String assigneeId) async {
    try {
      final response = await _apiClient.dio.patch('/leads/$leadId/assign', data: {'assigneeId': assigneeId});
      return LeadModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to assign lead: $e');
    }
  }

  Future<LeadModel> createLead(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/leads', data: data);
      return LeadModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('Failed to create lead: $e');
    }
  }
}
