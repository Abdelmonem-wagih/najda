import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/design.dart';
import '../../../core/shared/widgets/app_widgets.dart';

class FirstAidItem {
  final String id;
  final String title;
  final String subtitle;
  final String heroImage;
  final List<FirstAidStep> steps;
  final String urgencyLevel;

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
  final String? imageUrl;

  const FirstAidStep({
    required this.number,
    required this.instruction,
    this.imageUrl,
  });
}

final kFirstAidData = <FirstAidItem>[
  // ── 1. CPR ─────────────────────────────────────────────────────────
  FirstAidItem(
    id: 'cpr',
    title: 'الإنعاش القلبي الرئوي',
    subtitle: 'CPR — توقف القلب',
    urgencyLevel: 'critical',
    heroImage:
        'https://commons.wikimedia.org/wiki/Special:Redirect/file/CPR_training-01.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction:
            'تحقق من استجابة المريض: انقر على كتفه وانادِه بصوت عالٍ "هل أنت بخير؟". إن لم يستجب — اتصل بالإسعاف 123 فوراً.',
        imageUrl:
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/CPR_training-01.jpg',
      ),
      FirstAidStep(
        number: 2,
        instruction:
            'أضجع المريض على ظهره على سطح صلب. ضع كعب يدك على منتصف الصدر تماماً (بين الحلمتين).',
        imageUrl:
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/CPR_training-05.jpg',
      ),
      FirstAidStep(
        number: 3,
        instruction:
            'ضع يدك الثانية فوق الأولى وشبّك الأصابع. أبقِ ذراعيك مستقيمتين وكتفيك فوق يديك مباشرة.',
        imageUrl:
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/CPR_training-06.jpg',
      ),
      FirstAidStep(
        number: 4,
        instruction:
            'اضغط للأسفل بقوة 5-6 سم بمعدل 100-120 ضغطة في الدقيقة (بنفس إيقاع أغنية "Stayin Alive"). اسمح للصدر بالارتداد تماماً بعد كل ضغطة.',
        imageUrl:
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/CPR_training-06.jpg',
      ),
      FirstAidStep(
        number: 5,
        instruction:
            'بعد 30 ضغطة، أعطِ نفَسين اصطناعيين: أمسك الأنف، ضع فمك على فمه، انفخ لمدة ثانية كاملة حتى ترى الصدر يرتفع.',
        imageUrl:
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/CPR_training-09.jpg',
      ),
      FirstAidStep(
        number: 6,
        instruction:
            'كرر دورات 30 ضغطة + 2 نفس بلا توقف حتى وصول الإسعاف أو استعادة المريض للتنفس أو ظهور علامات الحياة.',
        imageUrl: null,
      ),
    ],
  ),

  // ── 2. اختناق / Heimlich ────────────────────────────────────────────
  FirstAidItem(
    id: 'choking',
    title: 'الاختناق',
    subtitle: 'انسداد مجرى الهواء',
    urgencyLevel: 'critical',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Heimlich_Maneuver.jpg/640px-Heimlich_Maneuver.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction:
            'اسأل: "هل تختنق؟". إن لم يستطع الكلام أو السعال أو أشار بيده للحلق — تصرّف فوراً. لا تنتظر.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 2,
        instruction:
            'انحنِ المصاب للأمام (رأسه لأسفل أكثر من صدره). اضرب 5 ضربات قوية بكعب يدك بين لوحَي الكتف باتجاه الأسفل.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Back_blow_adult.jpg/480px-Back_blow_adult.jpg',
      ),
      FirstAidStep(
        number: 3,
        instruction:
            'إن لم تنجح الضربات: قف خلفه، ضع قبضة يدك (الجانب الإبهامي) أسفل عظمة القفص الصدري وفوق السرة مباشرة.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Heimlich_Maneuver.jpg/480px-Heimlich_Maneuver.jpg',
      ),
      FirstAidStep(
        number: 4,
        instruction:
            'اقبض اليد الأخرى على قبضتك. اضغط بسرعة وقوة للداخل وللأعلى 5 مرات (مناورة هيمليك). كل ضغطة يجب أن تكون مستقلة وقوية.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Heimlich_Maneuver.jpg/480px-Heimlich_Maneuver.jpg',
      ),
      FirstAidStep(
        number: 5,
        instruction:
            'كرّر: 5 ضربات ظهر + 5 ضغطات بطن بالتناوب حتى يخرج الجسم الغريب أو يتنفس المصاب. إن فقد الوعي ابدأ CPR.',
        imageUrl: null,
      ),
    ],
  ),

  // ── 3. نزيف شديد ────────────────────────────────────────────────────
  FirstAidItem(
    id: 'bleeding',
    title: 'النزيف الشديد',
    subtitle: 'إيقاف النزيف الخارجي',
    urgencyLevel: 'critical',
    heroImage:
        'https://commons.wikimedia.org/wiki/Special:Redirect/file/Direct_pressure_on_wound.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction:
            'ارتدِ قفازات طبية إن توفرت لحماية نفسك. اطلب المصاب أن يضغط بيده إن كان واعياً. لا تزل أي جسم غريب مغروز في الجرح.',
        imageUrl: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/Direct_pressure_on_wound.jpg',
      ),
      FirstAidStep(
        number: 2,
        instruction:
            'اضغط مباشرة على الجرح بقطعة قماش نظيفة أو ضمادة معقمة. الضغط يجب أن يكون قوياً وثابتاً دون انقطاع.',
        imageUrl:
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/Tourniquet_TCCC.jp',
      ),
      FirstAidStep(
        number: 3,
        instruction:
            'استمر بالضغط 10-15 دقيقة متواصلة بدون رفع الضمادة للتحقق. إن نفذ الدم خلالها — أضف ضمادة أخرى فوقها فقط.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 4,
        instruction:
            'ارفع الطرف المصاب فوق مستوى القلب إن أمكن (ما لم يكن مكسوراً). هذا يُبطئ تدفق الدم.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction:
            'إن كان النزيف في ذراع أو ساق وشديداً جداً ولا يتوقف: استخدم رباطاً ضاغطاً (tourniquet) أعلى الجرح بـ 5-7 سم. دوّن وقت التطبيق.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Tourniquet_TCCC.jpg/480px-Tourniquet_TCCC.jpg',
      ),
    ],
  ),

  // ── 4. حروق ─────────────────────────────────────────────────────────
  FirstAidItem(
    id: 'burns',
    title: 'الحروق',
    subtitle: 'حروق حرارية وكيميائية',
    urgencyLevel: 'high',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Running_water_on_burn.jpg/640px-Running_water_on_burn.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction:
            'أبعد المصاب عن مصدر الحرارة فوراً. إن كانت ملابسه تشتعل: "أوقعه — دحرجه — غطّه" (Stop, Drop, Roll).',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 2,
        instruction:
            'برّد الحرق فوراً بماء بارد جاري لمدة 20 دقيقة كاملة. لا تستخدم الثلج أو الماء المثلج لأنه يُفاقم الضرر.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/Running_water_on_burn.jpg/480px-Running_water_on_burn.jpg',
      ),
      FirstAidStep(
        number: 3,
        instruction:
            'لا تزل الملابس الملتصقة بالجلد. أزل المجوهرات والأحذية بلطف قبل التورم إن لم تكن ملتصقة.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 4,
        instruction:
            'ممنوع تماماً: الزبدة، معجون الأسنان، الزيت، القشدة، أي مواد منزلية — كلها تزيد الضرر وتخاطر بالعدوى.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction:
            'غطِّ الحرق بضمادة معقمة لاصقة أو قماش نظيف رطب. اتصل بالإسعاف إن كان الحرق: واسعاً، في الوجه/اليدين/المفاصل، أو عند طفل.',
        imageUrl: null,
      ),
    ],
  ),

  // ── 5. كسور ─────────────────────────────────────────────────────────
  FirstAidItem(
    id: 'fracture',
    title: 'الكسور',
    subtitle: 'تثبيت العظام المكسورة',
    urgencyLevel: 'high',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Splint.jpg/640px-Splint.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction:
            'لا تحرّك الطرف المكسور ولا تحاول تقويمه. إن كان الكسر مفتوحاً (عظم بارز) غطِّه بقماش نظيف ولا تضغط.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 2,
        instruction:
            'جهّز جبيرة: ألواح خشبية، مجلات، عصا — أي شيء صلب أطول من الطرف. ضع قماشاً ناعماً بين الجبيرة والجلد.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Splint.jpg/480px-Splint.jpg',
      ),
      FirstAidStep(
        number: 3,
        instruction:
            'ثبّت الجبيرة بربطات تشمل المفصلين فوق وأسفل الكسر. الربطات لا تكون ضيقة جداً — يجب أن تستطيع إدخال إصبع تحتها.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 4,
        instruction:
            'راقب كل 10 دقائق: الألوان (شحوب أو ازرقاق)، الدفء، الإحساس، حركة الأصابع. أي تغيير — أرخِ الربطات فوراً.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction:
            'اتصل بالإسعاف خاصة في: كسور الورك، العمود الفقري، الرقبة، الحوض — هذه لا تُحرَّك أبداً بدون إشراف طبي.',
        imageUrl: null,
      ),
    ],
  ),

  // ── 6. سكتة دماغية ─────────────────────────────────────────────────
  FirstAidItem(
    id: 'stroke',
    title: 'السكتة الدماغية',
    subtitle: 'اختبار FAST السريع',
    urgencyLevel: 'critical',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/FAST_stroke_warning_signs.png/640px-FAST_stroke_warning_signs.png',
    steps: [
      FirstAidStep(
        number: 1,
        instruction:
            'F — Face (الوجه): اطلب منه الابتسام. هل أحد جانبَي الفم مائل للأسفل أو متدلٍّ؟ هذا تحذير.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/2/28/FAST_stroke_warning_signs.png/480px-FAST_stroke_warning_signs.png',
      ),
      FirstAidStep(
        number: 2,
        instruction:
            'A — Arms (الذراعان): اطلب رفع كلتا الذراعين للأمام لمدة 10 ثوانٍ. هل إحداهما تنزل وحدها؟',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 3,
        instruction:
            'S — Speech (الكلام): اطلب قول جملة بسيطة كـ"السماء زرقاء". هل الكلام مبهم أو متقطع أو غريب؟',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 4,
        instruction:
            'T — Time (الوقت): إن نجح أي من الاختبارات السابقة — اتصل بالإسعاف 123 فوراً. دوّن وقت ظهور الأعراض. لا تنتظر!',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction:
            'أضجعه بشكل مريح. لا تعطه طعاماً أو ماءً. لا تتركه وحده. إن فقد الوعي وتنفسه طبيعي: ضعه في وضع الإفاقة (على جانبه).',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Recovery_position.jpg/480px-Recovery_position.jpg',
      ),
    ],
  ),

  // ── 7. غرق / استنقاذ ──────────────────────────────────────────────
  FirstAidItem(
    id: 'drowning',
    title: 'الغرق',
    subtitle: 'إنقاذ الغريق والإسعاف',
    urgencyLevel: 'critical',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/AED_training_05.jpg/640px-AED_training_05.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction:
            'لا تقفز للنجدة إلا إن كنت مدرّباً على الإنقاذ المائي. ابحث عن حبل، عصا، أو أي شيء تمده له من الشاطئ.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 2,
        instruction:
            'بمجرد إخراجه: تحقق من استجابته والتنفس. اتصل بالإسعاف 123 فوراً حتى لو بدا بخير — الغرق الثانوي خطير.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 3,
        instruction:
            'إن لم يتنفس: ابدأ CPR فوراً (30 ضغطة + 2 نفس). للغريق يُبدأ بـ 5 أنفاس اصطناعية أولاً قبل الضغطات.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5c/CPR_training-09.jpg/480px-CPR_training-09.jpg',
      ),
      FirstAidStep(
        number: 4,
        instruction:
            'لا تحاول إخراج الماء من رئتيه بالضغط على بطنه — هذا خطأ شائع وخطير. ركّز على التنفس الصناعي.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction:
            'إن تنفس وواعٍ: ضعه في وضع الإفاقة (على جانبه). افرد بطانية لتدفئته — الغرق يسبب انخفاض حرارة خطير.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Recovery_position.jpg/480px-Recovery_position.jpg',
      ),
    ],
  ),

  // ── 8. تسمم ─────────────────────────────────────────────────────────
  FirstAidItem(
    id: 'poisoning',
    title: 'التسمم',
    subtitle: 'دواء أو مواد كيميائية',
    urgencyLevel: 'high',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Activated_Charcoal_Antidote.jpg/640px-Activated_Charcoal_Antidote.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction:
            'حدّد المادة المسببة إن أمكن. احتفظ بالعبوة أو عبّئ اسمها — ستحتاجها للطاقم الطبي. اتصل بـ 123 أو مركز السموم.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 2,
        instruction:
            'لا تحاول إحداث القيء إلا بتعليمات طبية صريحة — بعض المواد (الأحماض، المنظفات) تسبب حروقاً مزدوجة عند القيء.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 3,
        instruction:
            'إن كان التسمم على الجلد: انزع الملابس الملوثة بحذر واغسل المنطقة بماء وفير لمدة 15-20 دقيقة.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 4,
        instruction:
            'إن دخل السم في العين: اغسلها بماء دافئ نظيف لمدة 15 دقيقة على الأقل. أبقِ العين مفتوحة أثناء الغسيل.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction:
            'إن كان المريض واعياً: أبقِه في وضع مريح. إن فقد الوعي ويتنفس: ضعه في وضع الإفاقة. إن توقف التنفس: ابدأ CPR.',
        imageUrl: null,
      ),
    ],
  ),

  // ── 9. نوبة صرع ─────────────────────────────────────────────────────
  FirstAidItem(
    id: 'seizure',
    title: 'نوبة الصرع',
    subtitle: 'التعامل مع نوبة تشنج',
    urgencyLevel: 'high',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Recovery_position.jpg/640px-Recovery_position.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction:
            'لا تتذعر. أبعد الأثاث والأشياء الصلبة عنه. ضع شيئاً ناعماً (معطف، وسادة) تحت رأسه لحمايته.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 2,
        instruction:
            'لا تمسكه ولا تقيّد حركته. لا تضع أي شيء في فمه — هذا خرافة خطيرة. المصاب بالصرع لا يبتلع لسانه.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 3,
        instruction:
            'إذا كان على جانبه لا تقلبه على ظهره. إذا كان على ظهره وبدأ يتقيأ — أدِر رأسه بلطف للجانب فقط.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 4,
        instruction:
            'راقب الوقت. معظم النوبات تنتهي في 1-3 دقائق. اتصل بـ 123 إن: استمرت أكثر من 5 دقائق، أو كانت الأولى، أو لم يستعد وعيه.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction:
            'بعد النوبة: ضعه في وضع الإفاقة (على جانبه). سيكون مرتبكاً وتعباناً — هذا طبيعي. أبقَ بجانبه وطمئنه بهدوء.',
        imageUrl:
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Recovery_position.jpg/480px-Recovery_position.jpg',
      ),
    ],
  ),

  // ── 10. صدمة تحسسية شديدة ───────────────────────────────────────────
  FirstAidItem(
    id: 'anaphylaxis',
    title: 'الحساسية الحادة',
    subtitle: 'صدمة تحسسية — أنافيلاكسيس',
    urgencyLevel: 'critical',
    heroImage:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/AED_training_05.jpg/640px-AED_training_05.jpg',
    steps: [
      FirstAidStep(
        number: 1,
        instruction:
            'علامات التحذير: انتفاخ الوجه/الشفتين/اللسان، صفير في التنفس، طفح جلدي مفاجئ، انخفاض ضغط الدم، دوار شديد. اتصل بـ 123 فوراً.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 2,
        instruction:
            'إن كان معه قلم إبينفرين (EpiPen): استخدمه فوراً في الجانب الخارجي من الفخذ. يمكن استخدامه فوق الملابس.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 3,
        instruction:
            'أضجعه على ظهره مع رفع ساقيه (إلا إن كان يعاني من ضيق تنفس — أجلسه حينئذٍ). لا تتركه يقف أو يمشي.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 4,
        instruction:
            'ابعده عن مسبب الحساسية إن عرفته. لا تعطه طعاماً أو ماءً أو أقراصاً فموية — قد لا يستطيع البلع.',
        imageUrl: null,
      ),
      FirstAidStep(
        number: 5,
        instruction:
            'إن فقد الوعي وتوقف التنفس: ابدأ CPR فوراً. حتى بعد تحسن الحالة — يجب نقله للمستشفى لأن الأعراض قد تعود خلال ساعات.',
        imageUrl: null,
      ),
    ],
  ),
];

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('الإسعافات الأولية'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'ابحث عن حالة إسعافية...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _query = ''),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'لا توجد نتائج',
                    subtitle: 'حاول البحث بكلمات أخرى',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (ctx, i) => _FirstAidCard(item: _filtered[i]),
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
      case 'critical': return AppColors.criticalRed;
      case 'high': return AppColors.warning;
      default: return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FirstAidDetailPage(item: item)),
      ),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            child: CachedNetworkImage(
              imageUrl: item.heroImage,
              httpHeaders: const {
                'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
                'Referer': 'https://commons.wikimedia.org/',
              },
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 160,
                color: AppColors.background,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (_, __, ___) => Container(
                height: 160,
                color: AppColors.background,
                child: const Icon(Icons.medical_services_outlined, size: 48, color: AppColors.textMuted),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.titleLarge),
                      Text(item.subtitle, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _urgencyColor.withOpacity(0.1),
                    borderRadius: AppRadius.radiusXl,
                    border: Border.all(color: _urgencyColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    item.urgencyLevel == 'critical' ? 'حرج' : item.urgencyLevel == 'high' ? 'عاجل' : 'عادي',
                    style: AppTextStyles.labelMedium.copyWith(color: _urgencyColor, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FirstAidDetailPage extends StatelessWidget {
  final FirstAidItem item;
  const FirstAidDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppColors.navy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(item.title, style: AppTextStyles.headlineMedium.copyWith(color: AppColors.white)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.heroImage,
                    httpHeaders: const {
                      'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
                      'Referer': 'https://commons.wikimedia.org/',
                    },
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AppCard(
                  color: AppColors.warning.withOpacity(0.05),
                  border: BorderSide(color: AppColors.warning.withOpacity(0.2)),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          item.urgencyLevel == 'critical'
                              ? 'حالة طارئة جداً — ابدأ الإسعافات واتصل بـ 123 فوراً'
                              : 'اتبع الخطوات بدقة واتصل بالإسعاف إذا لزم الأمر',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('خطوات الإسعاف', style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppSpacing.md),
                ...item.steps.map((step) => _StepItem(step: step)),
                const SizedBox(height: AppSpacing.xl),
                GlassCard(
                  borderColor: NC.primary.withOpacity(0.2),
                  child: Text(
                    'تنبيه: هذه المعلومات للأغراض الإرشادية فقط. نجدة تخلي مسؤوليتها عن سوء استخدام هذه المعلومات.',
                    style: NC.body(12, color: NC.primary),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
                  child: Text(
                    '© الصور: Wikimedia Commons — CC-BY-SA 4.0',
                    style: NC.body(10, color: NC.textLow),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final FirstAidStep step;
  const _StepItem({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (step.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                child: CachedNetworkImage(
                  imageUrl: step.imageUrl!,
                  httpHeaders: const {
                    'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
                    'Referer': 'https://commons.wikimedia.org/',
                  },
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${step.number}',
                        style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      step.instruction,
                      style: AppTextStyles.bodyLarge,
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
