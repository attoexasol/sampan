import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../modules/schedule/schedule_binding.dart';
import '../modules/schedule/schedule_view.dart';

import '../widgets/header_widget.dart';

class LaundryHowItWorksPage extends StatefulWidget {
  const LaundryHowItWorksPage({Key? key}) : super(key: key);

  @override
  State<LaundryHowItWorksPage> createState() => _LaundryHowItWorksPageState();
}

class _LaundryHowItWorksPageState extends State<LaundryHowItWorksPage> {
  /// SERVICES (toggle)
  bool eliteAdded = false;          // Elite Express Bag – $109 (per bag)
  bool dreamPlanAdded = false;      // Subscription – Dream Big Plan ($69 x 4)
  bool payAsYouGoAdded = false;     // Pay-as-you-go – show a min service charge line

  /// BULKY & ADD-ONS (quantities)
  int countStandard = 0;
  int countFeather = 0;
  int countStdPillow = 0;
  int countFeatherPillow = 0;
  int countRug = 0;
  int countSleepingBag = 0;
  int countCoverall = 0;
  int countJacket = 0;
  int countPetBed = 0;

  int addHangDry = 0;
  int addExtraSoiled = 0;
  int addPetHair = 0;

  final notesController = TextEditingController();
  bool saveNotesForFuture = true;

  /// PRICE TABLE
  static const priceEliteBag = 109.00;
  static const priceDreamPlan = 69.00; // per bag; summary shows x4
  static const payPerPound = 2.25;     // UI label; we’ll use a flat $45 line item
  static const paygMinCharge = 45.00;

  static const priceStandard = 30.00;
  static const priceFeather = 60.00;
  static const priceStdPillow = 15.00;
  static const priceFeatherPillow = 50.00;
  static const priceRug = 50.00;
  static const priceSleepingBag = 50.00;
  static const priceCoverall = 15.00;
  static const priceJacket = 15.00;
  static const pricePetBed = 50.00;

  static const addHangDryPrice = 7.50;
  static const addExtraSoiledPrice = 10.00;
  static const addPetHairPrice = 7.50;

  static const pickupDeliveryFee = 10.99;
  static const gstRate = 0.05;

  // ----------------- CALCULATIONS -----------------
  double _servicesTotal() {
    double s = 0;
    if (eliteAdded) s += priceEliteBag;
    if (dreamPlanAdded) s += priceDreamPlan * 4;
    if (payAsYouGoAdded) s += paygMinCharge; // treat as a line item
    return s;
  }

  double _bulkyTotal() {
    return countStandard * priceStandard +
        countFeather * priceFeather +
        countStdPillow * priceStdPillow +
        countFeatherPillow * priceFeatherPillow +
        countRug * priceRug +
        countSleepingBag * priceSleepingBag +
        countCoverall * priceCoverall +
        countJacket * priceJacket +
        countPetBed * pricePetBed;
  }

  double _addonsTotal() {
    return addHangDry * addHangDryPrice +
        addExtraSoiled * addExtraSoiledPrice +
        addPetHair * addPetHairPrice;
  }

  double _subTotal() => _servicesTotal() + _bulkyTotal() + _addonsTotal();

  double _deliveryFee() => _subTotal() >= 80 ? 0.0 : pickupDeliveryFee;

  double _gst() => _subTotal() * gstRate;

  double _grandTotal() => _subTotal() + _deliveryFee() + _gst();

  bool get _hasAnySelection =>
      eliteAdded ||
          dreamPlanAdded ||
          payAsYouGoAdded ||
          _bulkyTotal() > 0 ||
          _addonsTotal() > 0;

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderWidget(),
              SizedBox(height: AppSizes.lg),

