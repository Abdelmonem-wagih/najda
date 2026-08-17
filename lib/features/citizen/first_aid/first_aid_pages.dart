import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/design.dart';

// ─── Real first aid image dataset (Wikimedia Commons / public domain) ─────────
class FirstAidItem {
  final String id;
  final String title;
  final String subtitle;
  final String heroImage; // real illustrative image URL
  final List<FirstAidStep> steps;
  final String urgencyLevel; // critical | high | medium

  const FirstAidItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.heroImage,
    required this.steps,
    required this.urgencyLevel,
  });
}

class FirstAidStep {
  final int number;
  final String instruction;
  final String? imageUrl; // per-step illustrative image

  const FirstAidStep({
    required this.number,
    required this.instruction,
    this.imageUrl,
  });
}

// ─── Dataset with real illustrative images ────────────────────────────────────
final kFirstAidData = <FirstAidItem>[
  FirstAidItem(
    id: 'cpr',
    title: 'الإنعاش القلبي الرئوي',
    subtitle: 'CPR — السكتة القلبية',
    urgencyLevel: 'critical',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/CPR_training-01.jpg/800px-CPR_training-01.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction: 'تأكد من أمان المكان ثم استجب للمريض بالنداء والنقر على كتفه.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/CPR_training-01.jpg/400px-CPR_training-01.jpg',
      ),
      FirstAidStep(
        number: 2,
        instruction: 'اتصل بالإسعاف (123) فوراً أو اطلب من أحد الاتصال بهم.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 3,
        instruction: 'ضع كعب يدك على منتصف الصدر بين الحلمتين، وضع اليد الأخرى فوقها وشبّك الأصابع.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e4/CPR_training-05.jpg/400px-CPR_training-05.jpg',
      ),
      FirstAidStep(
        number: 4,
        instruction: 'اضغط بقوة لأسفل 5-6 سم بمعدل 100-120 ضغطة في الدقيقة. اسمح للصدر بالارتداد تماماً.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/CPR_training-06.jpg/400px-CPR_training-06.jpg',
      ),
      FirstAidStep(
        number: 5,
        instruction: 'بعد كل 30 ضغطة أعطِ نفَسين اصطناعيين: أغلق الأنف ونفخ في الفم حتى يرتفع الصدر.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/CPR_training-09.jpg/400px-CPR_training-09.jpg',
      ),
      FirstAidStep(
        number: 6,
        instruction: 'استمر في دورات 30 ضغطة + 2 نفس حتى وصول الإسعاف أو استعادة التنفس.',
        imageUrl: null,
      ),
    ],
  ),
  FirstAidItem(
    id: 'choking',
    title: 'الاختناق',
    subtitle: 'انسداد مجرى الهواء',
    urgencyLevel: 'critical',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Heimlich_Maneuver.jpg/800px-Heimlich_Maneuver.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction: 'اسأل: "هل تختنق؟" إن لم يستطع الإجابة أو السعال — تصرّف فوراً.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 2,
        instruction: 'انحنِ المريض للأمام واضرب بين لوحَي كتفيه 5 مرات بقوة بكعب يدك.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Back_blow_adult.jpg/400px-Back_blow_adult.jpg',
      ),
      FirstAidStep(
        number: 3,
        instruction: 'إن لم تنجح: قف خلفه، ضع قبضتك أسفل القفص الصدري فوق السرة مباشرة.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Heimlich_Maneuver.jpg/400px-Heimlich_Maneuver.jpg',
      ),
      FirstAidStep(
        number: 4,
        instruction: 'اضغط بقوة للداخل وللأعلى 5 مرات بحركة سريعة (مناورة هيمليك).',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction: 'كرّر 5 ضربات ظهر + 5 ضغطات بطن بالتناوب حتى يخرج الجسم الغريب.',
        imageUrl: null,
      ),
    ],
  ),
  FirstAidItem(
    id: 'bleeding',
    title: 'النزيف الشديد',
    subtitle: 'إيقاف النزيف الخارجي',
    urgencyLevel: 'critical',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Direct_pressure_on_wound.jpg/800px-Direct_pressure_on_wound.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction: 'ارتدِ قفازات طبية إن توفرت. لا تزل أي جسم غريب مغروز في الجرح.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 2,
        instruction: 'اضغط على الجرح مباشرةً بقماش نظيف أو ضمادة معقمة بقوة ثابتة.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Direct_pressure_on_wound.jpg/400px-Direct_pressure_on_wound.jpg',
      ),
      FirstAidStep(
        number: 3,
        instruction: 'حافظ على الضغط 10-15 دقيقة متواصلة دون رفع الضمادة.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 4,
        instruction: 'إن نفذ الدم أضف ضمادة أخرى فوق الأولى دون إزالتها.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction: 'ارفع الطرف المصاب فوق مستوى القلب إن أمكن لإبطاء النزيف.',
        imageUrl: null,
      ),
    ],
  ),
  FirstAidItem(
    id: 'burns',
    title: 'الحروق',
    subtitle: 'حروق حرارية وكيميائية',
    urgencyLevel: 'high',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Running_water_on_burn.jpg/800px-Running_water_on_burn.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction: 'أبعد المصاب عن مصدر الحرارة فوراً. احمِ نفسك أولاً.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 2,
        instruction: 'برّد الحرق بماء بارد جاري (ليس مثلجاً) لمدة 10-20 دقيقة.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Running_water_on_burn.jpg/400px-Running_water_on_burn.jpg',
      ),
      FirstAidStep(
        number: 3,
        instruction: 'لا تزل الملابس الملتصقة بالجلد. لا تفقع الفقاعات.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 4,
        instruction: 'لا تضع زبدة، معجون أسنان، أو أي مواد منزلية على الحرق.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction: 'غطِّ الحرق بضمادة معقمة أو قماش نظيف جاف واتصل بالإسعاف.',
        imageUrl: null,
      ),
    ],
  ),
  FirstAidItem(
    id: 'fracture',
    title: 'الكسور',
    subtitle: 'تثبيت الكسور',
    urgencyLevel: 'high',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Splint.jpg/800px-Splint.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction: 'لا تحرّك الطرف المكسور ولا تحاول إعادة العظم لمكانه.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 2,
        instruction: 'ثبّت الطرف كما هو باستخدام جبيرة (ألواح، مجلات) مع ضمادة ناعمة بينها وبين الجلد.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Splint.jpg/400px-Splint.jpg',
      ),
      FirstAidStep(
        number: 3,
        instruction: 'تأكد أن الجبيرة تثبّت المفصلين فوق وأسفل الكسر.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 4,
        instruction: 'راقب اللون والدفء والإحساس في الطرف. الابيضاض أو التنميل خطر.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction: 'اتصل بالإسعاف خاصة في كسور الورك والعمود الفقري والرقبة والحوض.',
        imageUrl: null,
      ),
    ],
  ),
  FirstAidItem(
    id: 'stroke',
    title: 'السكتة الدماغية',
    subtitle: 'التعرف والاستجابة',
    urgencyLevel: 'critical',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/FAST_stroke_warning_signs.png/800px-FAST_stroke_warning_signs.png',
    steps: [
      FirstAidStep(
        number: 1,
        instruction: 'اختبر FAST: Face (وجه)، Arms (أذرع)، Speech (كلام)، Time (وقت).',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/FAST_stroke_warning_signs.png/400px-FAST_stroke_warning_signs.png',
      ),
      FirstAidStep(
        number: 2,
        instruction: 'اطلب من المريض الابتسام — هل أحد جانبَي الفم مائل؟',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 3,
        instruction: 'اطلب رفع الذراعين — هل ذراع تنزل وحدها؟',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 4,
        instruction: 'اطلب قول جملة — هل الكلام مبهم أو صعب؟',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction: 'إن نجحت إحدى الاختبارات — اتصل بالإسعاف فوراً. كل دقيقة حرجة!',
        imageUrl: null,
      ),
    ],
  ),
];

