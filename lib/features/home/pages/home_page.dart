import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vjptest/common/colors.dart';
import '../../../features/authentication/cubit/login/login_cubit.dart';
import '../../../features/authentication/cubit/login/login_state.dart';
import '../../../features/company/cubit/company_cubit.dart';
import '../../../features/company/cubit/company_state.dart';
import '../../../models/company_model.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.user == null) {
          AppRouter.goToLogin(context);
        }
      },
      builder: (context, state) {
        final User? user = state.user;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Image.asset(
                  'assets/images/logoVJP.png',
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 8),
              ],
            ),
            backgroundColor: UIColors.yellow,
            elevation: 0,
            actions: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // TODO: Chuyển sang tiếng Việt
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Image.asset(
                        'assets/images/logo1VN.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Chuyển sang tiếng Nhật
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Image.asset(
                        'assets/images/logo2JP.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Chuyển sang tiếng Anh
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Image.asset(
                        'assets/images/logo3ENG.png',
                        width: 28,
                        height: 28,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: BlocBuilder<CompanyCubit, CompanyState>(
            builder: (context, companyState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.blue[700]!, Colors.blue[500]!],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/vjp-banner.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.blue[900]!.withOpacity(0.7),
                                  Colors.blue[800]!.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _showSearchBottomSheet(context);
                                  },
                                  icon: const Icon(Icons.search),
                                  label: const Text('Tìm doanh nghiệp'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.blue[700],
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Phần Công ty nổi bật
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Doanh nghiệp Việt Nam nổi bật',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Xem tất cả công ty
                                },
                                child: const Text('Xem tất cả'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFeaturedCompanies(companyState),
                          
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Doanh nghiệp Nhật Bản',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Xem tất cả công ty Nhật
                                },
                                child: const Text('Xem tất cả'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildJapaneseCompanies(companyState),
                          
                          const SizedBox(height: 24),
                          Text(
                            'Chuyên gia hỗ trợ',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildExperts(),
                          
                          const SizedBox(height: 24),
                          const Text(
                            'Liên hệ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildContactInfo(),
                          
                          const SizedBox(height: 24),
                          const Text(
                            'Đối tác và khách hàng',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPartners(),
                          
                          const SizedBox(height: 30),
                          _buildFooter(context),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        );
      },
    );
  }
  
  void _showSearchBottomSheet(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<Company> searchResults = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void performSearch(String query) {
              setState(() {
                isSearching = true;
              });
              
              final companyCubit = context.read<CompanyCubit>();
              companyCubit.searchCompanies(query).then((_) {
                setState(() {
                  searchResults = companyCubit.state.filteredCompanies;
                  isSearching = false;
                });
              });
            }
            
            final companyState = context.watch<CompanyCubit>().state;
            final vietnamCompanies = companyState.vietnamCompanies;
            final japanCompanies = companyState.japanCompanies;
            
            return Container(
              padding: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Tìm kiếm doanh nghiệp',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên doanh nghiệp, ngành nghề...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchResults.clear();
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onSubmitted: (value) {
                      performSearch(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              searchResults = vietnamCompanies;
                            });
                          },
                          icon: const Icon(Icons.business),
                          label: const Text('Doanh nghiệp VN'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              searchResults = japanCompanies;
                            });
                          },
                          icon: const Icon(Icons.business),
                          label: const Text('Doanh nghiệp JP'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ngành nghề',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildIndustryChip('Tư vấn tuyển dụng', () {
                        performSearch('Tư vấn tuyển dụng');
                      }),
                      _buildIndustryChip('Sản xuất', () {
                        performSearch('Sản xuất');
                      }),
                      _buildIndustryChip('Thực phẩm & Đồ uống', () {
                        performSearch('Thực phẩm');
                      }),
                      _buildIndustryChip('Y tế', () {
                        performSearch('Y tế');
                      }),
                      _buildIndustryChip('Công nghệ', () {
                        performSearch('Công nghệ');
                      }),
                      _buildIndustryChip('Giáo dục', () {
                        performSearch('Giáo dục');
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isSearching ? 'Đang tìm kiếm...' :
                        searchResults.isEmpty && searchController.text.isEmpty
                            ? 'Doanh nghiệp nổi bật'
                            : 'Kết quả tìm kiếm (${searchResults.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (searchResults.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              searchResults.clear();
                              searchController.clear();
                            });
                          },
                          child: const Text('Xóa tất cả'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: isSearching
                        ? const Center(child: CircularProgressIndicator())
                        : searchResults.isEmpty && searchController.text.isEmpty
                            ? _buildDefaultSearchResults(vietnamCompanies, japanCompanies)
                            : searchResults.isEmpty
                                ? const Center(child: Text('Không tìm thấy kết quả nào'))
                                : ListView.builder(
                                    itemCount: searchResults.length,
                                    itemBuilder: (context, index) {
                                      final company = searchResults[index];
                                      final isVietnamCompany = company.isVietnamCompany;
                                      return ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: isVietnamCompany ? Colors.blue[50] : Colors.red[50],
                                          child: Icon(
                                            Icons.business,
                                            color: isVietnamCompany ? Colors.blue[700] : Colors.red[700],
                                          ),
                                        ),
                                        title: Flexible(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  company.name,
                                                  style: _blackTextStyle,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (company.customersAndPartners != null && company.customersAndPartners!.isNotEmpty)
                                                SvgPicture.network(
                                                  'https://vjp-connect.com/_next/static/media/Icon_Group.e6df7480.svg',
                                                  width: 20,
                                                  height: 20,
                                                  colorFilter: ColorFilter.mode(
                                                    Colors.grey[600]!,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        subtitle: Text(
                                          company.industry,
                                          style: _blackSubtitleStyle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: const Icon(Icons.chevron_right),
                                        onTap: () {
                                          // TODO: Mở chi tiết công ty
                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDefaultSearchResults(List<Company> vietnamCompanies, List<Company> japanCompanies) {
    List<Company> combined = [];
    if (vietnamCompanies.isNotEmpty) {
      combined.add(vietnamCompanies.first);
    }
    if (japanCompanies.isNotEmpty) {
      combined.add(japanCompanies.first);
    }
    
    return ListView.builder(
      itemCount: combined.length,
      itemBuilder: (context, index) {
        final company = combined[index];
        final isVietnamCompany = company.isVietnamCompany;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isVietnamCompany ? Colors.blue[50] : Colors.red[50],
            child: Icon(
              Icons.business,
              color: isVietnamCompany ? Colors.blue[700] : Colors.red[700],
            ),
          ),
          title: Flexible(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    company.name,
                    style: _blackTextStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          subtitle: Text(
            company.industry,
            style: _blackSubtitleStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Mở chi tiết công ty
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildIndustryChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildFeaturedCompanies(CompanyState state) {
    if (state.status == CompanyStatus.loading) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (state.vietnamCompanies.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: const Text('Không có dữ liệu công ty'),
      );
    }

    return SizedBox(
      height: 260, // Adjusted height for better mobile view
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.vietnamCompanies.length,
        itemBuilder: (context, index) {
          final company = state.vietnamCompanies[index];
          return _buildCompanyCard(company, true); // Pass isVietnamCompany as true
        },
      ),
    );
  }

  Widget _buildJapaneseCompanies(CompanyState state) {
    if (state.status == CompanyStatus.loading) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    if (state.japanCompanies.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: const Text('Không có dữ liệu công ty Nhật Bản'),
      );
    }

    return SizedBox(
      height: 260, // Adjusted height for better mobile view
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.japanCompanies.length,
        itemBuilder: (context, index) {
          final company = state.japanCompanies[index];
          return _buildCompanyCard(company, false); // Pass isVietnamCompany as false
        },
      ),
    );
  }

  Widget _buildCompanyCard(Company company, bool isVietnamCompany) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/backgroundCompany.jpg'),
                      fit: BoxFit.cover,
                      opacity: 0.5,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue[900]!.withOpacity(0.7),
                              Colors.blue[500]!.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.network(
                                  company.image,
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) => Text(
                                    company.name.toString().substring(0, 2).toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: isVietnamCompany ? Colors.blue[700] : Colors.red[700],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    company.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    company.industry,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Thành lập: ${company.yearFounded}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (company.customersAndPartners != null && company.customersAndPartners!.isNotEmpty)
                            SvgPicture.network(
                              'https://vjp-connect.com/_next/static/media/Icon_Group.e6df7480.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                Colors.grey[600]!,
                                BlendMode.srcIn,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.people,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Nhân viên: ${company.employees}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to company details
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isVietnamCompany ? Colors.blue[50] : Colors.red[50],
                          foregroundColor: isVietnamCompany ? Colors.blue[700] : Colors.red[700],
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Chi tiết',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
  
  Widget _buildExperts() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.grey[100],
                  child: Image.asset(
                    'assets/images/default_avatar.png',
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) => Text(
                      'E${index + 1}',
                      style: _getExpertNameStyle(index),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chuyên gia ${index + 1}',
                  textAlign: TextAlign.center,
                  style: _getLabelStyle(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: const Text(
                  'Bạn muốn đăng thông tin doanh nghiệp miễn phí?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 32),
            child: Text('Hãy bắt đầu từ đăng ký thành viên.'),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.person_add),
            label: const Text('Đăng ký tài khoản'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.contact_support_outlined,
                color: Colors.blue[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: const Text(
                  'Bạn cần tư vấn ngay?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(left: 32),
            child: Text('Hãy liên hệ email vjpconnect@vj-partner.com hoặc nhấn nút "Đăng ký tư vấn" để nhập thông tin liên hệ'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.support_agent),
            label: const Text('Đăng ký tư vấn'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[700],
              side: BorderSide(color: Colors.blue[700]!),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPartners() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Text(
            'VJP Connect Platform (VJP-CONNECT.COM) là nền tảng chuyên hỗ trợ quảng bá doanh nghiệp, tìm đối tác, kết nối chuyên gia Việt Nam và Nhật Bản trong nhiều lĩnh vực.',
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(height: 8),
          Text(
            'Nền tảng được vận hành bởi công ty Viet Japan Partner Cooperation - thành viên của hệ sinh thái hỗ trợ doanh nghiệp Nhật Bản của Viet Japan Partner Group.',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin liên lạc',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.business,
              color: Colors.blue[700],
              size: 24,
            ),
          ),
          title: const Text(
            'VIET JAPAN PARTNER COOPERATION CO.,LTD',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          subtitle: const Text(
            'P1.3-40, The Prince Residence-Novaland, 17-19-21 Đ. Nguyễn Văn Trỗi, Phường 14, Hồ Chí Minh',
            style: TextStyle(fontSize: 12),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.phone,
              color: Colors.blue[700],
              size: 24,
            ),
          ),
          title: const Text(
            '(+84) 028 7303 8939',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.email,
              color: Colors.blue[700],
              size: 24,
            ),
          ),
          title: Text(
            'vjpconnect@vj-partner.com',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.blue[700]),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '©2023 Bản quyền thuộc về VIET JAPAN DIGITAL CO.,LTD',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
  
  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: _getLabelStyle(),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  TextStyle get _blackTextStyle => const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 14,
    color: Colors.black,
  );
  
  TextStyle get _blackSubtitleStyle => const TextStyle(
    color: Colors.black,
    fontSize: 12,
  );

  TextStyle _getExpertNameStyle(int index) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.primaries[index % Colors.primaries.length].shade800,
    );
  }
  
  TextStyle _getLabelStyle() {
    return TextStyle(
      fontSize: 12,
      color: Colors.grey[600],
    );
  }
} 