import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:vjptest/models/company_model.dart';

class CompanyRepository {
  // Phương thức lấy danh sách công ty từ file JSON local
  Future<List<Company>> getCompaniesFromLocal() async {
    try {
      // Đọc file JSON từ assets với đường dẫn tương đối như khai báo trong pubspec.yaml
      final String response = await rootBundle.loadString('lib/common/datatest/companies.json');
      final Map<String, dynamic> data = json.decode(response);
      
      if (data.containsKey('companies') && data['companies'] is List) {
        List<dynamic> companiesJson = data['companies'];
        return companiesJson.map((json) => Company.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      print('Error loading companies from local: $e');
      return [];
    }
  }
  
  // Phương thức lấy công ty Việt Nam
  Future<List<Company>> getVietnamCompanies() async {
    final companies = await getCompaniesFromLocal();
    return companies.where((company) => company.isVietnamCompany).toList();
  }
  
  // Phương thức lấy công ty Nhật Bản
  Future<List<Company>> getJapanCompanies() async {
    final companies = await getCompaniesFromLocal();
    return companies.where((company) => !company.isVietnamCompany).toList();
  }
  
  // Phương thức tìm kiếm công ty
  Future<List<Company>> searchCompanies(String query) async {
    final companies = await getCompaniesFromLocal();
    if (query.isEmpty) return companies;
    
    final lowercaseQuery = query.toLowerCase();
    return companies.where((company) => 
      company.name.toLowerCase().contains(lowercaseQuery) ||
      company.industry.toLowerCase().contains(lowercaseQuery) ||
      company.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
  
  // Phương thức lấy chi tiết công ty theo tên
  Future<Company?> getCompanyByName(String name) async {
    final companies = await getCompaniesFromLocal();
    try {
      return companies.firstWhere((company) => company.name == name);
    } catch (e) {
      return null;
    }
  }
  
  // Phương thức lấy công ty theo ngành nghề
  Future<List<Company>> getCompaniesByIndustry(String industry) async {
    final companies = await getCompaniesFromLocal();
    if (industry.isEmpty) return companies;
    
    final lowercaseIndustry = industry.toLowerCase();
    return companies.where((company) => 
      company.industry.toLowerCase().contains(lowercaseIndustry)
    ).toList();
  }
} 