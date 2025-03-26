import 'package:equatable/equatable.dart';
import 'package:vjptest/models/company_model.dart';

enum CompanyStatus { initial, loading, success, failure }

class CompanyState extends Equatable {
  final List<Company> companies;
  final List<Company> vietnamCompanies;
  final List<Company> japanCompanies;
  final List<Company> filteredCompanies;
  final CompanyStatus status;
  final String error;
  final String searchQuery;
  final String industryFilter;
  final Company? selectedCompany;

  const CompanyState({
    this.companies = const [],
    this.vietnamCompanies = const [],
    this.japanCompanies = const [],
    this.filteredCompanies = const [],
    this.status = CompanyStatus.initial,
    this.error = '',
    this.searchQuery = '',
    this.industryFilter = '',
    this.selectedCompany,
  });

  CompanyState copyWith({
    List<Company>? companies,
    List<Company>? vietnamCompanies,
    List<Company>? japanCompanies,
    List<Company>? filteredCompanies,
    CompanyStatus? status,
    String? error,
    String? searchQuery,
    String? industryFilter,
    Company? selectedCompany,
    bool? clearSelectedCompany,
  }) {
    return CompanyState(
      companies: companies ?? this.companies,
      vietnamCompanies: vietnamCompanies ?? this.vietnamCompanies,
      japanCompanies: japanCompanies ?? this.japanCompanies,
      filteredCompanies: filteredCompanies ?? this.filteredCompanies,
      status: status ?? this.status,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      industryFilter: industryFilter ?? this.industryFilter,
      selectedCompany: clearSelectedCompany == true ? null : selectedCompany ?? this.selectedCompany,
    );
  }

  @override
  List<Object?> get props => [
    companies,
    vietnamCompanies,
    japanCompanies,
    filteredCompanies,
    status,
    error,
    searchQuery,
    industryFilter,
    selectedCompany,
  ];
} 