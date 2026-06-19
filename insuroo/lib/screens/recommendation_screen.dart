import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Form controllers
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  final _incomeController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isFarmer = false;
  bool _isBPL = false;
  bool _hasPreexisting = false;

  bool _isLoading = false;
  RecommendationResponse? _response;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _incomeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _getRecommendations() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _response = null;
    });

    try {
      final profile = UserProfile(
        name: _nameController.text,
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        occupation: _occupationController.text,
        annualIncome: double.parse(_incomeController.text),
        isFarmer: _isFarmer,
        isBelowPovertyLine: _isBPL,
        hasPreexistingConditions: _hasPreexisting,
        additionalInfo: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
      );

      // Simulate a small delay for better UX "thinking" feel
      await Future.delayed(const Duration(seconds: 1));

      final result = await _apiService.getRecommendations(profile);
      setState(() {
        _response = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policy Recommendations'),
        centerTitle: true,
      ),
      body: _response == null ? _buildForm() : _buildResults(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tell us about yourself',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Fill in your details to get personalized insurance recommendations.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => v!.isEmpty ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'e.g. 35',
                      prefixIcon: Icon(Icons.cake_outlined),
                    ),
                    validator: (v) => v!.isEmpty ? 'Age required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.people_outline),
                    ),
                    items: ['Male', 'Female', 'Other']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedGender = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _occupationController,
              decoration: const InputDecoration(
                labelText: 'Occupation',
                hintText: 'e.g. Farmer, Teacher',
                prefixIcon: Icon(Icons.work_outline),
              ),
              validator: (v) => v!.isEmpty ? 'Occupation required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Annual Income (₹)',
                hintText: 'e.g. 250000',
                prefixIcon: Icon(Icons.currency_rupee),
              ),
              validator: (v) => v!.isEmpty ? 'Income required' : null,
            ),
            const SizedBox(height: 20),
            _buildSwitchTile(
              'Are you a Farmer?',
              _isFarmer,
              (v) => setState(() => _isFarmer = v),
              Icons.agriculture,
            ),
            _buildSwitchTile(
              'Below Poverty Line (BPL)?',
              _isBPL,
              (v) => setState(() => _isBPL = v),
              Icons.trending_down,
            ),
            _buildSwitchTile(
              'Pre-existing Health Conditions?',
              _hasPreexisting,
              (v) => setState(() => _hasPreexisting = v),
              Icons.health_and_safety_outlined,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _additionalInfoController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Additional Information (Optional)',
                hintText: 'e.g. I have a family of 4, I travel frequently...',
                prefixIcon: Icon(Icons.info_outline),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _getRecommendations,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: AppTheme.primaryColor.withOpacity(0.5),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Get Recommendations',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, bool value, Function(bool) onChanged, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: value ? AppTheme.primaryColor : Colors.transparent,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(icon,
                    color:
                        value ? AppTheme.accentColor : AppTheme.textSecondary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: AppTheme.accentColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDark,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Hello, ${_response!.userName}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _response!.summary,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Top 3 Recommended Schemes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
                const SizedBox(height: 16),
                ..._response!.recommendations
                    .map((policy) => _buildPolicyCard(policy)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextButton(
              onPressed: () => setState(() => _response = null),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
              child: const Text('← Edit Profile Details'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard(RecommendedPolicy policy) {
    Color statusColor;
    if (policy.eligibilityStatus.contains('Highly')) {
      statusColor = AppTheme.primaryColor;
    } else if (policy.eligibilityStatus.contains('Eligible')) {
      statusColor = AppTheme.accentColor;
    } else {
      statusColor = AppTheme.errorColor;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withOpacity(0.2), Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    policy.policyName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    policy.eligibilityStatus,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WHY IT FITS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  policy.reasoning,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'KEY BENEFITS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ...policy.benefits.map((benefit) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: statusColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              benefit,
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