// ═══════════════════════════════════════════════════════════════════
// LIST PAGE
// ═══════════════════════════════════════════════════════════════════
class FirstAidListPage extends StatefulWidget {
  const FirstAidListPage({super.key});

  @override
  State<FirstAidListPage> createState() => _FirstAidListPageState();
}

class _FirstAidListPageState extends State<FirstAidListPage> {
  String _query = '';

  List<FirstAidItem> get _filtered => kFirstAidData
      .where((e) => e.title.contains(_query) || e.subtitle.contains(_query))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NC.base,
      appBar: AppBar(
        backgroundColor: NC.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: NC.textHigh, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('الإسعافات الأولية', style: NC.display(16)),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              style: NC.inputText(),
              decoration: InputDecoration(
                hintText: 'ابحث عن حالة...',
                prefixIcon:
                    const Icon(Icons.search, color: NC.primary, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: NC.textLow),
                        onPressed: () =>
                            setState(() => _query = ''),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? NajdaEmpty(
                    icon: Icons.search_off_outlined,
                    title: 'لا نتائج',
                    subtitle: 'جرّب كلمة بحث مختلفة')
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) =>
                        _FirstAidCard(item: _filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FirstAidCard extends StatelessWidget {
  final FirstAidItem item;
  const _FirstAidCard({required this.item});

  Color get _urgencyColor {
    switch (item.urgencyLevel) {
      case 'critical': return NC.critical;
      case 'high': return NC.warning;
      default: return NC.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FirstAidDetailPage(item: item)),
      ),
      child: GlassCard(
        padding: EdgeInsets.zero,
        radius: 18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: CachedNetworkImage(
                imageUrl: item.heroImage,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 140,
                  color: NC.card,
                  child: const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(NC.primary),
                        strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 140,
                  color: NC.card,
                  child: Icon(Icons.medical_services_outlined,
                      color: NC.textLow, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: NC.label(15)),
                        const SizedBox(height: 3),
                        Text(item.subtitle, style: NC.body(12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _urgencyColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: _urgencyColor, size: 7),
                        const SizedBox(width: 5),
                        Text(
                          item.urgencyLevel == 'critical'
                              ? 'حرج'
                              : item.urgencyLevel == 'high'
                                  ? 'عاجل'
                                  : 'عادي',
                          style: NC.label(10, color: _urgencyColor),
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
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// DETAIL PAGE — step by step with images
// ═══════════════════════════════════════════════════════════════════
class FirstAidDetailPage extends StatelessWidget {
  final FirstAidItem item;
  const FirstAidDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NC.base,
      body: CustomScrollView(
        slivers: [
          // Hero
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: NC.surface,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: NC.base.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_rounded,
                    color: NC.textHigh, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(item.title,
                  style: NC.label(14)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.heroImage,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) =>
                        Container(color: NC.surface),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          NC.base.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(item.subtitle,
                    style: NC.body(14, color: NC.textMid)),
                const SizedBox(height: 6),

                // Urgency
                Row(children: [
                  const Icon(Icons.warning_amber_outlined,
                      color: NC.warning, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    item.urgencyLevel == 'critical'
                        ? 'حالة حرجة — اتصل بالإسعاف فوراً'
                        : 'اتصل بالإسعاف إذا ازدادت الحالة سوءاً',
                    style: NC.body(12, color: NC.warning),
                  ),
                ]),
                const SizedBox(height: 24),

                Text('الخطوات', style: NC.display(16)),
                const SizedBox(height: 14),

                ...item.steps.map((step) => _StepCard(step: step)),
                const SizedBox(height: 20),

                // Disclaimer
                GlassCard(
                  borderColor: NC.primary.withOpacity(0.3),
                  child: Row(children: [
                    const Icon(Icons.info_outline,
                        color: NC.primary, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'هذه إرشادات أولية. اتصل بالإسعاف 123 في الحالات الطارئة.',
                        style: NC.body(12),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final FirstAidStep step;
  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step image (if available)
            if (step.imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: CachedNetworkImage(
                  imageUrl: step.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 160,
                    color: NC.overlay,
                    child: const Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(NC.primary),
                          strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      gradient: NC.primaryGrad,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('${step.number}',
                          style: NC.label(13, color: NC.base,
                              weight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(step.instruction,
                        style: NC.body(14,
                            color: NC.textHigh),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
