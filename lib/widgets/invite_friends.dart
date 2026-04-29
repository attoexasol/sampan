import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sampan/constants/colors.dart';
import 'package:sampan/data/models/referral_response_model.dart';
import 'package:sampan/data/service/referral_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds share message with dynamic referral code only (no hardcoded code).
String buildReferralShareMessage(ReferralResponseModel model) {
  final code = model.referralCode;
  return 'Try Sampan for laundry pickup and delivery. Use my referral code: $code.';
}

class InviteFriendsWidget {
  /// Shows invite dialog. Requires valid [customerId]; caller should use CustomerSessionHelper.requireCustomerIdOrRedirect() first.
  static void showInviteDialog(BuildContext context, {required String customerId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _InviteFriendsDialog(customerId: customerId),
    );
  }

  static Widget _inviteOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 28, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }
}

class _InviteFriendsDialog extends StatefulWidget {
  final String customerId;

  const _InviteFriendsDialog({required this.customerId});

  @override
  State<_InviteFriendsDialog> createState() => _InviteFriendsDialogState();
}

class _InviteFriendsDialogState extends State<_InviteFriendsDialog> {
  ReferralResponseModel? _referral;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReferral();
  }

  Future<void> _fetchReferral() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final model = await ReferralService.fetchReferral(widget.customerId);
      if (!mounted) return;
      if (model == null || !model.isSuccess || !model.hasValidCode) {
        setState(() {
          _loading = false;
          _error = 'Could not load referral. Please try again.';
          _referral = null;
        });
        return;
      }
      setState(() {
        _referral = model;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong. Please try again.';
        _referral = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _loading || _referral == null
                  ? 'Invite Friends & Earn'
                  : 'Invite Friends & Earn ${_referral!.existingCustomerRewardText}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _error!,
            style: TextStyle(color: AppColors.mutedForeground),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _fetchReferral,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      );
    }
    final model = _referral!;
    final shareMessage = buildReferralShareMessage(model);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Share Sampan with friends and earn ${model.existingCustomerRewardText} credit when they join using your referral code.',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Your referral code: ${model.referralCode}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          InviteFriendsWidget._inviteOption(
            icon: FontAwesomeIcons.whatsapp,
            title: 'WhatsApp',
            subtitle: 'Share via WhatsApp',
            onTap: () => _shareViaWhatsApp(context, shareMessage),
          ),
          InviteFriendsWidget._inviteOption(
            icon: Icons.sms,
            title: 'Text Message',
            subtitle: 'Share via SMS',
            onTap: () => _shareViaSMS(context, shareMessage),
          ),
          InviteFriendsWidget._inviteOption(
            icon: Icons.email_outlined,
            title: 'Email',
            subtitle: 'Share via Email',
            onTap: () => _shareViaEmail(context, shareMessage),
          ),
          InviteFriendsWidget._inviteOption(
            icon: Icons.link,
            title: 'Copy Link',
            subtitle: 'Copy referral message',
            onTap: () => _copyReferralMessage(context, shareMessage),
          ),
        ],
      ),
    );
  }

  Future<void> _shareViaWhatsApp(BuildContext context, String message) async {
    try {
      final url = Uri.parse(
        'https://wa.me/?text=${Uri.encodeComponent(message)}',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        if (context.mounted) Navigator.pop(context);
      } else {
        if (context.mounted) _showShareFeedback(context, 'Could not open WhatsApp');
      }
    } catch (e) {
      if (context.mounted) _showShareFeedback(context, 'Share failed');
    }
  }

  Future<void> _shareViaSMS(BuildContext context, String message) async {
    final encoded = Uri.encodeComponent(message);
    // Try `sms:` first (Android opens default messaging app); fall back to `smsto:`.
    final candidates = <Uri>[
      Uri.parse('sms:?body=$encoded'),
      Uri.parse('smsto:?body=$encoded'),
    ];
    for (final url in candidates) {
      try {
        final launched =
            await launchUrl(url, mode: LaunchMode.externalApplication);
        if (launched) {
          if (context.mounted) Navigator.pop(context);
          return;
        }
      } catch (_) {
        // Try the next candidate.
      }
    }
    if (context.mounted) {
      _showShareFeedback(context, 'No messaging app found');
    }
  }

  Future<void> _shareViaEmail(BuildContext context, String message) async {
    final url = Uri(
      scheme: 'mailto',
      query: _encodeMailtoQuery({
        'subject': 'Try Sampan Laundry',
        'body': message,
      }),
    );
    try {
      final launched =
          await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        if (context.mounted) {
          _showShareFeedback(context, 'No email app found');
        }
        return;
      }
      if (context.mounted) Navigator.pop(context);
    } catch (_) {
      if (context.mounted) {
        _showShareFeedback(context, 'Could not open Email');
      }
    }
  }

  /// Build a `mailto:` query string with proper encoding of spaces (`%20`, not `+`).
  String _encodeMailtoQuery(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  void _copyReferralMessage(BuildContext context, String message) {
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral message copied!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  void _showShareFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
