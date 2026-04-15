import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/OrderProvider.dart';
import 'package:provider/provider.dart';

class VoiceService {
  static final List<String> sortedKeys = masterMap.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  static const Map<String, String> masterMap = {
    'ایک': '1', 'دو': '2', 'تین': '3', 'چار': '4', 'پانچ': '5', 'چھ': '6', 'چھے': '6', 'سات': '7', 'آٹھ': '8', 'اٹھ': '8', 'نو': '9', 'دس': '10', 'دص': '10','ڈس': '10', 'گیارہ': '11',
    'بارہ': '12', 'تیرہ': '13', 'چودہ': '14', 'پندرہ': '15', 'سولہ': '16', 'سترہ': '17', 'اٹھارہ': '18', 'انیس': '19', 'بیس': '20',
    'اکیس': '21', 'بائیس': '22', 'تئیس': '23', 'چوبیس': '24', 'پچیس': '25', 'چھبیس': '26', 'ستائیس': '27', 'اٹھائیس': '28',
    'انتیس': '29', 'تیس': '30', 'اکتیس': '31', 'بتیس': '32', 'تینتیس': '33', 'چونتیس': '34', 'پینتیس': '35', 'چھتیس': '36',
    'سینتیس': '37', 'اڑتیس': '38', 'انتالیس': '39', 'چالیس': '40', 'اکتالیس': '41', 'بیاس': '42', 'بیا لیس': '42', 'تینتالیس': '43',
    'چوالیس': '44', 'پینتالیس': '45', 'چھیالیس': '46', 'سینتالیس': '47', 'اڑتالیس': '48', 'انچاس': '49', 'پچاس': '50', 'اکیاون': '51',
    'باون': '52', 'تریپن': '53', 'چون': '54', 'پچپن': '55', 'چھپن': '56', 'ستاون': '57', 'اٹھاون': '58', 'انسٹھ': '59', 'ساٹھ': '60',
    'اکسٹھ': '61', 'باسٹھ': '62', 'تریسٹھ': '63', 'چونسٹھ': '64', 'پینسٹھ': '65', 'چھیاسٹھ': '66', 'سرسٹھ': '67', 'اڑسٹھ': '68', 'انہتر': '69',
    'ستر': '70', 'اکہتر': '71', 'بہتر': '72', 'تہتر': '73', 'چوہتر': '74', 'پچھتر': '75', 'چھہتر': '76', 'ستتر': '77',
    'اٹھہتر': '78', 'انیاسی': '79', 'اسی': '80', 'اکیاسی': '81', 'بیاسی': '82', 'تیاسی': '83', 'چوراسی': '84', 'پچاسی': '85',
    'چھیاسی': '86', 'ستاسی': '87', 'اٹھاسی': '88', 'نواسی': '89', 'نوے': '90', 'اکانوے': '91', 'بانوے': '92', 'ترانوے': '93',
    'چورانوے': '94', 'پچانوے': '95', 'چھیانوے': '96', 'ستانوے': '97', 'اٹھانوے': '98', 'ننانوے': '99', 'سو': '100',
    'one': '1', 'two': '2', 'too': '2', 'to': '2', 'three': '3', 'four': '4', 'for': '4', 'five': '5', 'six': '6', 'seven': '7', 'eight': '8', 'nine': '9', 'ten': '10',
    'ek': '1', 'yak': '1', 'du': '2', 'dwa': '2', 'do': '2', 'teen': '3', 'tre': '3', 'char': '4', 'tsalor': '4', 'panch': '5', 'pinz': '5', 'chey': '6', 'che': '6', 'shpag': '6',
    'saat': '7', 'sut': '7', 'oowa': '7', 'aath': '8', 'ath': '8', 'aut': '8', 'aat': '8', 'ata': '8', 'nau': '9', 'noo': '9', 'now': '9', 'naw': '9', 'nou': '9', 'nauw': '9','dhas': '10',
    'dhus': '10', 'daas': '10', 'dас': '10', 'das ': '10', 'ده': '10', 'tenn': '10', 'tin': '10', 'gyara': '11', 'geyara': '11', 'yara': '11', 'bara': '12', 'baara': '12', 'tera': '13', 'chowda': '14', 'pandra': '15',
    'panra': '15', 'sola': '16', 'satra': '17', 'athara': '18', 'unnis': '19', 'bees': '20', 'bis': '20', 'ikki': '21', 'bais': '22', 'base': '22', 'teis': '23', 'chobis': '24',
    'pachis': '25', 'chabbis': '26', 'satais': '27', 'athais': '28', 'untees': '29', 'tees': '30', 'thees': '30', 'ikthees': '31', 'battis': '32', 'battees': '32', 'tentis': '33',
    'chontis': '34', 'pantis': '35', 'chattis': '36', 'santis': '37', 'athtis': '38', 'untalis': '39', 'chalis': '40', 'chalees': '40', 'iktalis': '41', 'byalis': '42', 'tentalis': '43',
    'chovalis': '44', 'pantalis': '45', 'chyalis': '46', 'santalis': '47', 'athtalis': '48', 'unachas': '49', 'pachas': '50', 'bachas': '50', 'ikyawan': '51', 'bawan': '52', 'trepan': '53',
    'chowan': '54', 'pachpan': '55', 'chapan': '56', 'satawan': '57', 'athawan': '58', 'unhat': '59', 'saath': '60', 'sath': '60', 'iksath': '61', 'basath': '62', 'tresath': '63',
    'chonsath': '64', 'paintsath': '65', 'chyasath': '66', 'sarsath': '67', 'arsath': '68', 'unhattar': '69', 'sattar': '70', 'satar': '70', 'ikhattar': '71', 'bahattar': '72',
    'tihattar': '73', 'chohattar': '74', 'pachattar': '75', 'chihattar': '76', 'sathattar': '77', 'athhattar': '78', 'unasi': '79', 'assi': '80', 'asi': '80', 'asse': '80', 'ikyasi': '81',
    'byasi': '82', 'tyasi': '83', 'chorasi': '84', 'pachasi': '85', 'chyasi': '86', 'sataasi': '87', 'athasi': '88', 'unnaasi': '89', 'naway': '90', 'naaway': '90', 'nawey': '90',
    'ikyanway': '91', 'banway': '92', 'bahanomay': '92', 'tranway': '93', 'choranway': '94', 'pachanway': '95', 'chiyanway': '96', 'satanway': '97', 'athanway': '98', 'ninanway': '99', 'so': '100',
  };


  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final Map<String, TextEditingController> controllers;
  final Map<String, FocusNode> focusNodes;
  final List<Map<String, String>> fields;
  final ScrollController scrollController;
  final OrderProvider orderProvider;
  final BuildContext context;

