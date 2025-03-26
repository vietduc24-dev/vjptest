import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vjptest/features/company/cubit/company_state.dart';
import 'package:vjptest/features/company/repository/company_repository.dart';
import 'package:vjptest/models/company_model.dart';

class CompanyCubit extends Cubit<CompanyState> {
  final CompanyRepository _companyRepository;

  CompanyCubit({required CompanyRepository companyRepository})
      : _companyRepository = companyRepository,
        super(const CompanyState());

  // Lấy tất cả công ty
  Future<void> fetchCompanies() async {
    try {
      emit(state.copyWith(status: CompanyStatus.loading));

      final companies = await _companyRepository.getCompaniesFromLocal();
      final vietnamCompanies = await _companyRepository.getVietnamCompanies();
      final japanCompanies = await _companyRepository.getJapanCompanies();

      emit(state.copyWith(
        companies: companies,
        vietnamCompanies: vietnamCompanies,
        japanCompanies: japanCompanies,
        filteredCompanies: companies,
        status: CompanyStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        error: e.toString(),
      ));
    }
  }

  // Lấy công ty Việt Nam
  Future<void> fetchVietnamCompanies() async {
    try {
      emit(state.copyWith(status: CompanyStatus.loading));

      final vietnamCompanies = await _companyRepository.getVietnamCompanies();

      emit(state.copyWith(
        vietnamCompanies: vietnamCompanies,
        filteredCompanies: vietnamCompanies,
        status: CompanyStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        error: e.toString(),
      ));
    }
  }

  // Lấy công ty Nhật Bản
  Future<void> fetchJapanCompanies() async {
    try {
      emit(state.copyWith(status: CompanyStatus.loading));

      final japanCompanies = await _companyRepository.getJapanCompanies();

      emit(state.copyWith(
        japanCompanies: japanCompanies,
        filteredCompanies: japanCompanies,
        status: CompanyStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        error: e.toString(),
      ));
    }
  }

  // Tìm kiếm công ty
  Future<void> searchCompanies(String query) async {
    try {
      emit(state.copyWith(
        status: CompanyStatus.loading,
        searchQuery: query,
      ));

      final filteredCompanies = await _companyRepository.searchCompanies(query);

      emit(state.copyWith(
        filteredCompanies: filteredCompanies,
        status: CompanyStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        error: e.toString(),
      ));
    }
  }

  // Lọc công ty theo ngành nghề
  Future<void> filterCompaniesByIndustry(String industry) async {
    try {
      emit(state.copyWith(
        status: CompanyStatus.loading,
        industryFilter: industry,
      ));

      final filteredCompanies = await _companyRepository.getCompaniesByIndustry(industry);

      emit(state.copyWith(
        filteredCompanies: filteredCompanies,
        status: CompanyStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        error: e.toString(),
      ));
    }
  }

  // Lấy chi tiết công ty theo tên
  Future<void> getCompanyDetail(String name) async {
    try {
      emit(state.copyWith(status: CompanyStatus.loading));

      final company = await _companyRepository.getCompanyByName(name);

      if (company != null) {
        emit(state.copyWith(
          selectedCompany: company,
          status: CompanyStatus.success,
        ));
      } else {
        emit(state.copyWith(
          status: CompanyStatus.failure,
          error: 'Không tìm thấy công ty',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CompanyStatus.failure,
        error: e.toString(),
      ));
    }
  }

  // Reset bộ lọc
  void resetFilters() {
    emit(state.copyWith(
      filteredCompanies: state.companies,
      searchQuery: '',
      industryFilter: '',
      status: CompanyStatus.success,
    ));
  }
  
  // Reset lựa chọn công ty
  void clearSelectedCompany() {
    emit(state.copyWith(
      clearSelectedCompany: true,
    ));
  }
} 