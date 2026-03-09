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
  String get avgRatingLabel => _t({'it':'Media Voti','en':'Avg. Rating','fr':'Note Moyenne','es':'Calificación Media','de':'Ø Bewertung','pt':'Média','ru':'Средний рейтинг','ar':'متوسط التقييم','zh':'平均评分','ja':'平均評価'});
  String get ratingDistribution => _t({'it':'Distribuzione Voti','en':'Rating Distribution','fr':'Distribution des notes','es':'Distribución de calificaciones','de':'Bewertungsverteilung','pt':'Distribuição de avaliações','ru':'Распределение рейтингов','ar':'توزيع التقييمات','zh':'评分分布','ja':'評価分布'});
  String get mostReadGenres => _t({'it':'Generi più letti','en':'Most Read Genres','fr':'Genres les plus lus','es':'Géneros más leídos','de':'Meistgelesene Genres','pt':'Géneros mais lidos','ru':'Самые читаемые жанры','ar':'الأجناس الأكثر قراءة','zh':'最常读类型','ja':'最も読んだジャンル'});
  String get booksByYear => _t({'it':'Libri per anno','en':'Books by Year','fr':'Livres par année','es':'Libros por año','de':'Bücher pro Jahr','pt':'Livros por ano','ru':'Книги по годам','ar':'الكتب حسب السنة','zh':'按年书籍','ja':'年別の本'});
  String get writeReviewsForStats => _t({'it':'Scrivi recensioni per vedere le statistiche','en':'Write reviews to see statistics','fr':'Écrivez des avis pour voir les statistiques','es':'Escribe reseñas para ver estadísticas','de':'Bewertungen schreiben um Statistiken zu sehen','pt':'Escreva resenhas para ver estatísticas','ru':'Напишите рецензии для просмотра статистики','ar':'اكتب مراجعات لرؤية الإحصائيات','zh':'写评论以查看统计数据','ja':'統計を見るにはレビューを書いてください'});

  // ── Ricerca ───────────────────────────────────────────────────────────────
  String get searchBooks => _t({'it':'Cerca libri...','en':'Search books...','fr':'Rechercher des livres...','es':'Buscar libros...','de':'Bücher suchen...','pt':'Pesquisar livros...','ru':'Поиск книг...','ar':'البحث عن كتب...','zh':'搜索书籍...','ja':'本を検索...'});
  String get italianOnly => _t({'it':'Solo libri in italiano','en':'Italian books only','fr':'Livres en italien uniquement','es':'Solo libros en italiano','de':'Nur Bücher auf Italienisch','pt':'Apenas livros em italiano','ru':'Только на итальянском','ar':'الكتب الإيطالية فقط','zh':'仅意大利语书籍','ja':'イタリア語の本のみ'});
  String get searchBookHint => _t({'it':'Titolo, autore, ISBN...','en':'Title, author, ISBN...','fr':'Titre, auteur, ISBN...','es':'Título, autor, ISBN...','de':'Titel, Autor, ISBN...','pt':'Título, autor, ISBN...','ru':'Название, автор, ISBN...','ar':'العنوان، المؤلف، الرقم الدولي...','zh':'书名、作者、ISBN...','ja':'タイトル、著者、ISBN...'});

  // ── Wishlist ──────────────────────────────────────────────────────────────
  String get toRead => _t({'it':'Da leggere','en':'To Read','fr':'À lire','es':'Por leer','de':'Zu lesen','pt':'Para ler','ru':'Читать','ar':'للقراءة','zh':'待读','ja':'読む予定'});
  String get addToWishlist => _t({'it':'Aggiungi a "Da leggere"','en':'Add to Reading List','fr':'Ajouter à lire','es':'Añadir a leer','de':'Zur Leseliste','pt':'Adicionar à lista','ru':'В список чтения','ar':'أضف للقراءة','zh':'加入阅读清单','ja':'読書リストに追加'});

  // ── Azioni home ───────────────────────────────────────────────────────────
  String get addReadBook => _t({'it':'Aggiungi Libro Letto','en':'Add Read Book','fr':'Ajouter un livre lu','es':'Añadir libro leído','de':'Gelesenes Buch hinzufügen','pt':'Adicionar livro lido','ru':'Добавить прочитанную книгу','ar':'أضف كتابًا مقروءًا','zh':'添加已读书籍','ja':'読んだ本を追加'});
  String get searchOnGoogle => _t({'it':'Cerca su Google Books','en':'Search on Google Books','fr':'Rechercher sur Google Books','es':'Buscar en Google Books','de':'Auf Google Books suchen','pt':'Pesquisar no Google Books','ru':'Искать в Google Books','ar':'البحث في Google Books','zh':'在Google图书搜索','ja':'Google Booksで検索'});
  String get lastRead => _t({'it':'Ultimi letti','en':'Last Read','fr':'Derniers lus','es':'Últimos leídos','de':'Zuletzt gelesen','pt':'Últimos lidos','ru':'Недавно прочитанные','ar':'آخر ما قرئ','zh':'最近阅读','ja':'最近読んだ本'});

  // ── My Reviews ────────────────────────────────────────────────────────────
  String get myReviewsFull => _t({'it':'Le Mie Recensioni','en':'My Reviews','fr':'Mes avis','es':'Mis reseñas','de':'Meine Bewertungen','pt':'Minhas resenhas','ru':'Мои рецензии','ar':'مراجعاتي','zh':'我的评论','ja':'マイレビュー'});
  String get groupBy => _t({'it':'Raggruppa per','en':'Group by','fr':'Grouper par','es':'Agrupar por','de':'Gruppieren nach','pt':'Agrupar por','ru':'Группировать по','ar':'تجميع حسب','zh':'分组','ja':'グループ化'});
  String get filterByStars => _t({'it':'Filtra per stelle','en':'Filter by stars','fr':'Filtrer par étoiles','es':'Filtrar por estrellas','de':'Nach Sternen filtern','pt':'Filtrar por estrelas','ru':'Фильтр по звёздам','ar':'تصفية بالنجوم','zh':'按星级筛选','ja':'星でフィルター'});
  String get addBook => _t({'it':'Aggiungi libro','en':'Add book','fr':'Ajouter un livre','es':'Añadir libro','de':'Buch hinzufügen','pt':'Adicionar livro','ru':'Добавить книгу','ar':'أضف كتابًا','zh':'添加书籍','ja':'本を追加'});

  // ── Community ─────────────────────────────────────────────────────────────
  String get sharedInCommunity => _t({'it':'Condividi nella Community','en':'Share in Community','fr':'Partager dans la communauté','es':'Compartir en la comunidad','de':'In Community teilen','pt':'Compartilhar na comunidade','ru':'Поделиться в сообществе','ar':'مشاركة في المجتمع','zh':'分享到社区','ja':'コミュニティで共有'});

  // ── Dettaglio libro ───────────────────────────────────────────────────────
  String get bookDetail => _t({'it':'Dettaglio Libro','en':'Book Detail','fr':'Détail du livre','es':'Detalle del libro','de':'Buchdetail','pt':'Detalhe do livro','ru':'Детали книги','ar':'تفاصيل الكتاب','zh':'书籍详情','ja':'本の詳細'});
  String get description => _t({'it':'Descrizione','en':'Description','fr':'Description','es':'Descripción','de':'Beschreibung','pt':'Descrição','ru':'Описание','ar':'الوصف','zh':'描述','ja':'説明'});
  String get myReviewCard => _t({'it':'La tua Recensione','en':'Your Review','fr':'Votre avis','es':'Tu reseña','de':'Deine Bewertung','pt':'Sua resenha','ru':'Ваша рецензия','ar':'مراجعتك','zh':'你的评论','ja':'あなたのレビュー'});
  String get deleteReviewConfirm => _t({'it':'Sei sicuro di voler eliminare questa recensione?','en':'Are you sure you want to delete this review?','fr':'Êtes-vous sûr de vouloir supprimer cet avis?','es':'¿Estás seguro de que quieres eliminar esta reseña?','de':'Möchten Sie diese Bewertung wirklich löschen?','pt':'Tem certeza de que deseja excluir esta resenha?','ru':'Вы уверены, что хотите удалить эту рецензию?','ar':'هل أنت متأكد من حذف هذه المراجعة؟','zh':'您确定要删除此评论吗？','ja':'このレビューを削除してもよろしいですか？'});
  String get writeYourReview => _t({'it':'Scrivi la tua recensione','en':'Write your review','fr':'Écrire votre avis','es':'Escribe tu reseña','de':'Bewertung schreiben','pt':'Escrever sua resenha','ru':'Написать рецензию','ar':'اكتب مراجعتك','zh':'写下您的评论','ja':'レビューを書く'});

  // ── Validazione / Errori ──────────────────────────────────────────────────
  String get endDateBeforeStart => _t({'it':'La data di fine non può essere prima dell\'inizio','en':'End date cannot be before start date','fr':'La date de fin ne peut pas être avant la date de début','es':'La fecha de fin no puede ser antes de la de inicio','de':'Enddatum kann nicht vor dem Startdatum liegen','pt':'A data de fim não pode ser antes da data de início','ru':'Дата окончания не может быть раньше даты начала','ar':'لا يمكن أن يكون تاريخ الانتهاء قبل تاريخ البدء','zh':'结束日期不能早于开始日期','ja':'終了日は開始日より前にできません'});
  String get sessionExpired => _t({'it':'Sessione scaduta. Rieffettua il login.','en':'Session expired. Please log in again.','fr':'Session expirée. Veuillez vous reconnecter.','es':'Sesión expirada. Vuelve a iniciar sesión.','de':'Sitzung abgelaufen. Bitte erneut anmelden.','pt':'Sessão expirada. Faça login novamente.','ru':'Сессия истекла. Войдите снова.','ar':'انتهت الجلسة. سجل دخولك مرة أخرى.','zh':'会话已过期。请重新登录。','ja':'セッションが期限切れです。再ログインしてください。'});

  // ── Generi / Selezione ────────────────────────────────────────────────────
  String get selectGenre => _t({'it':'Seleziona un genere','en':'Select a genre','fr':'Sélectionner un genre','es':'Seleccionar un género','de':'Genre auswählen','pt':'Selecionar um gênero','ru':'Выберите жанр','ar':'اختر النوع','zh':'选择类型','ja':'ジャンルを選択'});

  // ── Community ─────────────────────────────────────────────────────────────
  String get beFirstToShare => _t({'it':'Sii il primo a condividere!','en':'Be the first to share!','fr':'Soyez le premier à partager!','es':'¡Sé el primero en compartir!','de':'Sei der erste, der teilt!','pt':'Seja o primeiro a compartilhar!','ru':'Будьте первым, кто поделится!','ar':'كن أول من يشارك!','zh':'成为第一个分享的人！','ja':'最初に共有しましょう！'});

  // ── My Reviews ────────────────────────────────────────────────────────────
  String get allStars => _t({'it':'Tutte le stelle','en':'All stars','fr':'Toutes les étoiles','es':'Todas las estrellas','de':'Alle Sterne','pt':'Todas as estrelas','ru':'Все звёзды','ar':'جميع النجوم','zh':'所有星级','ja':'全ての星'});
  String get searchOrAddManually => _t({'it':'Cerca un libro o aggiungilo manualmente!','en':'Search a book or add it manually!','fr':'Recherchez un livre ou ajoutez-le manuellement!','es':'¡Busca un libro o añádelo manualmente!','de':'Suche ein Buch oder füge es manuell hinzu!','pt':'Pesquise um livro ou adicione-o manualmente!','ru':'Найдите книгу или добавьте вручную!','ar':'ابحث عن كتاب أو أضفه يدويًا!','zh':'搜索书籍或手动添加！','ja':'本を検索するか手動で追加してください！'});

  // ── Wishlist ──────────────────────────────────────────────────────────────
  String get yesRemove => _t({'it':'Sì, rimuovi','en':'Yes, remove','fr':'Oui, supprimer','es':'Sí, eliminar','de':'Ja, entfernen','pt':'Sim, remover','ru':'Да, удалить','ar':'نعم، احذف','zh':'是，删除','ja':'はい、削除'});
}