  VoiceService({
    required this.controllers,
    required this.focusNodes,
    required this.fields,
    required this.scrollController,
    required this.orderProvider,
    required this.context,
  });


  Future<void> initSpeech() async => await _speech.initialize();

  Future<void> initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    if (Theme.of(context).platform == TargetPlatform.android) {
      await _tts.setSharedInstance(true);
    }
  }

  String _cleanAndConvertVoice(String input) {
    String normalized = input
        .replaceAll('۰', '0').replaceAll('۱', '1').replaceAll('۲', '2')
        .replaceAll('۳', '3').replaceAll('۴', '4').replaceAll('۵', '5')
        .replaceAll('۶', '6').replaceAll('۷', '7').replaceAll('۸', '8')
        .replaceAll('۹', '9');

    final saarheyDigit = RegExp(r'(ساڑھے|سڑے|سڑی|ساڈھے|ساڈے)\s*(\d+)');
    final match = saarheyDigit.firstMatch(normalized);
    if (match != null) {
      final num = int.tryParse(match.group(2)!);
      if (num != null) return '$num.5';
    }

    String text = normalized.toLowerCase().trim();
    debugPrint("STT ne suna: $input");

    List<String> halfKeywords = [
      'سڑے', 'سڑی', 'ساڑھے', 'سارے', 'ساڈے', 'ساڈھے',
      'saray', 'saaray', 'sade', 'sarhe', 'sary', 'sady',
      'sarry', 'sarri',
    ];

    bool indicatesHalf = false;
    for (var key in halfKeywords) {
      if (text.contains(key)) {
        indicatesHalf = true;
        text = text.replaceAll(key, '').trim();
        break;
      }
    }

    // List<String> sortedKeys = masterMap.keys.toList()
    //   ..sort((a, b) => b.length.compareTo(a.length));

    // for (var key in sortedKeys) {
    //   if (text.contains(key)) {
    //     text = text.replaceAll(key, masterMap[key]!);
    //   }
    // }

    for (var key in sortedKeys) {
      if (text.contains(key)) {
        text = text.replaceAll(key, masterMap[key]!);
      }
    }

    text = text.replaceAll(RegExp(r'\s*\.\s*'), '.');
    String numericPart = text.replaceAll(RegExp(r'[^0-9.]'), '');

    if (numericPart.split('.').length > 2) {
      var parts = numericPart.split('.');
      numericPart = parts[0] + '.' + parts.sublist(1).join('');
    }

    if (numericPart.isEmpty) return "";

    if (indicatesHalf) {
      if (numericPart.contains('.5')) return numericPart;
      if (numericPart.contains('.')) return "${numericPart.split('.')[0]}.5";
      return "$numericPart.5";
    }

    return numericPart;
  }


  Future<void> _listenForField(String key, int index) async {
    final orderProv = context.read<OrderProvider>();
    if (!orderProv.isListening) return;

    orderProv.setActiveField(key);

    await Future.delayed(const Duration(milliseconds: 200));
    if (focusNodes[key]?.context != null) {
      Scrollable.ensureVisible(
        focusNodes[key]!.context!,
        duration: const Duration(milliseconds: 400),
        alignment: 0.5,
        curve: Curves.easeOut,
      );
    }

    await Future.delayed(const Duration(milliseconds: 400));

    bool captured = false;
    String capturedValue = "";
    String lastRaw = "";
    String halfWord = "";

    while (controllers[key]!.text.isEmpty && orderProv.isListening) {

      await _tts.stop();
      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 500));

      await SystemSound.play(SystemSoundType.click);
      await HapticFeedback.mediumImpact();

      captured = false;
      capturedValue = "";
      lastRaw = "";

      await _speech.listen(
        localeId: "ur-PK",
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(seconds: 3),
        onResult: (res) {
          if (res.finalResult) {
            String raw = res.recognizedWords.trim();
            debugPrint("RAW STT: '$raw'");
            debugPrint("CODES: ${raw.runes.map((r) => 'U+${r.toRadixString(16).toUpperCase().padLeft(4,'0')}').join(' ')}");

            if (captured) {
              debugPrint("=== ALREADY CAPTURED, IGNORING: '$raw'");
              return;
            }

            List<String> halfOnly = [
              'saray', 'saaray', 'sarhe', 'sade', 'sary', 'sady', 'sarry', 'sarri',
              'ساڑھے', 'سڑے', 'سڑی', 'ساڈھے', 'ساڈے',
            ];
            bool isHalfOnly = halfOnly.any((h) =>
            raw.trim().toLowerCase() == h.toLowerCase() ||
                raw.trim() == h
            );


            if (isHalfOnly) {
              halfWord = raw;
              debugPrint("Half word stored: '$halfWord' — waiting for number...");
              return;
            }

            if (halfWord.isNotEmpty) {
              raw = "$halfWord $raw";
              debugPrint("Combined: '$raw'");
              halfWord = "";
            }

            lastRaw = raw;
            String cleaned = _cleanAndConvertVoice(raw);
            debugPrint("=== CLEANED: '$cleaned'");

            if (cleaned.isNotEmpty && cleaned != ".5" && !captured) {
              captured = true;
              capturedValue = cleaned;
              controllers[key]!.text = cleaned;
              orderProv.updateValueOnly(key, cleaned, controllers);
              debugPrint("=== CONTROLLER SET: '${controllers[key]!.text}'");
              _speech.stop();
            }
          }
        },
      );

      int timeout = 0;
      while (!captured &&
          _speech.isListening &&
          orderProv.isListening &&
          timeout < 20) {
        await Future.delayed(const Duration(milliseconds: 500));
        timeout++;
      }

      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 300));

      if (capturedValue.isEmpty && lastRaw.isNotEmpty) {
        String cleaned = _cleanAndConvertVoice(lastRaw);
        if (cleaned.isNotEmpty && cleaned != ".5") {
          capturedValue = cleaned;

          controllers[key]!.text = cleaned;
          orderProv.updateValueOnly(key, cleaned, controllers);
        }
      }

      if (capturedValue.isNotEmpty) {
        HapticFeedback.lightImpact();
        await _tts.stop();
        await Future.delayed(const Duration(milliseconds: 300));
        await _tts.speak("$capturedValue inch");
        debugPrint("TTS bolega: $capturedValue inch");
        await Future.delayed(const Duration(milliseconds: 800));
        break;
      }

      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  void  startVoiceFlow() async {
    final orderProv = context.read<OrderProvider>();
    await _speech.stop();
    await _tts.stop();
    await Future.delayed(const Duration(milliseconds: 300));

    orderProv.toggleListening(true);

    await scrollController.animateTo(
      580.0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );

    for (int i = 0; i < fields.length; i++) {
      if (!orderProv.isListening) break;
      await _listenForField(fields[i]['e']!, i);
    }

    orderProv.toggleListening(false);
    orderProv.setActiveField(null);

    if (fields.every((f) => controllers[f['e']]!.text.isNotEmpty)) {
      await _tts.speak("The measurement has been completed");
    }
  }
}