import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('vi', 'VN'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App General
      'app_title': 'FlashDesk',
      'settings': 'Settings',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'create': 'Create',
      'close': 'Close',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'skip': 'Skip',
      'continue_text': 'Continue',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',

      // Settings Page
      'appearance': 'Appearance',
      'theme_mode': 'Theme Mode',
      'system_default': 'System Default',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'language': 'Language',
      'language_settings': 'Language Settings',
      'english': 'English',
      'vietnamese': 'Vietnamese',
      'about': 'About',
      'version': 'Version',

      // Dashboard
      'dashboard': 'Dashboard',
      'my_decks': 'My Decks',
      'create_deck': 'Create Deck',
      'new_deck': 'New Deck',
      'deck_name': 'Deck Name',
      'deck_description': 'Description',
      'enter_deck_name': 'Enter deck name',
      'enter_deck_description': 'Enter description (optional)',
      'no_decks': 'No decks yet',
      'create_first_deck': 'Create your first deck to get started!',
      'cards': 'cards',
      'card': 'card',
      'last_studied': 'Last studied',
      'never_studied': 'Never studied',
      'created_on': 'Created on',

      // Deck Actions
      'study': 'Study',
      'edit_deck': 'Edit Deck',
      'delete_deck': 'Delete Deck',
      'delete_deck_confirm': 'Are you sure you want to delete this deck?',
      'deck_deleted': 'Deck deleted successfully',
      'deck_created': 'Deck created successfully',
      'deck_updated': 'Deck updated successfully',

      // Study Modes
      'study_modes': 'Study Modes',
      'flashcards': 'Flashcards',
      'flashcards_desc': 'Review cards one by one',
      'learn': 'Learn',
      'learn_desc': 'Smart learning with spaced repetition',
      'quiz': 'Quiz',
      'quiz_desc': 'Test your knowledge',
      'match': 'Match',
      'match_desc': 'Match terms with definitions',
      'test': 'Test',
      'test_desc': 'Take a comprehensive test',

      // Flashcard Page
      'tap_to_flip': 'Tap to flip',
      'term': 'Term',
      'definition': 'Definition',
      'card_of': 'of',
      'shuffle': 'Shuffle',
      'restart': 'Restart',
      'flip_all': 'Flip All',
      'auto_play': 'Auto Play',
      'stop': 'Stop',

      // Learn Mode
      'learning_progress': 'Learning Progress',
      'mastered': 'Mastered',
      'learning': 'Learning',
      'not_started': 'Not Started',
      'know': 'Know',
      'dont_know': "Don't Know",
      'still_learning': 'Still Learning',
      'got_it': 'Got It',
      'correct': 'Correct',
      'incorrect': 'Incorrect',
      'type_answer': 'Type your answer',
      'check_answer': 'Check Answer',
      'show_answer': 'Show Answer',
      'try_again': 'Try Again',
      'round_complete': 'Round Complete!',
      'learning_complete': 'Learning Complete!',
      'all_cards_mastered': 'You have mastered all cards!',
      'continue_learning': 'Continue Learning',
      'start_new_round': 'Start New Round',
      'finish': 'Finish',
      'streak': 'Streak',
      'best_streak': 'Best Streak',
      'no_cards_to_learn': 'No cards to learn',
      'add_cards_first_study': 'Add some cards to this deck first',
      'go_back': 'Go Back',
      'familiar': 'Familiar',
      'tap_to_see_definition': 'Tap the card to see the definition',
      'do_you_know': 'Do you know this term?',
      'i_know_this': 'I Know This',
      'show_me_quiz': 'Show me quiz',
      'skip_to_typing': 'Skip to typing',
      'choose_correct_definition': 'Choose the correct definition',
      'type_the_definition': 'Type the definition',
      'your_answer': 'Your answer...',
      'submit': 'Submit',
      'dont_know_question': "Don't know?",
      'correct_congrats': 'Correct! 🎉',
      'not_quite_right': 'Not quite right',
      'your_answer_was': 'Your answer',
      'correct_answer': 'Correct Answer',
      'type_correct_to_continue': 'Type the correct answer to continue:',
      'perfect_round': 'Perfect Round! 🌟',
      'session_complete': 'Session Complete! 🎉',
      'mastered_cards': "You've mastered all cards",
      'learn_again': 'Learn Again',

      // Quiz Mode
      'quiz_complete': 'Quiz Complete!',
      'your_score': 'Your Score',
      'questions_correct': 'Questions Correct',
      'review_incorrect': 'Review Incorrect',
      'retake_quiz': 'Retake Quiz',
      'select_answer': 'Select an answer',
      'question': 'Question',
      'answer': 'Answer',
      'multiple_choice': 'Multiple Choice',
      'true_false': 'True/False',
      'written': 'Written',

      // Match Mode
      'match_game': 'Match Game',
      'time_remaining': 'Time Remaining',
      'matches': 'Matches',
      'game_over': 'Game Over!',
      'congratulations': 'Congratulations!',
      'your_time': 'Your Time',
      'play_again': 'Play Again',
      'new_game': 'New Game',
      'pause': 'Pause',
      'resume': 'Resume',
      'best_time': 'Best Time',
      'perfect_match': 'Perfect Match!',

      // Editor
      'add_card': 'Add Card',
      'edit_card': 'Edit Card',
      'delete_card': 'Delete Card',
      'delete_card_confirm': 'Are you sure you want to delete this card?',
      'card_deleted': 'Card deleted',
      'card_added': 'Card added',
      'card_updated': 'Card updated',
      'enter_term': 'Enter term',
      'enter_definition': 'Enter definition',
      'front': 'Front',
      'back': 'Back',
      'swap': 'Swap',
      'import_cards': 'Import Cards',
      'export_cards': 'Export Cards',

      // Validation & Errors
      'field_required': 'This field is required',
      'deck_name_required': 'Deck name is required',
      'term_required': 'Term is required',
      'definition_required': 'Definition is required',
      'no_cards_in_deck': 'No cards in this deck',
      'add_cards_first': 'Add some cards to start studying',
      'something_went_wrong': 'Something went wrong',
      'please_try_again': 'Please try again',

      // Time
      'seconds': 'seconds',
      'minutes': 'minutes',
      'hours': 'hours',
      'days': 'days',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'ago': 'ago',

      // Match Game
      'match_instruction': 'Tap a term, then tap its matching definition',
    },
    'vi': {
      // App General
      'app_title': 'FlashDesk',
      'settings': 'Cài đặt',
      'cancel': 'Hủy',
      'save': 'Lưu',
      'delete': 'Xóa',
      'edit': 'Sửa',
      'create': 'Tạo',
      'close': 'Đóng',
      'confirm': 'Xác nhận',
      'yes': 'Có',
      'no': 'Không',
      'ok': 'OK',
      'back': 'Quay lại',
      'next': 'Tiếp',
      'done': 'Xong',
      'skip': 'Bỏ qua',
      'continue_text': 'Tiếp tục',
      'loading': 'Đang tải...',
      'error': 'Lỗi',
      'success': 'Thành công',

      // Settings Page
      'appearance': 'Giao diện',
      'theme_mode': 'Chế độ hiển thị',
      'system_default': 'Mặc định hệ thống',
      'dark_mode': 'Chế độ tối',
      'light_mode': 'Chế độ sáng',
      'language': 'Ngôn ngữ',
      'language_settings': 'Cài đặt ngôn ngữ',
      'english': 'Tiếng Anh',
      'vietnamese': 'Tiếng Việt',
      'about': 'Thông tin',
      'version': 'Phiên bản',

      // Dashboard
      'dashboard': 'Trang chủ',
      'my_decks': 'Bộ thẻ của tôi',
      'create_deck': 'Tạo bộ thẻ',
      'new_deck': 'Bộ thẻ mới',
      'deck_name': 'Tên bộ thẻ',
      'deck_description': 'Mô tả',
      'enter_deck_name': 'Nhập tên bộ thẻ',
      'enter_deck_description': 'Nhập mô tả (tùy chọn)',
      'no_decks': 'Chưa có bộ thẻ nào',
      'create_first_deck': 'Tạo bộ thẻ đầu tiên để bắt đầu!',
      'cards': 'thẻ',
      'card': 'thẻ',
      'last_studied': 'Học lần cuối',
      'never_studied': 'Chưa từng học',
      'created_on': 'Tạo ngày',

      // Deck Actions
      'study': 'Học',
      'edit_deck': 'Sửa bộ thẻ',
      'delete_deck': 'Xóa bộ thẻ',
      'delete_deck_confirm': 'Bạn có chắc muốn xóa bộ thẻ này không?',
      'deck_deleted': 'Đã xóa bộ thẻ',
      'deck_created': 'Đã tạo bộ thẻ',
      'deck_updated': 'Đã cập nhật bộ thẻ',

      // Study Modes
      'study_modes': 'Chế độ học',
      'flashcards': 'Thẻ ghi nhớ',
      'flashcards_desc': 'Xem lại từng thẻ một',
      'learn': 'Học tập',
      'learn_desc': 'Học thông minh với lặp lại ngắt quãng',
      'quiz': 'Trắc nghiệm',
      'quiz_desc': 'Kiểm tra kiến thức của bạn',
      'match': 'Nối từ',
      'match_desc': 'Nối thuật ngữ với định nghĩa',
      'test': 'Kiểm tra',
      'test_desc': 'Làm bài kiểm tra tổng hợp',

      // Flashcard Page
      'tap_to_flip': 'Chạm để lật',
      'term': 'Thuật ngữ',
      'definition': 'Định nghĩa',
      'card_of': 'trên',
      'shuffle': 'Xáo trộn',
      'restart': 'Bắt đầu lại',
      'flip_all': 'Lật tất cả',
      'auto_play': 'Tự động phát',
      'stop': 'Dừng',

      // Learn Mode
      'learning_progress': 'Tiến độ học',
      'mastered': 'Đã thuộc',
      'learning': 'Đang học',
      'not_started': 'Chưa học',
      'know': 'Biết rồi',
      'dont_know': 'Chưa biết',
      'still_learning': 'Đang học',
      'got_it': 'Đã hiểu',
      'correct': 'Đúng',
      'incorrect': 'Sai',
      'type_answer': 'Nhập câu trả lời',
      'check_answer': 'Kiểm tra',
      'show_answer': 'Xem đáp án',
      'try_again': 'Thử lại',
      'round_complete': 'Hoàn thành lượt!',
      'learning_complete': 'Hoàn thành học tập!',
      'all_cards_mastered': 'Bạn đã thuộc tất cả các thẻ!',
      'continue_learning': 'Tiếp tục học',
      'start_new_round': 'Bắt đầu lượt mới',
      'finish': 'Hoàn thành',
      'streak': 'Chuỗi',
      'best_streak': 'Chuỗi cao nhất',
      'no_cards_to_learn': 'Không có thẻ để học',
      'add_cards_first_study': 'Thêm thẻ vào bộ này trước',
      'go_back': 'Quay lại',
      'familiar': 'Quen thuộc',
      'tap_to_see_definition': 'Chạm vào thẻ để xem định nghĩa',
      'do_you_know': 'Bạn có biết thuật ngữ này không?',
      'i_know_this': 'Tôi biết rồi',
      'show_me_quiz': 'Cho tôi xem quiz',
      'skip_to_typing': 'Chuyển sang gõ',
      'choose_correct_definition': 'Chọn định nghĩa đúng',
      'type_the_definition': 'Gõ định nghĩa',
      'your_answer': 'Câu trả lời của bạn...',
      'submit': 'Gửi',
      'dont_know_question': 'Không biết?',
      'correct_congrats': 'Đúng rồi! 🎉',
      'not_quite_right': 'Chưa đúng',
      'your_answer_was': 'Câu trả lời của bạn',
      'correct_answer': 'Đáp án đúng',
      'type_correct_to_continue': 'Gõ đáp án đúng để tiếp tục:',
      'perfect_round': 'Lượt hoàn hảo! 🌟',
      'session_complete': 'Hoàn thành phiên học! 🎉',
      'mastered_cards': 'Bạn đã thuộc tất cả các thẻ',
      'learn_again': 'Học lại',

      // Quiz Mode
      'quiz_complete': 'Hoàn thành trắc nghiệm!',
      'your_score': 'Điểm của bạn',
      'questions_correct': 'Câu đúng',
      'review_incorrect': 'Xem lại câu sai',
      'retake_quiz': 'Làm lại',
      'select_answer': 'Chọn một đáp án',
      'question': 'Câu hỏi',
      'answer': 'Đáp án',
      'multiple_choice': 'Trắc nghiệm',
      'true_false': 'Đúng/Sai',
      'written': 'Tự luận',

      // Match Mode
      'match_game': 'Trò chơi nối từ',
      'time_remaining': 'Thời gian còn lại',
      'matches': 'Cặp đã nối',
      'game_over': 'Hết giờ!',
      'congratulations': 'Chúc mừng!',
      'your_time': 'Thời gian của bạn',
      'play_again': 'Chơi lại',
      'new_game': 'Ván mới',
      'pause': 'Tạm dừng',
      'resume': 'Tiếp tục',
      'best_time': 'Thời gian tốt nhất',
      'perfect_match': 'Hoàn hảo!',

      // Editor
      'add_card': 'Thêm thẻ',
      'edit_card': 'Sửa thẻ',
      'delete_card': 'Xóa thẻ',
      'delete_card_confirm': 'Bạn có chắc muốn xóa thẻ này không?',
      'card_deleted': 'Đã xóa thẻ',
      'card_added': 'Đã thêm thẻ',
      'card_updated': 'Đã cập nhật thẻ',
      'enter_term': 'Nhập thuật ngữ',
      'enter_definition': 'Nhập định nghĩa',
      'front': 'Mặt trước',
      'back': 'Mặt sau',
      'swap': 'Đổi',
      'import_cards': 'Nhập thẻ',
      'export_cards': 'Xuất thẻ',

      // Validation & Errors
      'field_required': 'Trường này là bắt buộc',
      'deck_name_required': 'Vui lòng nhập tên bộ thẻ',
      'term_required': 'Vui lòng nhập thuật ngữ',
      'definition_required': 'Vui lòng nhập định nghĩa',
      'no_cards_in_deck': 'Bộ thẻ này chưa có thẻ nào',
      'add_cards_first': 'Thêm một số thẻ để bắt đầu học',
      'something_went_wrong': 'Đã xảy ra lỗi',
      'please_try_again': 'Vui lòng thử lại',

      // Time
      'seconds': 'giây',
      'minutes': 'phút',
      'hours': 'giờ',
      'days': 'ngày',
      'today': 'Hôm nay',
      'yesterday': 'Hôm qua',
      'ago': 'trước',

      // Match Game
      'match_instruction':
          'Chạm vào thuật ngữ, sau đó chạm vào định nghĩa tương ứng',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  // Convenience getters for commonly used strings
  String get appTitle => translate('app_title');
  String get settings => translate('settings');
  String get cancel => translate('cancel');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get create => translate('create');
  String get close => translate('close');
  String get confirm => translate('confirm');
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');
  String get back => translate('back');
  String get next => translate('next');
  String get done => translate('done');
  String get skip => translate('skip');
  String get continueText => translate('continue_text');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');

  // Settings
  String get appearance => translate('appearance');
  String get themeMode => translate('theme_mode');
  String get systemDefault => translate('system_default');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get language => translate('language');
  String get languageSettings => translate('language_settings');
  String get english => translate('english');
  String get vietnamese => translate('vietnamese');
  String get about => translate('about');
  String get version => translate('version');

  // Dashboard
  String get dashboard => translate('dashboard');
  String get myDecks => translate('my_decks');
  String get createDeck => translate('create_deck');
  String get newDeck => translate('new_deck');
  String get deckName => translate('deck_name');
  String get deckDescription => translate('deck_description');
  String get enterDeckName => translate('enter_deck_name');
  String get enterDeckDescription => translate('enter_deck_description');
  String get noDecks => translate('no_decks');
  String get createFirstDeck => translate('create_first_deck');
  String get cards => translate('cards');
  String get card => translate('card');
  String get lastStudied => translate('last_studied');
  String get neverStudied => translate('never_studied');
  String get createdOn => translate('created_on');

  // Deck Actions
  String get study => translate('study');
  String get editDeck => translate('edit_deck');
  String get deleteDeck => translate('delete_deck');
  String get deleteDeckConfirm => translate('delete_deck_confirm');
  String get deckDeleted => translate('deck_deleted');
  String get deckCreated => translate('deck_created');
  String get deckUpdated => translate('deck_updated');

  // Study Modes
  String get studyModes => translate('study_modes');
  String get flashcards => translate('flashcards');
  String get flashcardsDesc => translate('flashcards_desc');
  String get learn => translate('learn');
  String get learnDesc => translate('learn_desc');
  String get quiz => translate('quiz');
  String get quizDesc => translate('quiz_desc');
  String get match => translate('match');
  String get matchDesc => translate('match_desc');
  String get test => translate('test');
  String get testDesc => translate('test_desc');

  // Flashcard Page
  String get tapToFlip => translate('tap_to_flip');
  String get term => translate('term');
  String get definition => translate('definition');
  String get cardOf => translate('card_of');
  String get shuffle => translate('shuffle');
  String get restart => translate('restart');
  String get flipAll => translate('flip_all');
  String get autoPlay => translate('auto_play');
  String get stop => translate('stop');

  // Learn Mode
  String get learningProgress => translate('learning_progress');
  String get mastered => translate('mastered');
  String get learning => translate('learning');
  String get notStarted => translate('not_started');
  String get know => translate('know');
  String get dontKnow => translate('dont_know');
  String get stillLearning => translate('still_learning');
  String get gotIt => translate('got_it');
  String get correct => translate('correct');
  String get incorrect => translate('incorrect');
  String get typeAnswer => translate('type_answer');
  String get checkAnswer => translate('check_answer');
  String get showAnswer => translate('show_answer');
  String get tryAgain => translate('try_again');
  String get roundComplete => translate('round_complete');
  String get learningComplete => translate('learning_complete');
  String get allCardsMastered => translate('all_cards_mastered');
  String get continueLearning => translate('continue_learning');
  String get startNewRound => translate('start_new_round');
  String get finish => translate('finish');
  String get streak => translate('streak');
  String get bestStreak => translate('best_streak');
  String get noCardsToLearn => translate('no_cards_to_learn');
  String get addCardsFirstStudy => translate('add_cards_first_study');
  String get goBack => translate('go_back');
  String get familiar => translate('familiar');
  String get tapToSeeDefinition => translate('tap_to_see_definition');
  String get doYouKnow => translate('do_you_know');
  String get iKnowThis => translate('i_know_this');
  String get showMeQuiz => translate('show_me_quiz');
  String get skipToTyping => translate('skip_to_typing');
  String get chooseCorrectDefinition => translate('choose_correct_definition');
  String get typeTheDefinition => translate('type_the_definition');
  String get yourAnswer => translate('your_answer');
  String get submit => translate('submit');
  String get dontKnowQuestion => translate('dont_know_question');
  String get correctCongrats => translate('correct_congrats');
  String get notQuiteRight => translate('not_quite_right');
  String get yourAnswerWas => translate('your_answer_was');
  String get correctAnswer => translate('correct_answer');
  String get typeCorrectToContinue => translate('type_correct_to_continue');
  String get perfectRound => translate('perfect_round');
  String get sessionComplete => translate('session_complete');
  String get masteredCards => translate('mastered_cards');
  String get learnAgain => translate('learn_again');

  // Quiz Mode
  String get quizComplete => translate('quiz_complete');
  String get yourScore => translate('your_score');
  String get questionsCorrect => translate('questions_correct');
  String get reviewIncorrect => translate('review_incorrect');
  String get retakeQuiz => translate('retake_quiz');
  String get selectAnswer => translate('select_answer');
  String get question => translate('question');
  String get answer => translate('answer');
  String get multipleChoice => translate('multiple_choice');
  String get trueFalse => translate('true_false');
  String get written => translate('written');

  // Match Mode
  String get matchGame => translate('match_game');
  String get timeRemaining => translate('time_remaining');
  String get matches => translate('matches');
  String get gameOver => translate('game_over');
  String get congratulations => translate('congratulations');
  String get yourTime => translate('your_time');
  String get playAgain => translate('play_again');
  String get newGame => translate('new_game');
  String get pause => translate('pause');
  String get resume => translate('resume');
  String get bestTime => translate('best_time');
  String get perfectMatch => translate('perfect_match');

  // Editor
  String get addCard => translate('add_card');
  String get editCard => translate('edit_card');
  String get deleteCard => translate('delete_card');
  String get deleteCardConfirm => translate('delete_card_confirm');
  String get cardDeleted => translate('card_deleted');
  String get cardAdded => translate('card_added');
  String get cardUpdated => translate('card_updated');
  String get enterTerm => translate('enter_term');
  String get enterDefinition => translate('enter_definition');
  String get front => translate('front');
  String get backSide => translate('back');
  String get swap => translate('swap');
  String get importCards => translate('import_cards');
  String get exportCards => translate('export_cards');

  // Validation & Errors
  String get fieldRequired => translate('field_required');
  String get deckNameRequired => translate('deck_name_required');
  String get termRequired => translate('term_required');
  String get definitionRequired => translate('definition_required');
  String get noCardsInDeck => translate('no_cards_in_deck');
  String get addCardsFirst => translate('add_cards_first');
  String get somethingWentWrong => translate('something_went_wrong');
  String get pleaseTryAgain => translate('please_try_again');

  // Time
  String get seconds => translate('seconds');
  String get minutes => translate('minutes');
  String get hours => translate('hours');
  String get days => translate('days');
  String get today => translate('today');
  String get yesterday => translate('yesterday');
  String get ago => translate('ago');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
