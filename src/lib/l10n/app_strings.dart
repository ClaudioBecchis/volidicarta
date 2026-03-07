import 'package:flutter/widgets.dart';

class S {
  final String _lang;
  const S._(this._lang);

  static S of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return S._(locale.languageCode);
  }

  String _t(Map<String, String> map) =>
      map[_lang] ?? map['en'] ?? map.values.first;

  // ── Navigazione ───────────────────────────────────────────────────────────
  String get home => _t({'it':'Home','en':'Home','fr':'Accueil','es':'Inicio','de':'Start','pt':'Início','ru':'Главная','ar':'الرئيسية','zh':'主页','ja':'ホーム'});
  String get search => _t({'it':'Cerca','en':'Search','fr':'Recherche','es':'Buscar','de':'Suche','pt':'Pesquisa','ru':'Поиск','ar':'بحث','zh':'搜索','ja':'検索'});
  String get myReviews => _t({'it':'Recensioni','en':'Reviews','fr':'Avis','es':'Reseñas','de':'Bewertungen','pt':'Resenhas','ru':'Рецензии','ar':'المراجعات','zh':'评论','ja':'レビュー'});
  String get stats => _t({'it':'Statistiche','en':'Statistics','fr':'Statistiques','es':'Estadísticas','de':'Statistiken','pt':'Estatísticas','ru':'Статистика','ar':'الإحصائيات','zh':'统计','ja':'統計'});
  String get community => _t({'it':'Community','en':'Community','fr':'Communauté','es':'Comunidad','de':'Gemeinschaft','pt':'Comunidade','ru':'Сообщество','ar':'المجتمع','zh':'社区','ja':'コミュニティ'});

  // ── Autenticazione ────────────────────────────────────────────────────────
  String get login => _t({'it':'Accedi','en':'Login','fr':'Connexion','es':'Iniciar sesión','de':'Anmelden','pt':'Entrar','ru':'Войти','ar':'تسجيل الدخول','zh':'登录','ja':'ログイン'});
  String get register => _t({'it':'Registrati','en':'Register','fr':'S\'inscrire','es':'Registrarse','de':'Registrieren','pt':'Registrar','ru':'Регистрация','ar':'تسجيل','zh':'注册','ja':'登録'});
  String get logout => _t({'it':'Disconnetti','en':'Logout','fr':'Déconnexion','es':'Cerrar sesión','de':'Abmelden','pt':'Sair','ru':'Выйти','ar':'تسجيل الخروج','zh':'退出','ja':'ログアウト'});
  String get email => _t({'it':'Email','en':'Email','fr':'E-mail','es':'Correo electrónico','de':'E-Mail','pt':'E-mail','ru':'Эл. почта','ar':'البريد الإلكتروني','zh':'电子邮件','ja':'メール'});
  String get password => _t({'it':'Password','en':'Password','fr':'Mot de passe','es':'Contraseña','de':'Passwort','pt':'Senha','ru':'Пароль','ar':'كلمة المرور','zh':'密码','ja':'パスワード'});
  String get username => _t({'it':'Username','en':'Username','fr':'Nom d\'utilisateur','es':'Usuario','de':'Benutzername','pt':'Nome de usuário','ru':'Имя пользователя','ar':'اسم المستخدم','zh':'用户名','ja':'ユーザー名'});
  String get noAccount => _t({'it':'Non hai un account? Registrati','en':'No account? Register','fr':'Pas de compte? S\'inscrire','es':'¿Sin cuenta? Regístrate','de':'Kein Konto? Registrieren','pt':'Sem conta? Registrar','ru':'Нет аккаунта? Регистрация','ar':'لا حساب؟ سجل','zh':'没有账户？注册','ja':'アカウントがない？登録'});
  String get haveAccount => _t({'it':'Hai già un account? Accedi','en':'Have an account? Login','fr':'Déjà un compte? Connexion','es':'¿Ya tienes cuenta? Entrar','de':'Hast ein Konto? Anmelden','pt':'Já tem conta? Entrar','ru':'Есть аккаунт? Войти','ar':'لديك حساب؟ ادخل','zh':'有账户？登录','ja':'アカウントがある？ログイン'});

  // ── Azioni comuni ─────────────────────────────────────────────────────────
  String get save => _t({'it':'Salva','en':'Save','fr':'Enregistrer','es':'Guardar','de':'Speichern','pt':'Salvar','ru':'Сохранить','ar':'حفظ','zh':'保存','ja':'保存'});
  String get cancel => _t({'it':'Annulla','en':'Cancel','fr':'Annuler','es':'Cancelar','de':'Abbrechen','pt':'Cancelar','ru':'Отмена','ar':'إلغاء','zh':'取消','ja':'キャンセル'});
  String get close => _t({'it':'Chiudi','en':'Close','fr':'Fermer','es':'Cerrar','de':'Schließen','pt':'Fechar','ru':'Закрыть','ar':'إغلاق','zh':'关闭','ja':'閉じる'});
  String get confirm => _t({'it':'Conferma','en':'Confirm','fr':'Confirmer','es':'Confirmar','de':'Bestätigen','pt':'Confirmar','ru':'Подтвердить','ar':'تأكيد','zh':'确认','ja':'確認'});

  // ── Recensioni ────────────────────────────────────────────────────────────
  String get writeReview => _t({'it':'Scrivi Recensione','en':'Write Review','fr':'Écrire un avis','es':'Escribir reseña','de':'Bewertung schreiben','pt':'Escrever resenha','ru':'Написать рецензию','ar':'كتابة مراجعة','zh':'写评论','ja':'レビューを書く'});
  String get editReview => _t({'it':'Modifica Recensione','en':'Edit Review','fr':'Modifier l\'avis','es':'Editar reseña','de':'Bewertung bearbeiten','pt':'Editar resenha','ru':'Редактировать','ar':'تعديل المراجعة','zh':'编辑评论','ja':'レビューを編集'});
  String get saveReview => _t({'it':'Salva Recensione','en':'Save Review','fr':'Enregistrer l\'avis','es':'Guardar reseña','de':'Bewertung speichern','pt':'Salvar resenha','ru':'Сохранить рецензию','ar':'حفظ المراجعة','zh':'保存评论','ja':'レビューを保存'});
  String get updateReview => _t({'it':'Aggiorna Recensione','en':'Update Review','fr':'Mettre à jour','es':'Actualizar reseña','de':'Bewertung aktualisieren','pt':'Atualizar resenha','ru':'Обновить рецензию','ar':'تحديث المراجعة','zh':'更新评论','ja':'レビューを更新'});
  String get rating => _t({'it':'Valutazione','en':'Rating','fr':'Note','es':'Calificación','de':'Bewertung','pt':'Avaliação','ru':'Рейтинг','ar':'التقييم','zh':'评分','ja':'評価'});
  String get iReadThisBook => _t({'it':'Ho letto questo libro','en':'I read this book','fr':'J\'ai lu ce livre','es':'Leí este libro','de':'Ich las dieses Buch','pt':'Li este livro','ru':'Я прочитал эту книгу','ar':'قرأت هذا الكتاب','zh':'我读过这本书','ja':'この本を読んだ'});
  String get editReviewBtn => _t({'it':'Modifica recensione','en':'Edit review','fr':'Modifier l\'avis','es':'Editar reseña','de':'Bearbeiten','pt':'Editar','ru':'Редактировать','ar':'تعديل','zh':'编辑','ja':'編集'});

  // ── Dashboard ─────────────────────────────────────────────────────────────
  String get booksRead => _t({'it':'Libri letti','en':'Books read','fr':'Livres lus','es':'Libros leídos','de':'Gelesene Bücher','pt':'Livros lidos','ru':'Прочитано книг','ar':'كتب مقروءة','zh':'已读书籍','ja':'読んだ本'});
  String get avgRating => _t({'it':'Media voti','en':'Avg. rating','fr':'Note moyenne','es':'Calificación media','de':'Ø Bewertung','pt':'Média','ru':'Средний рейтинг','ar':'متوسط التقييم','zh':'平均评分','ja':'平均評価'});
  String get whatToDo => _t({'it':'Cosa vuoi fare?','en':'What do you want to do?','fr':'Que voulez-vous faire?','es':'¿Qué quieres hacer?','de':'Was möchten Sie tun?','pt':'O que deseja fazer?','ru':'Что вы хотите сделать?','ar':'ماذا تريد أن تفعل؟','zh':'你想做什么？','ja':'何をしますか？'});

  // ── Impostazioni ──────────────────────────────────────────────────────────
  String get settings => _t({'it':'Impostazioni','en':'Settings','fr':'Paramètres','es':'Configuración','de':'Einstellungen','pt':'Configurações','ru':'Настройки','ar':'الإعدادات','zh':'设置','ja':'設定'});
  String get theme => _t({'it':'Tema','en':'Theme','fr':'Thème','es':'Tema','de':'Thema','pt':'Tema','ru':'Тема','ar':'المظهر','zh':'主题','ja':'テーマ'});
  String get language => _t({'it':'Lingua','en':'Language','fr':'Langue','es':'Idioma','de':'Sprache','pt':'Idioma','ru':'Язык','ar':'اللغة','zh':'语言','ja':'言語'});
  String get themeLight => _t({'it':'Chiaro','en':'Light','fr':'Clair','es':'Claro','de':'Hell','pt':'Claro','ru':'Светлая','ar':'فاتح','zh':'浅色','ja':'ライト'});
  String get themeDark => _t({'it':'Scuro','en':'Dark','fr':'Sombre','es':'Oscuro','de':'Dunkel','pt':'Escuro','ru':'Тёмная','ar':'داكن','zh':'深色','ja':'ダーク'});
  String get themeSystem => _t({'it':'Sistema','en':'System','fr':'Système','es':'Sistema','de':'System','pt':'Sistema','ru':'Система','ar':'النظام','zh':'系统','ja':'システム'});

  // ── Statistiche ───────────────────────────────────────────────────────────
  String get reviewedBooks => _t({'it':'Libri Recensiti','en':'Reviewed Books','fr':'Livres notés','es':'Libros reseñados','de':'Bewertete Bücher','pt':'Livros avaliados','ru':'Рецензированных','ar':'كتب مراجعة','zh':'已评书籍','ja':'レビュー済み本'});
  String get ratingDistribution => _t({'it':'Distribuzione Voti','en':'Rating Distribution','fr':'Distribution des notes','es':'Distribución de calificaciones','de':'Bewertungsverteilung','pt':'Distribuição de avaliações','ru':'Распределение рейтингов','ar':'توزيع التقييمات','zh':'评分分布','ja':'評価分布'});

  // ── Ricerca ───────────────────────────────────────────────────────────────
  String get searchBooks => _t({'it':'Cerca libri...','en':'Search books...','fr':'Rechercher des livres...','es':'Buscar libros...','de':'Bücher suchen...','pt':'Pesquisar livros...','ru':'Поиск книг...','ar':'البحث عن كتب...','zh':'搜索书籍...','ja':'本を検索...'});
  String get italianOnly => _t({'it':'Solo libri in italiano','en':'Italian books only','fr':'Livres en italien uniquement','es':'Solo libros en italiano','de':'Nur Bücher auf Italienisch','pt':'Apenas livros em italiano','ru':'Только на итальянском','ar':'الكتب الإيطالية فقط','zh':'仅意大利语书籍','ja':'イタリア語の本のみ'});
}