              // Tagline
              Center(
                child: Column(
                  children: [
                    Text(
                      'Laundry & Dry Cleaning',
                      style: GoogleFonts.outfit(
                        fontSize: AppSizes.fontLg,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Eco Conscious and Cleanliness Obsessed',
                      style: GoogleFonts.outfit(
                        fontSize: AppSizes.fontSm,
                        color: Colors.white.withOpacity(0.92),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.lg),

              // How it works
              _sectionCard(
                title: 'Laundry How It Works',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _howItWorksIcon(Icons.done_all, 'Select', 'Pick a service'),
                    _howItWorksIcon(Icons.calendar_today_outlined, 'Schedule', 'Pick a time'),
                    _howItWorksIcon(Icons.eco_outlined, 'Enjoy', 'Pick clean living'),
                  ],
                ),
              ),

              // Premium Bag Service
              _sectionCard(
                title: 'Premium Bag Service (per bag)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _muted(
                      'When life gets messy, our Premium Bag gets it all done in 12 hours — picked up, washed, folded, and back at your door.',
                    ),
                    SizedBox(height: AppSizes.sm),
                    _bullet('Free Pickup & Delivery'),
                    _bullet('Same-day (12h) turnaround'),
                    _bullet('Priority Pickup & Delivery Windows'),
                    SizedBox(height: AppSizes.md),
                    _serviceRow(
                      label: 'Elite Express Bag – \$${priceEliteBag.toStringAsFixed(2)} per bag',
                      isAdded: eliteAdded,
                      onTap: () => setState(() => eliteAdded = !eliteAdded),
                    ),
                  ],
                ),
              ),

