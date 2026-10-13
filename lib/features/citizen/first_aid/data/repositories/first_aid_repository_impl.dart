import '../../domain/entities/first_aid_item.dart';
import '../../domain/repositories/first_aid_repository.dart';

class FirstAidRepositoryImpl implements FirstAidRepository {
  @override
  Future<List<FirstAidItem>> getFirstAidItems() async {
    // For now, we return the static data. In a real app, this could be from a local JSON or API.
    return kFirstAidData;
  }
}

final kFirstAidData = <FirstAidItem>[
  // ... (I'll copy the data here)
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
  FirstAidItem(
    id: 'choking',
    title: 'الاختناق',
    subtitle: 'انسداد مجرى الهواء',
    urgencyLevel: 'critical',
    heroImage:
        'https://commons.wikimedia.org/wiki/Special:Redirect/file/Heimlich_Maneuver.jpg',
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
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/Back_blow_adult.jpg',
      ),
      FirstAidStep(
        number: 3,
        instruction:
            'إن لم تنجح الضربات: قف خلفه، ضع قبضة يدك (الجانب الإبهامي) أسفل عظمة القفص الصدري وفوق السرة مباشرة.',
        imageUrl:
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/Heimlich_Maneuver.jpg',
      ),
      FirstAidStep(
        number: 4,
        instruction:
            'اقبض اليد الأخرى على قبضتك. اضغط بسرعة وقوة للداخل وللأعلى 5 مرات (مناورة هيمليك). كل ضغطة يجب أن تكون مستقلة وقوية.',
        imageUrl:
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/Heimlich_Maneuver.jpg',
      ),
      FirstAidStep(
        number: 5,
        instruction:
            'كرّر: 5 ضربات ظهر + 5 ضغطات بطن بالتناوب حتى يخرج الجسم الغريب أو يتنفس المصاب. إن فقد الوعي ابدأ CPR.',
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
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/Tourniquet_TCCC.jpg',
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
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/Tourniquet_TCCC.jpg',
      ),
    ],
  ),
  FirstAidItem(
    id: 'burns',
    title: 'الحروق',
    subtitle: 'حروق حرارية وكيميائية',
    urgencyLevel: 'high',
    heroImage:
        'https://commons.wikimedia.org/wiki/Special:Redirect/file/Running_water_on_burn.jpg',
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
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/Running_water_on_burn.jpg',
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
  FirstAidItem(
    id: 'fracture',
    title: 'الكسور',
    subtitle: 'تثبيت العظام المكسورة',
    urgencyLevel: 'high',
    heroImage:
        'https://commons.wikimedia.org/wiki/Special:Redirect/file/Splint.jpg',
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
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/Splint.jpg',
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
  FirstAidItem(
    id: 'stroke',
    title: 'السكتة الدماغية',
    subtitle: 'اختبار FAST السريع',
    urgencyLevel: 'critical',
    heroImage:
        'https://commons.wikimedia.org/wiki/Special:Redirect/file/FAST_stroke_warning_signs.png',
    steps: [
      FirstAidStep(
        number: 1,
        instruction:
            'F — Face (الوجه): اطلب منه الابتسام. هل أحد جانبَي الفم مائل للأسفل أو متدلٍّ؟ هذا تحذير.',
        imageUrl:
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/FAST_stroke_warning_signs.png',
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
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/Recovery_position.jpg',
      ),
    ],
  ),
  FirstAidItem(
    id: 'drowning',
    title: 'الغرق',
    subtitle: 'إنقاذ الغريق والإسعاف',
    urgencyLevel: 'critical',
    heroImage:
        'https://commons.wikimedia.org/wiki/Special:Redirect/file/AED_training_05.jpg',
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
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/CPR_training-09.jpg',
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
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/Recovery_position.jpg',
      ),
    ],
  ),
  FirstAidItem(
    id: 'poisoning',
    title: 'التسمم',
    subtitle: 'دواء أو مواد كيميائية',
    urgencyLevel: 'high',
    heroImage:
        'https://commons.wikimedia.org/wiki/Special:Redirect/file/Activated_Charcoal_Antidote.jpg',
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
  FirstAidItem(
    id: 'seizure',
    title: 'نوبة صرع',
    subtitle: 'التعامل مع نوبة تشنج',
    urgencyLevel: 'high',
    heroImage:
        'https://commons.wikimedia.org/wiki/Special:Redirect/file/Recovery_position.jpg',
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
            'https://commons.wikimedia.org/wiki/Special:Redirect/file/Recovery_position.jpg',
      ),
    ],
  ),
  FirstAidItem(
    id: 'anaphylaxis',
    title: 'الحساسية الحادة',
    subtitle: 'صدمة تحسسية — أنافيلاكسيس',
    urgencyLevel: 'critical',
    heroImage:
        'https://commons.wikimedia.org/wiki/Special:Redirect/file/AED_training_05.jpg',
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
