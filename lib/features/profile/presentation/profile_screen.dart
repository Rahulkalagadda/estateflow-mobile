import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../../core/network/api_client.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../leads/presentation/providers/leads_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final leadState = ref.watch(leadsProvider);
    
    final totalLeads = leadState.leads.length;
    final totalPortfolio = leadState.leads.fold(0.0, (sum, l) => sum + (l.budget ?? 0));
    final fmtPortfolio = totalPortfolio >= 10000000 
        ? '₹${(totalPortfolio / 10000000).toStringAsFixed(1)} Cr' 
        : '₹${(totalPortfolio / 100000).toStringAsFixed(1)} L';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        color: context.colors.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.network(
                          'https://i.pravatar.cc/200?u=${user?.id}',
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.person, size: 64, color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Icon(Icons.edit, size: 20, color: context.colors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('${user?.firstName ?? ''} ${user?.lastName ?? ''}', style: Theme.of(context).textTheme.displayMedium),
                SizedBox(height: 4),
                Text(user?.role ?? 'Agent', style: TextStyle(fontWeight: FontWeight.w500, color: context.colors.onSurfaceVariant)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildBadge('Top Producer', context.colors.secondaryContainer.withValues(alpha: 0.3), context.colors.onSecondaryFixedVariant),
                    SizedBox(width: 8),
                    _buildBadge(user?.role ?? 'MEMBER', context.colors.primaryFixed, context.colors.onPrimaryFixed),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(context, 'Portfolio', fmtPortfolio),
                _buildStatCard(context, 'Active Leads', totalLeads.toString()),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: context.colors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RESPONSE TIME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: context.colors.onSurfaceVariant)),
                      SizedBox(height: 4),
                      Text('1.2h', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: context.colors.primary)),
                    ],
                  ),
                  Icon(Icons.bolt, size: 32, color: context.colors.secondaryContainer),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Settings Sections
            _buildSettingsSection(
              context,
              title: 'Account Settings',
              items: [
                _buildSettingsItem(context, icon: Icons.person, iconBg: context.colors.primaryFixed, iconColor: context.colors.primary, title: 'Personal Information', subtitle: 'Update your details and contact info'),
                _buildSettingsItem(context, icon: Icons.lock, iconBg: context.colors.primaryFixed, iconColor: context.colors.primary, title: 'Password & Security', subtitle: 'Manage your credentials and 2FA'),
                if (ref.watch(authProvider).user?.role != 'EMPLOYEE')
                  _buildSettingsItem(
                    context,
                    icon: Icons.diversity_3, 
                    iconBg: context.colors.secondaryContainer.withValues(alpha: 0.2), 
                    iconColor: context.colors.primary, 
                    title: 'Team Management', 
                    subtitle: 'Manage members and performance',
                    onTap: () => context.push('/profile/team'),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSettingsSection(
              context,
              title: 'Preferences',
              items: [
                _buildSettingsItem(
                  context,
                  icon: Icons.dark_mode, 
                  iconBg: context.colors.tertiaryFixed, 
                  iconColor: context.colors.onTertiaryFixedVariant, 
                  title: 'Dark Mode', 
                  subtitle: 'Switch to high-contrast night view', 
                  isToggle: true,
                  switchValue: ref.watch(themeModeProvider) == ThemeMode.dark || (ref.watch(themeModeProvider) == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark),
                  onSwitchChanged: (val) async {
                    ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                    try {
                      final storage = ref.read(secureStorageProvider);
                      await storage.write(key: 'theme_mode', value: val ? 'dark' : 'light');
                    } catch (e) {
                      // ignore storage errors
                    }
                  },
                ),
                _buildSettingsItem(context, icon: Icons.notifications, iconBg: context.colors.tertiaryFixed, iconColor: context.colors.onTertiaryFixedVariant, title: 'Notifications', subtitle: 'Email, Push and SMS alerts'),
              ],
            ),
            const SizedBox(height: 24),

            _buildSettingsSection(
              context,
              title: 'Support & About',
              items: [
                _buildSettingsItem(context, icon: Icons.help, iconBg: context.colors.surfaceContainerHigh, iconColor: context.colors.onSurfaceVariant, title: 'Help Center', subtitle: 'Documentation and support tickets'),
                _buildSettingsItem(context, icon: Icons.description, iconBg: context.colors.surfaceContainerHigh, iconColor: context.colors.onSurfaceVariant, title: 'Terms of Service', subtitle: 'Legal information and privacy policy'),
              ],
            ),
            const SizedBox(height: 32),

            // Logout
            ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.errorContainer,
                foregroundColor: context.colors.onErrorContainer,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ESTATE LOGIC V2.4.0 • ENTERPRISE EDITION',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: context.colors.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(text.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: textColor)),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: context.colors.surfaceContainerLow, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: context.colors.onSurfaceVariant)),
          Spacer(),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: context.colors.primary)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, {required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2, color: context.colors.onSurfaceVariant)),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 8)),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(height: 1, color: context.colors.outlineVariant.withValues(alpha: 0.2)),
            itemBuilder: (context, index) => items[index],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool isToggle = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: context.colors.onSurface)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: context.colors.onSurfaceVariant)),
                ],
              ),
            ),
            if (isToggle)
              Switch(value: switchValue, onChanged: onSwitchChanged, activeThumbColor: context.colors.primary)
            else
              Icon(Icons.chevron_right, color: context.colors.outline),
          ],
        ),
      ),
    );
  }
}
