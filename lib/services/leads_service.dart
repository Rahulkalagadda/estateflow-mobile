import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/models/lead_model.dart';

final leadsServiceProvider = Provider<LeadsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LeadsService(apiClient);
});

class LeadsService {
  final ApiClient _apiClient;

  LeadsService(this._apiClient);

  String _readableError(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
        if (message is List && message.isNotEmpty) {
          return message.join(', ');
        }
      }
      if (e.response?.statusCode == 409) {
        return 'A lead with the same email or phone already exists.';
      }
    }
    return fallback;
  }

  Future<List<LeadModel>> fetchAssignedLeads() async {
    try {
      final response = await _apiClient.dio.get('/leads');
      return (response.data['data'] as List).map((json) => LeadModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception(_readableError(e, 'Failed to fetch leads'));
    }
  }

  Future<LeadModel> updateLeadStage(String leadId, String newStageId) async {
    try {
      final response = await _apiClient.dio.patch('/leads/$leadId/stage', data: {'stageId': newStageId});
      return LeadModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception(_readableError(e, 'Failed to update lead stage'));
    }
  }

  Future<LeadModel> assignLead(String leadId, String assigneeId) async {
    try {
      final response = await _apiClient.dio.patch('/leads/$leadId/assign', data: {'assigneeId': assigneeId});
      return LeadModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception(_readableError(e, 'Failed to assign lead'));
    }
  }

  Future<LeadModel> createLead(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post('/leads', data: data);
      return LeadModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception(_readableError(e, 'Failed to create lead'));
    }
  }

  Future<LeadModel> updateLead(String leadId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.patch('/leads/$leadId', data: data);
      return LeadModel.fromJson(response.data['data']);
    } catch (e) {
      throw Exception(_readableError(e, 'Failed to update lead'));
    }
  }
}
