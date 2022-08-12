import 'package:intl/intl.dart';

mixin L10nStrings {
  // Menu text
  String get myCollectionTitle =>
      Intl.message('マイコレクション', name: 'myCollectionTitle');

  String get favorite => Intl.message("お気に入りを見る（管理）", name: 'favorite');

  String get myMaterial =>
      Intl.message("My Materialsを見る（管理）", name: 'myMaterial');

  String get myMaterialAddText =>
      Intl.message("My Materialsを追加（管理）", name: 'myMaterialAddText');

  String get paymentMethod => Intl.message("お支払方法（管理）", name: 'paymentMethod');

  String get yieldManager => Intl.message("収益管理", name: 'yieldManager');

  String get purchaseHistory => Intl.message("購入履歴", name: 'purchaseHistory');

  String get textHintEmailLogin => Intl.message(
        'メールを入力してください',
        name: 'textHintEmailLo'
            'gin',
      );

  String get textHintPasswordLogin => Intl.message(
        'パスワードを入力してください',
        name: 'textHintPasswordLogin',
      );

  String get startLogin => Intl.message(
        'ログイン',
        name: 'startLogin',
      );

  String get ssoLogin => Intl.message(
        'SSOでログイン',
        name: 'ssoLogin',
      );

  String get register => Intl.message(
        '新規アカウント作成',
        name: 'register',
      );

  String get home => Intl.message(
        'ホーム',
        name: 'home',
      );

  String get other => Intl.message(
        'その他',
        name: 'other',
      );

  String get message => Intl.message(
        'お知らせ',
        name: 'message',
      );

  String get featureNotImplemented => Intl.message(
        'この機能は実装されていません',
        name: 'featureNotImplemented',
      );

  String get registerTitle => Intl.message(
        '新規登録',
        name: 'registerTitle',
      );

  String get userNameText => Intl.message(
        'ユーザー名',
        name: 'userNameText',
      );

  String get emailAddressText => Intl.message(
        'メールアドレス',
        name: 'emailAddressText',
      );

  String get fullNameText => Intl.message(
        '氏名',
        name: 'fullNameText',
      );

  String get passwordText => Intl.message(
        'パスワード',
        name: 'passwordText',
      );

  String get confirmPasswordText => Intl.message(
        'パスワードの確認',
        name: 'confirmPasswordText',
      );

  String get passwordLengthValidText => Intl.message(
        '英数含む8-20文字',
        name: 'passwordLengthValidText',
      );

  String get profileEditingText => Intl.message(
        'プロフィール編集',
        name: 'profileEditingText',
      );

  String get nickNameText => Intl.message(
        'ニックネーム',
        name: 'nickNameText',
      );

  String get changeText => Intl.message(
        '変更',
        name: 'changeText',
      );

  String get labelFollows => Intl.message(
        'フォロワー',
        name: 'labelFollows',
      );

  String get labelVideos => Intl.message(
        'ビデオ',
        name: 'labelVideos',
      );

  String get labelMenu => Intl.message(
        'メニュー',
        name: 'labelMenu',
      );

  String get editProfileMenu => Intl.message(
        'プロフィール編集',
        name: 'editProfileMenu',
      );

  String get labelMyCollection => Intl.message(
        'My Collectionを見る',
        name: 'labelMyCollection',
      );

  String get paymentTypeMenu => Intl.message(
        'お支払い方法',
        name: 'paymentTypeMenu',
      );

  String get incomeManagementMenu => Intl.message(
        '収益管理',
        name: 'incomeManagementMenu',
      );

  String get transactionHistoryMenu => Intl.message(
        '購入履歴',
        name: 'transactionHistoryMenu',
      );

  String get blockManagementMenu => Intl.message(
        'ブロック管理',
        name: 'blockManagementMenu',
      );

  String get favoriteManagementMenu => Intl.message(
        'お気に入り管理',
        name: 'favoriteManagementMenu',
      );

  String get followManagementMenu => Intl.message(
        'フォロー管理',
        name: 'followManagementMenu',
      );

  String get helpMenu => Intl.message(
        'ヘルプ',
        name: 'helpMenu',
      );

  String get logoutMenu => Intl.message(
        'ログアウト',
        name: 'logoutMenu',
      );

  String get commentHint => Intl.message(
        'としてコメントを追加',
        name: 'commentHint',
      );

  String get labelShowMore => Intl.message(
        'もっと見る',
        name: 'labelShowMore',
      );

  String get labelLike => Intl.message(
        'いいね',
        name: 'labelLike',
      );

  String get labelReplyButton => Intl.message(
        '返信する',
        name: 'labelReplyButton',
      );

  String get titleProfile => Intl.message(
        'マイページ',
        name: 'titleProfile',
      );

  String get titleForgotPass => Intl.message(
        'パスワードを忘れた',
        name: 'titleForgotPass',
      );

  String get emailHint => Intl.message(
        'メールアドレスを入力してください',
        name: 'emailHint',
      );

  String get labelSendButton => Intl.message(
        '送信',
        name: 'labelSendButton',
      );

  String get titlePurchasePolicy => Intl.message(
        '規約',
        name: 'titlePurchasePolicy',
      );

  String get contentPurchasePolicy => Intl.message(
        '「購入したコンテンツの利用方法について」\n'
        '購入したコンテンツは、編集などを行いFreeコンテンツとして公開することができます。有料コンテンツとしての公開はできません。また、有料コンテンツを作成する場合、本アプリで購入したコンテンツの AR・Background・effectのいずれかが含まれている場合有料公開はできません。\n\n'
        '「表示価格について」\n'
        '当アプリの表示価格につきましては、それぞれの掲載者が価格の設定、及び価格の変更をしており、当アプリがそれらの設定を行っているものではありません。価格などの設定についてのお問い合わせは、該当する掲載者にお問い合わせください。\n\n'
        '「Discountについて」\n'
        '表示されている「Discount」についきましては、それぞれの掲載者がそのDiscount率と期間を設定しており、当アプリがそれらの設定などを行っているものではありません。\n'
        'Discountについてのお問い合わせは、該当する掲載者にお問い合わせください。\n\n'
        '「まとめ買いDiscountについて」\n'
        'まとめ買いDiscountは10％（対象外を除く）となっていますが、その対象商品の設定は掲載者が設定しており、当アプリが対象商品の設定を行っているものではありません。「まとめ買いDiscount」対象商品の詳細は該当する商品の掲載者にお問い合わせください。',
        name: 'contentPurchasePolicy',
      );

  String get labelAgreeButton => Intl.message(
        '同意する',
        name: 'labelAgreeButton',
      );

  String get loginTitle => Intl.message(
        'ログイン',
        name: 'loginTitle',
      );

  String get mainTitle => Intl.message(
        'Home',
        name: 'mainTitle',
      );

  String get userNameHint => Intl.message(
        'ユーザーネームをご入力ください',
        name: 'userNameHint',
      );

  String get passWordHint => Intl.message(
        'パスワードをご入力ください',
        name: 'passWordHint',
      );

  String get loginWithGoogle => Intl.message(
        'メールでログイン',
        name: 'loginWithGoogle',
      );

  String get orLogin => Intl.message(
        'または',
        name: 'orLogin',
      );

  String get loginButtonText => Intl.message(
        'ログイン',
        name: 'loginButtonText',
      );

  String get noAccountText => Intl.message(
        'アカウントお持ちではない方',
        name: 'noAccountText',
      );

  String get forgotPassword => Intl.message(
        'パスワードを忘れた方',
        name: 'forgotPassword',
      );

  String get shopLabelButton => Intl.message(
        'Shop',
        name: 'shopLabelButton',
      );

  String get moneyLabelButton => Intl.message(
        'Money',
        name: 'moneyLabelButton',
      );

  String get musicLabelButton => Intl.message(
        'Music',
        name: 'musicLabelButton',
      );

  String get shareLabelButton => Intl.message(
        'Share',
        name: 'shareLabelButton',
      );

  String get forYouLabel => Intl.message(
        'おすすめ',
        name: 'forYouLabel',
      );

  String get followingLabel => Intl.message(
        'フォロー中',
        name: 'followingLabel',
      );

  String get titleResetPassword => Intl.message(
        'パスワード変更',
        name: 'titleResetPassword',
      );

  String get labelCurrentPassword => Intl.message(
        '現在パスワード',
        name: 'labelCurrentPassword',
      );

  String get labelNewPassword => Intl.message(
        '新しいパスワード',
        name: 'labelNewPassword',
      );

  String get labelConfirmPassword => Intl.message(
        '新しいパスワードの確認',
        name: 'labelConfirmPassword',
      );

  String get textSubmitButton => Intl.message(
        '確認',
        name: 'textSubmitButton',
      );

  String get textValidPassword => Intl.message(
        '英数含む8~20文字',
        name: 'textValidPassword',
      );

  String get textShareWithFriend => Intl.message(
        '送信先',
        name: 'textShareWithFriend',
      );

  String get textShareNetWork => Intl.message(
        'シェア',
        name: 'textShareNetWork',
      );

  String get textReport => Intl.message(
        '報告する',
        name: 'textReport',
      );

  String get textHeart => Intl.message(
        '興味ありません',
        name: 'textHeart',
      );

  String get textDownload => Intl.message(
        'ダウンロードする',
        name: 'textDownload',
      );

  String get textContinue => Intl.message(
        '壁紙に設定する',
        name: 'textContinue',
      );

  String get textHeaderRegisterComplete => Intl.message(
        '新規登録',
        name: 'textHeaderRegisterComplete',
      );

  String get textH1RegisterComplete => Intl.message(
        '登録が完了しました',
        name: 'textH1RegisterComplete',
      );

  String get textTitleRegisterComplete => Intl.message(
        '登録メールへ認証メールを送信しました。\nご確認ください。',
        name: 'textTitleRegisterComplete',
      );

  String get textButtonRegisterComplete => Intl.message(
        'ログインへ',
        name: 'textButtonRegisterComplete',
      );

  String get labelFreeTab => Intl.message(
        'FREE',
        name: 'labelFreeTab',
      );

  String get labelPaidTab => Intl.message(
        'PAID',
        name: 'labelPaidTab',
      );

  String get labelSelectPhotoMenu => Intl.message(
        'ギャラリーから写真を選択',
        name: 'labelSelectPhotoMenu',
      );

  String get labelTakePhotoMenu => Intl.message(
        '新しい写真を撮る',
        name: 'labelTakePhotoMenu',
      );

  String get labelDeletePhotoMenu => Intl.message(
        '写真を削除する',
        name: 'labelDeletePhotoMenu',
      );

  String get labelFavorite => Intl.message(
        'お気に入り',
        name: 'labelFavorite',
      );

  String get labelSearchVideos => Intl.message(
        '動画を検索',
        name: 'labelSearchVideos',
      );

  String get labelLift => Intl.message(
        '解除',
        name: 'labelLift',
      );

  String get textLink => Intl.message(
        'リンクをコピー',
        name: 'textLink',
      );

  String get logoutConfirmMessage => Intl.message(
        'ログアウトでしょうか',
        name: 'logoutConfirmMessage',
      );

  String get labelUnfollowButton => Intl.message(
        '登録済み',
        name: 'labelUnfollowButton',
      );

  String get labelFollowButton => Intl.message(
        'フォロー',
        name: 'labelFollowButton',
      );

  String get unfollowConfirmMessage => Intl.message(
        'のフォローを解除しますか？',
        name: 'unfollowConfirmMessage',
      );

  String get labelCancelButton => Intl.message(
        'キャンセル',
        name: 'labelCancelButton',
      );

  String get labelUnfollowAccept => Intl.message(
        'フォローをやめる',
        name: 'labelUnfollowAccept',
      );

  String get defaultConfirmMessage => Intl.message(
        'メッセージ内容を記載する',
        name: 'defaultConfirmMessage',
      );

  String get labelOkButton => Intl.message(
        'OK',
        name: 'labelOkButton',
      );

  String get followManagementText => Intl.message(
        'フォロー管理',
        name: 'followManagementText',
      );

  String get followerText => Intl.message(
        'フォロワー',
        name: 'followerText',
      );

  String get labelSearchUser => Intl.message(
        'ユーザーを検索',
        name: 'labelSearchUser',
      );

  String get labelSearch => Intl.message(
        'ユーザー名、動画を検索',
        name: 'labelSearch',
      );

  String get titleUnfollow => Intl.message(
        'を解除しますか？',
        name: 'titleUnfollow',
      );

  String get myARText => Intl.message(
        '私のAR',
        name: 'myARText',
      );

  String get recommendBackgroundText => Intl.message(
        'おすすめの背景',
        name: 'recommendBackgroundText',
      );

  String get myEffectText => Intl.message(
        '私のエフェクト',
        name: 'myEffectText',
      );

  String get titleSignupChoice => Intl.message(
        'WelCome',
        name: 'titleSignupChoice',
      );

  String get labelAppleSignup => Intl.message(
        'Appleで登録',
        name: 'labelAppleSignup',
      );

  String get labelFacebookSignup => Intl.message(
        'Facebookで登録',
        name: 'labelFacebookSignup',
      );

  String get labelGoogleSignup => Intl.message(
        'Googleで登録',
        name: 'labelGoogleSignup',
      );

  String get labelEmailSignup => Intl.message(
        'メールで登録',
        name: 'labelEmailSignup',
      );

  String get emptyBlockedListLabel =>
      Intl.message('ブロックしているユーザーがいません。', name: 'emptyBlockedListLabel');

  String get titleAddPassword => Intl.message(
        'パスワード作成',
        name: 'titleAddPassword',
      );

  String get hintEnterPass => Intl.message(
        'パスワードを入力',
        name: 'hintEnterPass',
      );

  String get hintEnterConfirmPass => Intl.message(
        '再度パスワードを入力',
        name: 'hintEnterConfirmPass',
      );

  String get labelNext => Intl.message(
        '次へ',
        name: 'labelNext',
      );

  String get titleAddEmail => Intl.message(
        'アカウント登録',
        name: 'titleAddEmail',
      );

  String get hintEnterEmail => Intl.message(
        'メールアドレスを入力',
        name: 'hintEnterEmail',
      );

  String get textCancelSignUpEmail => Intl.message(
        'すでにアカウントを持っている方',
        name: 'textCancelSignUpEmail',
      );

  String get registerAnotherEmailLabel =>
      Intl.message('別のメールアドレスで登録。', name: 'registerAnotherEmailLabel');

  String get registerAccountLabel =>
      Intl.message('アカウント登録。', name: 'registerAccountLabel');

  String get emailWasSendLabel =>
      Intl.message('登録メールアドレスへ認証メールを送信しました。\nOTPコードをご確認ください。',
          name: 'emailWasSendLabel');

  String get resendLabel => Intl.message('コードを再送信', name: 'resendLabel');

  String get userNameEmptyLabel => Intl.message(
        'ユーザ名を入力してください',
        name: 'userNameEmptyLabel',
      );

  String get passwordEmptyLabel => Intl.message(
        'パスワードをご入力ください',
        name: 'passwordEmptyLabel',
      );

  String get paymentWarningText => Intl.message(
        'カード情報の取得ができません。'
        '再度ご確認ください。',
        name: 'paymentWarningText',
      );

  String get paymentMethodLabel => Intl.message(
        'お支払い方法追加',
        name: 'paymentMethodLabel',
      );

  String get paymentUserNameHint => Intl.message(
        'クレジットカード名義人',
        name: 'paymentUserNameHint',
      );

  String get datePaymentHint => Intl.message(
        '有効期限',
        name: 'datePaymentHint',
      );

  String get cVVHint => Intl.message(
        'CVV',
        name: 'cVVHint',
      );

  String get numberPaymentHint =>
      Intl.message('カード番号', name: 'numberPaymentHint');

  String get titleDialog => Intl.message(
        'エラー',
        name: 'titleDialog',
      );

  String get cCVToolTripContent => Intl.message(
        '※CVVとは、クレジットカード裏面の署名欄に印字されている数字のうち下3桁または4桁の番号です。',
        name: 'cCVToolTripContent',
      );

  String get titleLink => Intl.message(
        'リンク',
        name: 'titleLink',
      );

  String get titleFacebook => Intl.message(
        'Facebook',
        name: 'titleFacebook',
      );

  String get titleLine => Intl.message(
        'Line',
        name: 'titleLine',
      );

  String get titleMessenger => Intl.message(
        'Messenger',
        name: 'titleMessenger',
      );

  String get titleTwitter => Intl.message(
        'Twitter',
        name: 'titleTwitter',
      );

  String get titleReport => Intl.message(
        '通報',
        name: 'titleReport',
      );

  String get titleBlock => Intl.message(
        'ブロック',
        name: 'titleBlock',
      );

  String get dropdownPaymentDelete => Intl.message(
        '削除',
        name: 'dropdownPaymentDelete',
      );

  String get dropdownPaymentApply => Intl.message(
        '切り替える',
        name: 'dropdownPaymentApply',
      );

  String get paymentSuccess => Intl.message(
        '支払いに成功しました。',
        name: 'paymentSuccess',
      );

  String get paymentFailed => Intl.message(
        'お支払いに失敗しました。',
        name: 'paymentFailed',
      );

  String get addCreditCard => Intl.message(
        'クレジットカードを追加',
        name: 'addCreditCard',
      );

  String get editInfoMenu => Intl.message(
        '個人情報',
        name: 'editInfoMenu',
      );

  String get displayName => Intl.message(
        '表示名（※必須）',
        name: 'displayName',
      );

  String get displayUserName => Intl.message(
        'ユーザーネーム（※必須）',
        name: 'displayUserName',
      );

  String get userPhone => Intl.message(
        '電話番号（※任意）',
        name: 'userPhone',
      );

  String get userNationality => Intl.message(
        '国籍（※任意）',
        name: 'userNationality',
      );

  String get userGender => Intl.message(
        '性別 (※任意)',
        name: 'userGender',
      );

  String get genderMale => Intl.message(
        '男',
        name: 'genderMale',
      );

  String get genderFemale => Intl.message(
        '女',
        name: 'genderFemale',
      );

  String get noAnswer => Intl.message(
        '回答なし',
        name: 'noAnswer',
      );

  String get dayOfBirth => Intl.message(
        '生年月日（※必須）',
        name: 'dayOfBirth',
      );

  String get year => Intl.message(
        '年',
        name: 'year',
      );

  String get day => Intl.message(
        '日',
        name: 'day',
      );

  String get month => Intl.message(
        '月',
        name: 'month',
      );

  String get shootNowLabel => Intl.message(
        '新規撮影',
        name: 'shootNowLabel',
      );

  String get clientLabel => Intl.message(
        'クライアント',
        name: 'clientLabel',
      );

  String get selectFromFileLabel => Intl.message(
        'ファイルから選択',
        name: 'selectFromFileLabel',
      );

  String get editFromYourLiking => Intl.message(
        'My Material から作成',
        name: 'editFromYourLiking',
      );

  String get editInfo => Intl.message(
        'プロフィール編集',
        name: 'editInfo',
      );

  String get skip => Intl.message(
        'スキップ',
        name: 'skip',
      );

  String get hintTiktok => Intl.message(
        'Tiktok',
        name: 'hintTiktok',
      );

  String get hintTwitter => Intl.message(
        'Twitter',
        name: 'hintTwitter',
      );

  String get hintInstagram => Intl.message(
        'Instagram',
        name: 'hintInstagram',
      );

  String get hintFacebook => Intl.message(
        'Facebook',
        name: 'hintFacebook',
      );

  String get wrongUrlFormat => Intl.message(
        '間違ったURL形式',
        name: 'wrongUrlFormat',
      );

  String get labelNotification => Intl.message(
        '通知',
        name: 'labelNotification',
      );

  String get textArProgressing => Intl.message(
        'ARを作成しています。映像の長さなどによって時間が掛かることががあります。'
        '完成すると通知が届きます。完成'
        'したARは、My material ARに保存されます。',
        name: 'textArProgressing',
      );

  String get back => Intl.message(
        '戻る',
        name: 'back',
      );

  String get displayNameEmptyLabel => Intl.message(
        '表示名をご入力ください。',
        name: 'displayNameEmptyLabel',
      );

  String get phoneNumberHint => Intl.message(
        '電話番号は8桁以上13桁以下です。',
        name: 'phoneNumberHint',
      );

  String get phoneNumberEmptyLabel => Intl.message(
        '電話番号をご入力ください。',
        name: 'phoneNumberEmptyLabel',
      );

  String get confirmPasswordErrorText => Intl.message(
        '再度パスコードが一致しません。',
        name: 'confirmPasswordErrorText',
      );

  String get wellComeText =>
      Intl.message('Welcome to Diastration', name: 'wellComeText');

  String get registerCompleterHint => Intl.message(
        'Answer a few questions, and Diastration will help you '
        'better in finding approriate contents',
        name: 'registerCompleterHint',
      );

  String get startButtonHint => Intl.message('開始', name: 'startButtonHint');

  String get userNameEmptyErrorText =>
      Intl.message('ユーザーネームをご入力ください。', name: 'userNameEmptyErrorText');

  String get userNameLabel =>
      Intl.message('ユーザーネーム（※必須）', name: 'userNameLabel');

  String get videoSettingsTitle =>
      Intl.message('動画設定', name: 'videoSettingsTitle');

  String get requiredTitleHint =>
      Intl.message('タイトル（※必須）', name: 'requiredTitleHint');

  String get requiredContentDescriptionHint =>
      Intl.message('コンテンツ説明（※必須）', name: 'requiredContentDescriptionHint');

  String get releaseLabel => Intl.message('公開', name: 'releaseLabel');

  String get paidSettingLabel => Intl.message('有料設定', name: 'paidSettingLabel');

  String get emptyRequiredFieldMessage =>
      Intl.message('This field is required', name: 'emptyRequiredFieldMessage');

  String get authenticationErrorText =>
      Intl.message('ユーザーネームまたはパスワードが正しくありません', name: 'authenticationErrorText');

  String get labelTimer => Intl.message(
        'タイマー',
        name: 'labelTimer',
      );

  String get forgotOTPTitle => Intl.message('OTP入力', name: 'forgotOTPTitle');

  String get checkOTPMessage => Intl.message(
      'メールアドレスへ認証メールを送信しました。'
      '\nOTPコードをご確認ください',
      name: 'checkOTPMessage');

  String get resendOTPText => Intl.message('コードを再送信', name: 'resendOTPText');

  String get countOTPMessage1 => Intl.message('OTPが', name: 'countOTPMessage1');

  String get countOTPMessage2 =>
      Intl.message('秒まで有効です。', name: 'countOTPMessage2');

  String get labelBringUpMenu => Intl.message(
        '前に移動',
        name: 'labelBringUpMenu',
      );

  String get labelPushDownMenu => Intl.message(
        '後ろに移動',
        name: 'labelPushDownMenu',
      );

  String get salePeriod => Intl.message('販売期間', name: 'salePeriod');

  String get discount => Intl.message('割引', name: 'discount');

  String get scopeAR => Intl.message('ARの公開範囲', name: 'scopeAR');

  String get mention => Intl.message('メンション', name: 'mention');

  String get anyone => Intl.message('誰でも', name: 'anyone');

  String get followersOnly => Intl.message('フォロワーのみ', name: 'followersOnly');

  String get onlyMe => Intl.message('自分のみ', name: 'onlyMe');

  String get titleVideoSettingRequired =>
      Intl.message('タイトルをご入力ください', name: 'titleVideoSettingRequired');

  String get descriptionVideoSettingRequired =>
      Intl.message('コンテンツ説明をご入力ください', name: "descriptionVideoSettingRequired");

  String get alphaError => Intl.message('英字の大文字と小文字', name: 'alphaError');

  String get renewPasswordTitle =>
      Intl.message('新しいパスワード', name: 'renewPasswordTitle');

  String get renewPasswordHint =>
      Intl.message('新しいのパスワードを入力', name: 'renewPasswordHint');

  String get numberNonWordError =>
      Intl.message('最低１文字以上の数字か特殊', name: 'numberNonWordError');

  String get lengthError => Intl.message('8文字以上16文字以内', name: 'lengthError');

  String get passwordRules =>
      Intl.message('※必須条件\n・8文字以上16文字以内\n・英字の大文字と小文字\n・最低１文字以上の数字か特殊',
          name: 'passwordRules');

  String get price => Intl.message('値段', name: "price");

  String get incorrectConfirmPass =>
      Intl.message('パスワードが一致いたしません', name: 'incorrectConfirmPass');

  String get invalidUserNameLength =>
      Intl.message('ユーザーネームは8文字以上20文字以下をご入力ください',
          name: 'invalidUserNameLength');

  String get invalidUserNameSpace =>
      Intl.message('ユーザーネームは空白を抜いてご入力ください', name: 'invalidUserNameSpace');

  String get passwordError =>
      Intl.message('パスワードの条件を満たしていません', name: 'passwordError');

  String get passwordConfirmError =>
      Intl.message('パスワードが一致しません', name: 'passwordConfirmError');

  String get myARString => Intl.message('MyAR', name: 'myARString');

  String get myCollectionBackground =>
      Intl.message('背景', name: 'myCollectionBackground');

  String get discountRate => Intl.message('割引率', name: 'discountRate');

  String get invalidDiscountPercent =>
      Intl.message('割引率が不適です', name: "invalidDiscountPercent");

  String get updateSuccessful =>
      Intl.message('情報を更新しました。', name: "updateSuccessful");

  String get imageCapacityTooBig =>
      Intl.message('画像の容量が大きすぎています', name: 'imageCapacityTooBig');

  String get textUserName => Intl.message(
        'ユーザーネームまたはメールアドレス',
        name: 'textUserName',
      );

  String get selfIntroduceTextHint => Intl.message(
        '自分について',
        name: 'selfIntroduceTextHint',
      );

  String get glamorous => Intl.message('Glamorous', name: 'glamorous');

  String get people => Intl.message('人', name: 'people');

  String get numPeople => Intl.message('人数（人）', name: 'numPeople');

  String get buyDiscount => Intl.message('まとめ買いDiscount', name: 'buyDiscount');

  String get peopleCanPurchased =>
      Intl.message('購入可能人数の設定', name: 'peopleCanPurchased');

  String get titleMode => Intl.message(
        'Mode選択',
        name: 'titleMode',
      );

  String get loading => Intl.message("Loading...", name: 'loading');

  String get editProfile => Intl.message("メールアドレス：", name: 'editProfile');

  String get titleDialogConfirm =>
      Intl.message("入力した情報を保存しますか", name: 'titleDialogConfirm');

  String get labelOkButtonJP => Intl.message("いいよ！", name: 'labelOkButtonJP');

  String get createVideoLabel => Intl.message("動画作成", name: 'createVideoLabel');

  String get successTitle => Intl.message("成功", name: 'successTitle');

  String get videoTitle => Intl.message("VIDEO", name: 'videoTitle');

  String get userTitle => Intl.message("USER", name: 'userTitle');

  String get hashTagTitle => Intl.message("HASH TAG", name: 'hashTagTitle');

  String get more => Intl.message("MORE", name: 'more');

  String get labelShare => Intl.message("Share", name: 'labelShare');

  String get labelAddToCart => Intl.message("カートに入れる", name: 'labelAddToCart');

  String get labelBuyNow => Intl.message("今すぐ買う", name: 'labelBuyNow');

  String get labelOtherContent =>
      Intl.message("他のコンテンツを確認する", name: 'labelOtherContent');

  String get labelBackToOrigin =>
      Intl.message("元に戻る", name: 'labelBackToOrigin');

  String get labelMaterial => Intl.message("Material", name: 'labelMaterial');
  String get textMaterial => Intl.message("Material", name: 'textMaterial');
  String get textSeeMore => Intl.message("もっとみる", name: 'textSeeMore');
  String get second => Intl.message("秒", name: 'second');

  String get off => Intl.message("OFF", name: 'off');

  String get labelComplete =>
      Intl.message("Completeに保存", name: 'labelComplete');

  String get labelMyMaterials =>
      Intl.message("My Materialsに保存", name: 'labelMyMaterials');

  String get labelBackToEdit =>
      Intl.message("編集ページに戻る", name: 'labelBackToEdit');

  String get titleBlockUser =>
      Intl.message("をブロックしますか。", name: 'titleBlockUser');

  String get buttonDelete => Intl.message("削除", name: 'buttonDelete');

  String get myMaterialText =>
      Intl.message("My Materials", name: 'myMaterialText');
  String get unlockLabel =>
      Intl.message("Press to unlock this content", name: 'unlockLabel');

  String get delete => Intl.message("削除", name: 'delete');

  String get titleShoppingCart =>
      Intl.message("カート一覧", name: 'titleShoppingCart');
  String get messageDeleteCartConfirmation =>
      Intl.message("このコンテンツはカートから削除しますか",
          name: 'messageDeleteCartConfirmation');

  String get labelSelectedCounter =>
      Intl.message("合計：", name: 'labelSelectedCounter');

  String get labelSelectedAll => Intl.message("全部", name: 'labelSelectedAll');

  String get labelConfirm => Intl.message("購入手続き", name: 'labelConfirm');

  String get labelGotoSetting =>
      Intl.message("動画設定へ", name: 'labelGotoSetting');

  String get labelVideoCaption =>
      Intl.message("Enter a title", name: 'labelVideoCaption');

  String get labelSNS => Intl.message("SNS", name: 'labelSNS');

  String get labelPassword => Intl.message("********", name: 'labelPassword');

  String get labelConfirmPurchase1 =>
      Intl.message("「購入を確定する」を押してご購入していただくことで、お客様は当アプリの",
          name: "labelConfirmPurchase1");

  String get labelConfirmPurchase2 =>
      Intl.message("の各種規約・プライバシー規約", name: "labelConfirmPurchase2");

  String get labelConfirmPurchase3 =>
      Intl.message("および当アプリの販売条件に同意の上、商品をご購入されたことになります。",
          name: "labelConfirmPurchase3");

  String get labelConfirmPurchase4 =>
      Intl.message("購入したコンテンツの利用方法、", name: "labelConfirmPurchase4");

  String get labelConfirmPurchase5 =>
      Intl.message("価格については必ず商品ページおよび", name: "labelConfirmPurchase5");

  String get labelConfirmPurchase6 =>
      Intl.message("こちら", name: "labelConfirmPurchase6");

  String get labelConfirmPurchase7 =>
      Intl.message("をご確認ください。", name: "labelConfirmPurchase7");

  String get labelPurchaseContent =>
      Intl.message("購入したコンテンツは", name: "labelPurchaseContent");

  String get labelPurchaseMyCollection =>
      Intl.message("My Materials", name: "labelPurchaseMyCollection");

  String get labelPurchaseMyAR =>
      Intl.message("My AR", name: "labelPurchaseMyAR");

  String get labelPurchaseMyBackground =>
      Intl.message("My Background", name: "labelPurchaseMyBackground");

  String get labelPurchaseMyEffect =>
      Intl.message("My effectに保存されます。", name: "labelPurchaseMyEffect");

  String get labelButtonConfirmPurchase =>
      Intl.message("購入を確定する", name: "labelButtonConfirmPurchase");

  String get labelTitleConditionPurchase =>
      Intl.message("カート規約", name: "labelTitleConditionPurchase");

  String get confirmSeparateBackgroundText =>
      Intl.message("この動画の背景を抜き出しましょうか。", name: "confirmSeparateBackgroundText");

  String get labelOther => Intl.message("未設定", name: "labelOther");

  String get labelNoFollowing =>
      Intl.message("フォロー中のユーザーがいません。", name: "labelNoFollowing");
  String get labelNoFollower =>
      Intl.message("フォロワーがいません。", name: "labelNoFollower");
  String get titleOtherContent =>
      Intl.message("他のコンテンツ", name: 'titleOtherContent');
  String get labelButtonAddToCart =>
      Intl.message("カートに入れ", name: 'labelButtonAddToCart');

  String get labelEmptyNotification =>
      Intl.message("発表はありません。", name: "labelEmptyNotification");

  String get labelReselect => Intl.message("再選択", name: 'labelReselect');

  String get labelRotateMenu =>
      Intl.message("右へ回転90度", name: 'labelRotateMenu');

  String get labelPackageContent =>
      Intl.message("Package Content", name: "labelPackageContent");
  String get labelMaterialContent =>
      Intl.message("Material Content", name: "labelMaterialContent");
  String get labelSecondaryUseOfARMaterial =>
      Intl.message("PackageのAR Material二次使用",
          name: "labelSecondaryUseOfARMaterial");
  String get labelPublishContent =>
      Intl.message("コンテンツを公開する ", name: "labelPublishContent");

  String get labelHashtag => Intl.message("# Hashtag", name: "labelHashtag");

  String get followDone =>
      Intl.message("Subscribe successfully", name: "followDone");

  String get inValidPrice => Intl.message("入力値段が不適です", name: "inValidPrice");

  String get inValidNumPeople =>
      Intl.message("人数が不適です", name: "inValidNumPeople");

  String get toPurchaseLabel => Intl.message("投稿へ", name: "toPurchaseLabel");

  String get myDraftVideo =>
      Intl.message("My Draft Video", name: 'myDraftVideo');

  String get labelEdit => Intl.message("編集へ", name: 'labelEdit');

  String get btnShoppingCart => Intl.message("買い物", name: 'btnShoppingCart');

  String get waitLoadingMessage =>
      Intl.message("loading.. wait...", name: 'waitLoadingMessage');

  String get txtEmptyContent =>
      Intl.message("買い物がありません。", name: 'txtEmptyContent');

  String get loadingFirstLaunchLabel =>
      Intl.message("Loading...\n Please wait a few minutes",
          name: 'loadingFirstLaunchLabel');

  String get loading_text => Intl.message("...", name: 'loading_text');

  String get lostNetWorkLabel => Intl.message(
      "No network connection. \n Connect to the internet and try again.",
      name: 'lostNetWorkLabel');

  String get labelCanNotEdit =>
      Intl.message("編集できません。コンテンツのマテリアルを取得できません", name: 'labelCanNotEdit');

  String get limitSizeTitle => Intl.message("制限サイズ", name: 'limitSizeTitle');

  String get limitSizeContent =>
      Intl.message("最大サイズは", name: 'limitSizeContent');

  String get labelConfirmVideoSetting =>
      Intl.message("投稿を公開する", name: 'labelConfirmVideoSetting');

  String get labelDefaultDelete =>
      Intl.message("削除しますか？", name: 'labelDefaultDelete');

  String get originalPriceLabel =>
      Intl.message("Original Price", name: 'originalPriceLabel');

  String get discountLabel =>
      Intl.message("Discount(%)", name: 'discountLabel');

  String get salePriceLabel =>
      Intl.message("Sale Price", name: 'salePriceLabel');

  String get successSignUpMessage =>
      Intl.message("アカウント情報を登録しました。", name: 'successSignUpMessage');

  String get doneLabel => Intl.message("完了", name: 'doneLabel');
  String get emptyLabel => Intl.message("Empty Video", name: 'emptyLabel');

  String get txtEmptyVideo =>
      Intl.message("コンテンツがありません。", name: 'txtEmptyVideo');

  String get dialogBlockUser =>
      Intl.message("このユーザー情報は表示されません。", name: 'dialogBlockUser');

  String get postText => Intl.message("投稿", name: 'postText');

  String get officialLabel => Intl.message("公式", name: 'officialLabel');

  String get recommendSetting =>
      Intl.message("Recommendの設定", name: 'recommendSetting');

  String get commentHintText =>
      Intl.message("コメントを入力してください", name: 'commentHintText');
  String get cancel => Intl.message("キャンセル", name: "cancel");
  String get save => Intl.message("変更", name: "save");
  String get updateBio => Intl.message("自己紹介変更", name: "updateBio");
  String get enterBio => Intl.message("自分について紹介してください。", name: "enterBio");
  String get labelMaterialDelete =>
      Intl.message("このMaterialを消除しますか？", name: "labelMaterialDelete");

  String get labelConfirmDelete =>
      Intl.message("はい", name: "labelConfirmDelete");

  String get labelCancelDelete =>
      Intl.message("やめる", name: "labelCancelDelete");

  String get deleteConfirmTitle => Intl.message("「お気に入り」から消除しますか？", name: "deleteConfirmTitle");

  String get titleGenreCategory => Intl.message("Recommendに表示したい関連ジャンルを指定してください\n複数選択できます"
  , name: 'titleGenreCategory');

  String get titleScreenGenre => Intl.message("動画ジャンル"
      , name: 'titleScreenGenre');

  String get menuGenreDrawer => Intl.message("観たい動画ジャンル選択"
      , name: 'menuGenreDrawer');

}
