import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'en';

  LanguageProvider() {
    _loadLanguage();
  }

  String get currentLanguage => _currentLanguage;

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language_code') ?? 'en';
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    notifyListeners();
  }

  String translate(String key) {
    return _localizedStrings[_currentLanguage]?[key] ?? key;
  }

  // 🔴 मास्टर ट्रांसलेशन मैप (The Master Translation Map)
  static final Map<String, Map<String, String>> _localizedStrings = {
    // ================= ENGLISH (en) =================
    'en': {

      'profile': 'Profile',
      'save_changes': 'Save Changes',
      'saved_success': 'Profile Updated Successfully!',
      'logout': 'Logout',
      // General
      'app_name': 'BeejuDay',
      'loading': 'Loading...',
      'success': 'Success',
      'error': 'Error',
      'next': 'NEXT',
      'submit': 'SUBMIT',
      'required': 'Required',
      'choose': 'Choose',
      'enter_here': 'Enter here',
      'apply': 'Apply',
      'cancel': 'Cancel',
      
      // Language Screen
      'choose_lang': 'Choose Language',
      // 🔴 UPDATED TO ACRES
      
      // Auth (Login/Signup)
      'login': 'Login',
      'sign_up': 'Sign Up',
      'create_account': 'Create your account',
      'welcome_back': 'Welcome back!',
      'enter_email': 'Enter your email',
      'enter_password': 'Enter your password',
      'name': 'Name',
      'user_exists': 'User already exists',
      'invalid_login': 'Invalid login credentials',
      'no_account': 'Don\'t have an account?',
      'already_have_account': 'Already have an account?',
      'create_one': 'Create one',
      'accept_terms_prefix': 'By tapping SIGN UP you accept all',
      'terms': 'terms',
      'conditions': 'conditions',
      'and': 'and',

      // Farmer Registration
      'farmer_registration': 'Farmer Registration',
      'village_district': 'Village / District',
      'state': 'State',
      'enter_state': 'Enter State',
      'land_size_hectares': 'Land Size (Acres)', 
      'land_size': 'Land Size',
      'ha': 'Acres',     

      'soil_type': 'Soil Type',
      'irrigation': 'Irrigation',
      'market_access': 'Market Access',
      'preferred_crop': 'Preferred Crop',
      'experience': 'Experience',
      
      // Home Categories
      'categories': 'Categories',
      'weather_prediction': 'Weather Prediction',
      'govt_subsidies': 'Government Subsidies',
      'profits': 'Profits',
      'market_value_prediction': 'Market Value Prediction',
      'fpo_procurement': 'FPO Procurement',
      'ai_crop_recommendation': 'AI Crop Recommendation',

      // Weather Screen
      'current_weather': 'Current Weather',
      'forecast_header': '3 Days Forecast',
      'ai_suggestion': 'AI Suggestion',
      'see_full_forecast': 'SEE FULL FORECAST',
      'temperature': 'Temperature',
      'humidity': 'Humidity',
      'rain_prob': 'Rain Probability',
      'wind_speed': 'Wind Speed',
      'day': 'Day',
      'today': 'Today',
      'temp': 'Temp',
      'rain_percent': 'Rain %',
      'advisory': 'Advisory',
      'ai_weather_tip': 'Based on forecast, delay sowing for 2 days. Best sowing window: Day 3.',
      'good_condition': 'Good condition',
      'delay_irrigation': 'Delay irrigation',
      'heat_alert': 'Heat alert',

      // Govt Schemes
      'govt_schemes': 'Government Schemes',
      'no_schemes_found': 'No schemes found',
      'scheme_name': 'Scheme Name',
      'eligibility': 'Eligibility',
      'benefit': 'Benefit',

      // Market Price
      'market_insights': 'Market Insights',
      'live_price': 'Live Price',
      'rising': 'Rising',
      'falling': 'Falling',
      'stable': 'Stable',
      'price_history': 'Price History (Last 7 Days)',
      'ai_forecast': 'AI FORECAST (Next Season)',
      'est_price': 'Est. Price',
      'est_yield': 'Est. Yield',
      'net_profit': 'Net Profit',
      'loading_market_data': 'Loading Market Data...',
      // Days
      'mon': 'Mon', 'tue': 'Tue', 'wed': 'Wed', 'thu': 'Thu', 'fri': 'Fri', 'sat': 'Sat', 'sun': 'Sun',

      // FPO Screens
      'fpo_offers': 'FPO Offers',
      'valid_till': 'Valid till',
      'qtl': 'qtl',
      'offer_details': 'Offer Details',
      'location': 'Location',
      'crop': 'Crop',
      'price': 'Price',
      'quantity_limit': 'Quantity Limit',
      'commit_produce': 'Commit your Produce',
      'farmer_name': 'Farmer Name',
      'quantity': 'Quantity',
      'generate_slip': 'GENERATE SLIP',
      'send_interest': 'SEND INTEREST',
      'interest_sent_msg': 'Your interest has been sent to the FPO.',

      // Profits Screen
      'crop_economics': 'Crop Economics',
      'highest_profit': 'HIGHEST PROFIT',
      'all_crops_comparison': 'All Crops Comparison',
      'revenue': 'Revenue',
      'cost': 'Cost',
      'yield': 'Yield',
      
      // Crop Recommendation
      'ai_recommendation': 'AI Recommendation',
      'initializing': 'Initializing...',
      'loading_profile': 'Loading Profile...',
      'loading_model': 'Loading AI Model...',
      'fetching_weather': 'Fetching Local Weather...',
      'running_prediction': 'Running Prediction...',
      'generating_insights': 'Generating Insights...',
      'analysis_based_on_location': 'Analysis based on your location',
      'rain_est': 'Rain Est',
      'ranking_title': 'Ranking of Crops',
      'best_crop_label': 'BEST CROP FOR YOU',
      'why_this_crop': 'Why this crop?',
      'analyzing': 'Analyzing...',
      'suitability': 'Suitability',

      // Common Crops & Soils (Dropdowns)
      'Sandy': 'Sandy',
      'Loamy': 'Loamy',
      'Clayey': 'Clayey',
      'Black': 'Black',
      'Red': 'Red',
      'Rainfed': 'Rainfed',
      'Irrigated': 'Irrigated',
      'Mustard': 'Mustard',
      'Wheat': 'Wheat',
      'Rice': 'Rice',
      'Maize': 'Maize',
      'Cotton': 'Cotton',
      'Groundnut': 'Groundnut',
      'Sugarcane': 'Sugarcane',
      'Bajra': 'Bajra',
      'Jeera': 'Jeera',
      'Soybean': 'Soybean',
      'Potato': 'Potato',
      'Onion': 'Onion',
      'Tobacco': 'Tobacco',
      'Sesamum': 'Sesamum',
      'Barley': 'Barley',
      'qtl_ha': 'q/acre',
    },

    // ================= HINDI (hi) =================
    'hi': {
      'profile': 'प्रोफ़ाइल',
      'save_changes': 'बदलाव सहेजें',
      'saved_success': 'प्रोफ़ाइल अपडेट हो गया!',
      'logout': 'लॉग आउट',
      // General
      'app_name': 'बीજુडे',
      'loading': 'लोड हो रहा है...',
      'success': 'सफल',
      'error': 'त्रुटि',
      'next': 'अगला',
      'submit': 'जमा करें',
      'required': 'अनिवार्य',
      'choose': 'चुनें',
      'enter_here': 'यहाँ दर्ज करें',
      'apply': 'आवेदन करें',
      'cancel': 'रद्द करें',

      // Language Screen
      'choose_lang': 'अपनी भाषा चुनें',

      // Auth
      'login': 'लॉगिन',
      'sign_up': 'साइन अप',
      'create_account': 'अपना खाता बनाएं',
      'welcome_back': 'वापसी पर स्वागत है!',
      'enter_email': 'अपना ईमेल दर्ज करें',
      'enter_password': 'अपना पासवर्ड दर्ज करें',
      'name': 'नाम',
      'user_exists': 'उपयोगकर्ता पहले से मौजूद है',
      'invalid_login': 'लॉगिन विवरण अमान्य है',
      'no_account': 'खाता नहीं है?',
      'already_have_account': 'पहले से खाता है?',
      'create_one': 'नया बनाएं',
      'accept_terms_prefix': 'साइन अप करके आप सभी शर्तें',
      'terms': 'नियम',
      'conditions': 'शर्तें',
      'and': 'और',

      // Farmer Registration
      'farmer_registration': 'किसान पंजीकरण',
      'village_district': 'गाँव / जिला',
      'state': 'राज्य',
      'enter_state': 'राज्य दर्ज करें',
      // 🔴 UPDATED TO ACRES
      'land_size_hectares': 'भूमि का आकार (एकड़)',
      'land_size': 'भूमि का आकार',
      'ha': 'एकड़',
      'soil_type': 'मिट्टी का प्रकार',
      'irrigation': 'सिंचाई',
      'market_access': 'बाज़ार पहुंच',
      'preferred_crop': 'पसंदीदा फसल',
      'experience': 'अनुभव',

      // Home Categories
      'categories': 'श्रेणियाँ',
      'weather_prediction': 'मौसम भविष्यवाणी',
      'govt_subsidies': 'सरकारी योजनाएं',
      'profits': 'मुनाफा गणना',
      'market_value_prediction': 'बाज़ार भाव भविष्यवाणी',
      'fpo_procurement': 'FPO खरीद',
      'ai_crop_recommendation': 'AI फसल सलाह',

      // Weather Screen
      'current_weather': 'वर्तमान मौसम',
      'forecast_header': '3 दिनों का पूर्वानुमान',
      'ai_suggestion': 'AI सुझाव',
      'see_full_forecast': 'पूरा पूर्वानुमान देखें',
      'temperature': 'तापमान',
      'humidity': 'नमी',
      'rain_prob': 'बारिश की संभावना',
      'wind_speed': 'हवा की गति',
      'day': 'दिन',
      'today': 'आज',
      'temp': 'तापमान',
      'rain_percent': 'बारिश %',
      'advisory': 'सलाह',
      'ai_weather_tip': 'पूर्वानुमान के आधार पर, बुवाई में 2 दिन की देरी करें। सबसे अच्छा समय: दिन 3।',
      'good_condition': 'अच्छी स्थिति',
      'delay_irrigation': 'सिंचाई रोके',
      'heat_alert': 'गर्मी की चेतावनी',

      // Govt Schemes
      'govt_schemes': 'सरकारी योजनाएं',
      'no_schemes_found': 'कोई योजना नहीं मिली',
      'scheme_name': 'योजना का नाम',
      'eligibility': 'पात्रता',
      'benefit': 'लाभ',

      // Market Price
      'market_insights': 'बाज़ार अंतर्दृष्टि',
      'live_price': 'ताज़ा भाव',
      'rising': 'बढ़ रहा है',
      'falling': 'गिर रहा है',
      'stable': 'स्थिर',
      'price_history': 'मूल्य इतिहास (पिछले 7 दिन)',
      'ai_forecast': 'AI पूर्वानुमान (अगला सीजन)',
      'est_price': 'अनुमानित भाव',
      'est_yield': 'अनुमानित उपज',
      'net_profit': 'शुद्ध लाभ',
      'loading_market_data': 'बाज़ार डेटा लोड हो रहा है...',
      // Days
      'mon': 'सोम', 'tue': 'मंगल', 'wed': 'बुध', 'thu': 'गुरु', 'fri': 'शुक्र', 'sat': 'शनि', 'sun': 'रवि',

      // FPO Screens
      'fpo_offers': 'FPO प्रस्ताव',
      'valid_till': 'वैधता',
      'qtl': 'क्विंटल',
      'offer_details': 'प्रस्ताव विवरण',
      'location': 'स्थान',
      'crop': 'फसल',
      'price': 'भाव',
      'quantity_limit': 'मात्रा सीमा',
      'commit_produce': 'अपनी उपज बेचने का वादा करें',
      'farmer_name': 'किसान का नाम',
      'quantity': 'मात्रा',
      'generate_slip': 'पर्ची जनरेट करें',
      'send_interest': 'रुचि भेजें',
      'interest_sent_msg': 'आपकी रुचि FPO को भेज दी गई है।',

      // Profits Screen
      'crop_economics': 'फसल अर्थशास्त्र',
      'highest_profit': 'सर्वाधिक लाभ',
      'all_crops_comparison': 'सभी फसलों की तुलना',
      'revenue': 'आय',
      'cost': 'लागत',
      'yield': 'उपज',

      // Crop Recommendation
      'ai_recommendation': 'AI सिफारिश',
      'initializing': 'शुरू हो रहा है...',
      'loading_profile': 'प्रोफाइल लोड हो रहा है...',
      'loading_model': 'AI मॉडल लोड हो रहा है...',
      'fetching_weather': 'स्थानीय मौसम लाया जा रहा है...',
      'running_prediction': 'भविष्यवाणी चल रही है...',
      'generating_insights': 'अंतर्दृष्टि उत्पन्न हो रही है...',
      'analysis_based_on_location': 'आपके स्थान के आधार पर विश्लेषण',
      'rain_est': 'अनुमानित बारिश',
      'ranking_title': 'फसलों की रैंकिंग',
      'best_crop_label': 'आपके लिए सर्वोत्तम फसल',
      'why_this_crop': 'यह फसल क्यों?',
      'analyzing': 'विश्लेषण जारी है...',
      'suitability': 'उपयुक्तता',

      // Dropdowns
      'Sandy': 'रेतीली',
      'Loamy': 'दोमट',
      'Clayey': 'चिकनी',
      'Black': 'काली',
      'Red': 'लाल',
      'Rainfed': 'वर्षा आधारित',
      'Irrigated': 'सिंचित',
      // Crops
      'Mustard': 'सरसों',
      'Wheat': 'गेहूँ',
      'Rice': 'चावल (धान)',
      'Maize': 'मक्का',
      'Cotton': 'कपास',
      'Groundnut': 'मूंगफली',
      'Sugarcane': 'गन्ना',
      'Bajra': 'बाजरा',
      'Jeera': 'जीरा',
      'Soybean': 'सोयाबीन',
      'Potato': 'आलू',
      'Onion': 'प्याज',
      'Tobacco': 'तंबाकू',
      'Sesamum': 'तिल',
      'Barley': 'जौ',
      'qtl_ha': 'क्विंटल/एकड़',
    },

    // ================= GUJARATI (gu) =================
    'gu': {
      'profile': 'પ્રોફાઇલ',
      'save_changes': 'ફેરફારો સાચવો',
      'saved_success': 'પ્રોફાઇલ અપડેટ થઈ ગયું!',
      'logout': 'લૉગ આઉટ',
      // General
      'app_name': 'બીજુડે',
      'loading': 'લોડ થઈ રહ્યું છે...',
      'success': 'સફળ',
      'error': 'ભૂલ',
      'next': 'આગળ',
      'submit': 'સબમિટ કરો',
      'required': 'જરૂરી',
      'choose': 'પસંદ કરો',
      'enter_here': 'અહીં દાખલ કરો',
      'apply': 'અરજી કરો',
      'cancel': 'રદ કરો',

      // Language Screen
      'choose_lang': 'તમારી ભાષા પસંદ કરો',

      // Auth
      'login': 'લોગિન',
      'sign_up': 'સાઇન અપ',
      'create_account': 'તમારું ખાતું બનાવો',
      'welcome_back': 'સ્વાગત છે!',
      'enter_email': 'તમારું ઇમેઇલ દાખલ કરો',
      'enter_password': 'તમારો પાસવર્ડ દાખલ કરો',
      'name': 'નામ',
      'user_exists': 'વપરાશકર્તા પહેલેથી જ અસ્તિત્વમાં છે',
      'invalid_login': 'અમાન્ય લોગિન વિગતો',
      'no_account': 'ખાતું નથી?',
      'already_have_account': 'પહેલેથી ખાતું છે?',
      'create_one': 'એક બનાવો',
      'accept_terms_prefix': 'સાઇન અપ કરીને તમે તમામ શરતો',
      'terms': 'નિયમો',
      'conditions': 'શરતો',
      'and': 'અને',

      // Farmer Registration
      'farmer_registration': 'ખેડૂત નોંધણી',
      'village_district': 'ગામ / જિલ્લો',
      'state': 'રાજ્ય',
      'enter_state': 'રાજ્ય દાખલ કરો',
      'land_size_hectares': 'જમીનનું કદ (એકર)',
      'land_size': 'જમીનનું કદ',
      'ha': 'એકર',
      'soil_type': 'જમીનનો પ્રકાર',
      'irrigation': 'સિંચાઈ',
      'market_access': 'બજાર પ્રવેશ',
      'preferred_crop': 'પસંદગીનો પાક',
      'experience': 'અનુભવ',

      // Home Categories
      'categories': 'શ્રેણીઓ',
      'weather_prediction': 'હવામાન આગાહી',
      'govt_subsidies': 'સરકારી યોજનાઓ',
      'profits': 'નફો ગણતરી',
      'market_value_prediction': 'બજાર ભાવ આગાહી',
      'fpo_procurement': 'FPO ખરીદી',
      'ai_crop_recommendation': 'AI પાક સલાહ',

      // Weather Screen
      'current_weather': 'વર્તમાન હવામાન',
      'forecast_header': '3 દિવસની આગાહી',
      'ai_suggestion': 'AI સૂચન',
      'see_full_forecast': 'સંપૂર્ણ આગાહી જુઓ',
      'temperature': 'તાપમાન',
      'humidity': 'ભેજ',
      'rain_prob': 'વરસાદની સંભાવના',
      'wind_speed': 'પવનની ઝડપ',
      'day': 'દિવસ',
      'today': 'આજે',
      'temp': 'તાપમાન',
      'rain_percent': 'વરસાદ %',
      'advisory': 'સલાહ',
      'ai_weather_tip': 'આગાહી મુજબ, વાવણીમાં 2 દિવસ વિલંબ કરો. શ્રેષ્ઠ સમય: દિવસ 3.',
      'good_condition': 'સારી સ્થિતિ',
      'delay_irrigation': 'સિંચાઈ મોકૂફ રાખો',
      'heat_alert': 'ગરમીની ચેતવણી',

      // Govt Schemes
      'govt_schemes': 'સરકારી યોજનાઓ',
      'no_schemes_found': 'કોઈ યોજના મળી નથી',
      'scheme_name': 'યોજનાનું નામ',
      'eligibility': 'લાયકાત',
      'benefit': 'લાભ',

      // Market Price
      'market_insights': 'બજાર અંદાજ',
      'live_price': 'જીવંત ભાવ',
      'rising': 'વધી રહ્યો છે',
      'falling': 'ઘટી રહ્યો છે',
      'stable': 'સ્થિર',
      'price_history': 'ભાવ ઇતિહાસ (છેલ્લા 7 દિવસ)',
      'ai_forecast': 'AI આગાહી (આગામી સીઝન)',
      'est_price': 'અંદાજિત ભાવ',
      'est_yield': 'અંદાજિત ઉપજ',
      'net_profit': 'ચોખ્ખો નફો',
      'loading_market_data': 'બજાર ડેટા લોડ થઈ રહ્યો છે...',
      // Days
      'mon': 'સોમ', 'tue': 'મંગળ', 'wed': 'બુધ', 'thu': 'ગુરુ', 'fri': 'શુક્ર', 'sat': 'શનિ', 'sun': 'રવિ',

      // FPO Screens
      'fpo_offers': 'FPO ઓફર્સ',
      'valid_till': 'માન્યતા',
      'qtl': 'ક્વિન્ટલ',
      'offer_details': 'ઓફર વિગતો',
      'location': 'સ્થળ',
      'crop': 'પાક',
      'price': 'ભાવ',
      'quantity_limit': 'જથ્થા મર્યાદા',
      'commit_produce': 'તમારો પાક વેચવાનું વચન આપો',
      'farmer_name': 'ખેડૂતનું નામ',
      'quantity': 'જથ્થો',
      'generate_slip': 'સ્લિપ જનરેટ કરો',
      'send_interest': 'રસ મોકલો',
      'interest_sent_msg': 'તમારો રસ FPO ને મોકલવામાં આવ્યો છે.',

      // Profits Screen
      'crop_economics': 'પાક અર્થશાસ્ત્ર',
      'highest_profit': 'સૌથી વધુ નફો',
      'all_crops_comparison': 'બધા પાકોની સરખામણી',
      'revenue': 'આવક',
      'cost': 'ખર્ચ',
      'yield': 'ઉપજ',

      // Crop Recommendation
      'ai_recommendation': 'AI ભલામણ',
      'initializing': 'શરૂ થઈ રહ્યું છે...',
      'loading_profile': 'પ્રોફાઇલ લોડ થઈ રહ્યું છે...',
      'loading_model': 'AI મોડેલ લોડ થઈ રહ્યું છે...',
      'fetching_weather': 'સ્થાનિક હવામાન મેળવી રહ્યું છે...',
      'running_prediction': 'આગાહી ચાલી રહી છે...',
      'generating_insights': 'ઇનસાઇટ્સ જનરેટ થઈ રહી છે...',
      'analysis_based_on_location': 'તમારા સ્થાનના આધારે વિશ્લેષણ',
      'rain_est': 'અંદાજિત વરસાદ',
      'ranking_title': 'પાક રેન્કિંગ',
      'best_crop_label': 'તમારા માટે શ્રેષ્ઠ પાક',
      'why_this_crop': 'આ પાક શા માટે?',
      'analyzing': 'વિશ્લેષણ ચાલી રહ્યું છે...',
      'suitability': 'અનુકૂળતા',

      // Dropdowns
      'Sandy': 'રેતાળ',
      'Loamy': 'ગોરાડુ',
      'Clayey': 'ચીકણી',
      'Black': 'કાળી',
      'Red': 'લાલ',
      'Rainfed': 'વરસાદ આધારિત',
      'Irrigated': 'પિયત',
      // Crops
      'Mustard': 'રાયડો',
      'Wheat': 'ઘઉં',
      'Rice': 'ચોખા (ડાંગર)',
      'Maize': 'મકાઈ',
      'Cotton': 'કપાસ',
      'Groundnut': 'મગફળી',
      'Sugarcane': 'શેરડી',
      'Bajra': 'બાજરી',
      'Jeera': 'જીરું',
      'Soybean': 'સોયાબીન',
      'Potato': 'બટાકા',
      'Onion': 'ડુંગળી',
      'Tobacco': 'તમાકુ',
      'Sesamum': 'તલ',
      'Barley': 'જવ',
      'qtl_ha': 'ક્વિન્ટલ/એકર',
    },
  };
}