              // Subscriptions
              _sectionCard(
                title: 'Subscriptions (per bag)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _muted(
                      'A predictable laundry bill, 24-hour freshness — subscription simplicity meets spotless results.',
                    ),
                    SizedBox(height: AppSizes.sm),
                    _bullet('One bag for everything — linens, delicates, all items.'),
                    _bullet('Free Pickup & Delivery'),
                    _bullet('Unlimited rollover of bag credits'),
                    SizedBox(height: AppSizes.md),
                    _subscriptionCard(
                      title: 'Dream Big Plan – \$${priceDreamPlan.toStringAsFixed(2)} per bag',
                      sub: '4 bags per month',
                      mostPopular: true,
                      isAdded: dreamPlanAdded,
                      onTap: () => setState(() => dreamPlanAdded = !dreamPlanAdded),
                    ),
                  ],
                ),
              ),

              // Pay As You Go
              _sectionCard(
                title: 'Pay As You Go (per pound)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _muted('Try Pay As You Go — \$${payPerPound.toStringAsFixed(2)}/lb, 24–48 hour delivery, and the freedom to upgrade anytime for more perks.'),
                    SizedBox(height: AppSizes.sm),
                    _bullet('\$${pickupDeliveryFee.toStringAsFixed(2)} Pickup & Delivery'),
                    _bullet('24 to 48 h turnaround'),
                    _bullet('20 lb minimum'),
                    SizedBox(height: AppSizes.sm),
                    _serviceRow(
                      label: 'Pay Per Pound – \$${payPerPound.toStringAsFixed(2)}/lb',
                      isAdded: payAsYouGoAdded,
                      onTap: () => setState(() => payAsYouGoAdded = !payAsYouGoAdded),
                    ),
                  ],
                ),
              ),

              // Bulky Items
              _sectionCard(
                title: 'Bulky Items (per piece)',
                child: Column(
                  children: [
                    _muted('Drop the heavy stuff on us — same trusted service, per-item pricing, and no extra hassle.'),
                    SizedBox(height: AppSizes.md),
                    _counterTile('Standard', 'Any size', priceStandard, countStandard, (v) => setState(() => countStandard = v)),
                    _counterTile('Feather/Down', 'Premium processing', priceFeather, countFeather, (v) => setState(() => countFeather = v)),
                    _counterTile('Standard Pillow', 'Regular processing', priceStdPillow, countStdPillow, (v) => setState(() => countStdPillow = v)),
                    _counterTile('Feather/Down Pillow', 'Premium processing', priceFeatherPillow, countFeatherPillow, (v) => setState(() => countFeatherPillow = v)),
                    _counterTile('Rug/Carpet', 'Professional cleaning', priceRug, countRug, (v) => setState(() => countRug = v)),
                    _counterTile('Sleeping Bag', 'Outdoor gear cleaning', priceSleepingBag, countSleepingBag, (v) => setState(() => countSleepingBag = v)),
                    _counterTile('Coverall', 'Professional cleaning', priceCoverall, countCoverall, (v) => setState(() => countCoverall = v)),
                    _counterTile('Jacket', 'Professional cleaning', priceJacket, countJacket, (v) => setState(() => countJacket = v)),
                    _counterTile('Pet Bed', 'Pet bedding cleaning', pricePetBed, countPetBed, (v) => setState(() => countPetBed = v)),
                  ],
                ),
              ),

              // Add-ons
              _sectionCard(
                title: 'Add-ons (per piece)',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _muted('Add the perfect finishing touch.'),
                    SizedBox(height: AppSizes.xs),
                    _muted('Optional services for special requirements.'),
                    SizedBox(height: AppSizes.sm),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: const Text(
                        'Free Add-ons:\nCold water wash • Whites/colors separated • Extra rinse cycle • Fabric softener • Pocket check • Standard heat drying • Next-day turnaround',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    SizedBox(height: AppSizes.md),
                    _counterTile('Hang Dry Items', 'Air-dried items', addHangDryPrice, addHangDry, (v) => setState(() => addHangDry = v)),
                    _counterTile('Extra Soiled Items', 'Pre-treatment for heavy stains', addExtraSoiledPrice, addExtraSoiled, (v) => setState(() => addExtraSoiled = v)),
                    _counterTile('Pet Hair Removal', 'Manual lint brush treatment', addPetHairPrice, addPetHair, (v) => setState(() => addPetHair = v)),
                  ],
                ),
              ),

              // Notes
              _sectionCard(
                title: 'Special Instructions or Notes',
                child: Column(
                  children: [
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add any special instructions for this order...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    SizedBox(height: AppSizes.sm),
                    Row(
                      children: [
                        Checkbox(
                          value: saveNotesForFuture,
                          onChanged: (v) => setState(() => saveNotesForFuture = v ?? true),
                        ),
                        const Text('Save for Future Orders'),
                      ],
                    ),
                  ],
                ),
              ),

              // ----------- ORDER SUMMARY -----------
              _sectionCard(
                title: 'Order Summary',
                child: _hasAnySelection
                    ? _buildOrderSummaryFilled()
                    : _buildOrderSummaryEmpty(),
              ),
              SizedBox(height: AppSizes.lg),

              // Footer buttons
              OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('← Back to Other Services'),
              ),
              SizedBox(height: AppSizes.sm),

              ElevatedButton(
                onPressed: () {
                  final details = _composeSummaryPayload();
                  Get.to(
                        () => const ScheduleView(),
                    binding: ScheduleBinding(),
                    arguments: {'orderSummary': details},
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Continue to Schedule →',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------- WIDGET HELPERS -----------------
  Widget _buildOrderSummaryEmpty() {
    return Padding(
      padding: EdgeInsets.only(top: AppSizes.xs),
      child: Text(
        'Select your services above to see order details',
        style: TextStyle(color: AppColors.mutedForeground, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildOrderSummaryFilled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Services
        if (eliteAdded) _serviceChip('ELITE EXPRESS BAG', 'Premium Service (per bag)', priceEliteBag),
        if (dreamPlanAdded) _serviceChip('SUBSCRIPTION PLAN', 'Weekly Plan (\$69 × 4)', priceDreamPlan * 4),
        if (payAsYouGoAdded) _serviceChip('PAY-AS-YOU-GO', 'Service charge (20 lb minimum)', paygMinCharge),

        // Bulky header
        if (_bulkyTotal() > 0) ...[
          SizedBox(height: AppSizes.sm),
          _sectionHeader('BULKY ITEMS', 'Pickup & Delivery: \$${pickupDeliveryFee.toStringAsFixed(2)}'),
          SizedBox(height: AppSizes.xs),
          if (countStandard > 0) _lineRow('Standard ($countStandard)', countStandard * priceStandard),
          if (countFeather > 0) _lineRow('Down Comforter ($countFeather)', countFeather * priceFeather),
          if (countStdPillow > 0) _lineRow('Pillow ($countStdPillow)', countStdPillow * priceStdPillow),
          if (countFeatherPillow > 0) _lineRow('Feather/Down Pillow ($countFeatherPillow)', countFeatherPillow * priceFeatherPillow),
          if (countRug > 0) _lineRow('Rug/Carpet ($countRug)', countRug * priceRug),
          if (countSleepingBag > 0) _lineRow('Sleeping Bag ($countSleepingBag)', countSleepingBag * priceSleepingBag),
          if (countCoverall > 0) _lineRow('Coverall ($countCoverall)', countCoverall * priceCoverall),
          if (countJacket > 0) _lineRow('Jacket ($countJacket)', countJacket * priceJacket),
          if (countPetBed > 0) _lineRow('Pet Bed ($countPetBed)', countPetBed * pricePetBed),
        ],

        // Add-ons
        if (_addonsTotal() > 0) ...[
          const Divider(height: 20),
          _summaryHeader('ADD-ONS', ''),
          if (addHangDry > 0) _lineRow('Hang Dry Items ($addHangDry)', addHangDry * addHangDryPrice),
          if (addExtraSoiled > 0) _lineRow('Extra Soiled Items ($addExtraSoiled)', addExtraSoiled * addExtraSoiledPrice),
          if (addPetHair > 0) _lineRow('Pet Hair Removal ($addPetHair)', addPetHair * addPetHairPrice),
        ],

        const Divider(height: 24),
        _totalsRow('Subtotal:', _subTotal()),
        _totalsRow('Pickup & Delivery:', _deliveryFee(), freeIfZero: true),
        _totalsRow('GST (5%):', _gst()),
        const Divider(height: 24),
        _totalsRow('Total:', _grandTotal(), isEmphasis: true),
      ],
    );
  }

  Widget _serviceChip(String title, String subtitle, double amount) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.sm),
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(subtitle, style: TextStyle(color: AppColors.mutedForeground, fontSize: AppSizes.fontSm)),
              ],
            ),
          ),
          Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _lineRow(String left, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(left, overflow: TextOverflow.ellipsis)),
          Text('\$${amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _totalsRow(String label, double amount, {bool isEmphasis = false, bool freeIfZero = false}) {
    final style = TextStyle(
      fontWeight: isEmphasis ? FontWeight.w800 : FontWeight.w600,
      color: isEmphasis ? AppColors.primary : AppColors.foreground,
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(
            (freeIfZero && amount == 0) ? 'FREE' : '\$${amount.toStringAsFixed(2)}',
            style: style,
          ),
        ],
      ),
    );
  }

  // -------- Small UI helpers ----------
  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSizes.md),
      padding: EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: AppSizes.fontXl, fontWeight: FontWeight.w800)),
          SizedBox(height: AppSizes.md),
          child,
        ],
      ),
    );
  }

  Widget _howItWorksIcon(IconData icon, String title, String caption) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        SizedBox(height: AppSizes.xs),
        Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: AppSizes.fontMd)),
        SizedBox(height: 2),
        Text(caption, style: TextStyle(fontSize: AppSizes.fontSm, color: AppColors.mutedForeground)),
      ],
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _muted(String text) => Text(text, style: TextStyle(color: AppColors.mutedForeground));

  Widget _serviceRow({required String label, required bool isAdded, required VoidCallback onTap}) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w600)),
          ),
          _pillButton(isAdded ? 'Added' : 'Add', active: isAdded, onTap: onTap),
        ],
      ),
    );
  }

  Widget _subscriptionCard({
    required String title,
    required String sub,
    required bool mostPopular,
    required bool isAdded,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        color: isAdded ? Colors.teal.shade50 : Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mostPopular)
            Container(
              margin: EdgeInsets.only(bottom: AppSizes.xs),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('MOST POPULAR', style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: AppSizes.fontMd, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text(sub, style: TextStyle(color: AppColors.mutedForeground)),
                  ],
                ),
              ),
              _pillButton(isAdded ? 'Added' : 'Add', active: isAdded, onTap: onTap),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillButton(String text, {bool active = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          text,
          style: TextStyle(color: active ? Colors.white : Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _counterTile(String title, String subtitle, double priceEach, int qty, ValueChanged<int> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: AppSizes.fontMd)),
                Text(subtitle, style: TextStyle(color: AppColors.mutedForeground)),
                Text('\$${priceEach.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          _qtyButton(Icons.remove_circle_outline, () => onChanged((qty - 1).clamp(0, 99))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$qty', style: const TextStyle(fontSize: 16)),
          ),
          _qtyButton(Icons.add_circle_outline, () => onChanged(qty + 1)),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Icon(icon, size: 26, color: AppColors.mutedForeground));
  }

  Widget _summaryHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(color: AppColors.mutedForeground)),
        SizedBox(height: AppSizes.xs),
      ],
    );
  }

  Widget _sectionHeader(String title, String subtitle) => Container(
    padding: EdgeInsets.all(AppSizes.sm),
    decoration: BoxDecoration(
      color: AppColors.muted.withOpacity(.15),
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        Text(subtitle, style: TextStyle(color: AppColors.mutedForeground, fontSize: AppSizes.fontSm)),
      ],
    ),
  );

  // ----------------- Payload to Schedule -----------------
  Map<String, dynamic> _composeSummaryPayload() {
    final services = <Map<String, dynamic>>[];
    if (eliteAdded) {
      services.add({
        'key': 'elite',
        'title': 'ELITE EXPRESS BAG',
        'subtitle': 'Premium Service (per bag)',
        'amount': priceEliteBag,
      });
    }
    if (dreamPlanAdded) {
      services.add({
        'key': 'sub',
        'title': 'SUBSCRIPTION PLAN',
        'subtitle': 'Weekly Plan (\$69 × 4)',
        'amount': priceDreamPlan * 4,
      });
    }
    if (payAsYouGoAdded) {
      services.add({
        'key': 'payg',
        'title': 'PAY-AS-YOU-GO',
        'subtitle': 'Service charge (20 lb minimum)',
        'amount': paygMinCharge,
      });
    }

    final bulky = <Map<String, dynamic>>[];
    void addBulky(String label, int qty, double unit) {
      if (qty > 0) {
        bulky.add({'label': label, 'qty': qty, 'unitPrice': unit, 'amount': qty * unit});
      }
    }

    addBulky('Standard', countStandard, priceStandard);
    addBulky('Down Comforter', countFeather, priceFeather);
    addBulky('Pillow', countStdPillow, priceStdPillow);
    addBulky('Feather/Down Pillow', countFeatherPillow, priceFeatherPillow);
    addBulky('Rug/Carpet', countRug, priceRug);
    addBulky('Sleeping Bag', countSleepingBag, priceSleepingBag);
    addBulky('Coverall', countCoverall, priceCoverall);
    addBulky('Jacket', countJacket, priceJacket);
    addBulky('Pet Bed', countPetBed, pricePetBed);

    final addons = <Map<String, dynamic>>[];
    if (addHangDry > 0) addons.add({'label': 'Hang Dry Items', 'qty': addHangDry, 'unitPrice': addHangDryPrice, 'amount': addHangDry * addHangDryPrice});
    if (addExtraSoiled > 0) addons.add({'label': 'Extra Soiled Items', 'qty': addExtraSoiled, 'unitPrice': addExtraSoiledPrice, 'amount': addExtraSoiled * addExtraSoiledPrice});
    if (addPetHair > 0) addons.add({'label': 'Pet Hair Removal', 'qty': addPetHair, 'unitPrice': addPetHairPrice, 'amount': addPetHair * addPetHairPrice});

    return {
      'services': services,
      'bulky': bulky,
      'addons': addons,
      'totals': {
        'servicesTotal': _servicesTotal(),
        'bulkyTotal': _bulkyTotal(),
        'addonsTotal': _addonsTotal(),
        'subTotal': _subTotal(),
        'deliveryFee': _deliveryFee(),
        'tax': _gst(),
        'grandTotal': _grandTotal(),
        'gstRate': gstRate,
      },
      'notes': notesController.text.trim(),
      'saveNotesForFuture': saveNotesForFuture,
    };
  }
}






