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
  String get loginToAddWishlist => _t({'it':'Accedi per aggiungere alla lista "Da leggere"','en':'Login to add to reading list','fr':'Connectez-vous pour ajouter à la liste','es':'Inicia sesión para agregar a la lista','de':'Anmelden um zur Leseliste hinzuzufügen','pt':'Entre para adicionar à lista','ru':'Войдите, чтобы добавить в список','ar':'سجل الدخول للإضافة إلى القائمة','zh':'登录以添加到阅读列表','ja':'ログインしてリストに追加'});
  String get addedToWishlist => _t({'it':'Aggiunto a "Da leggere" 🔖','en':'Added to reading list 🔖','fr':'Ajouté à la liste 🔖','es':'Añadido a la lista 🔖','de':'Zur Leseliste hinzugefügt 🔖','pt':'Adicionado à lista 🔖','ru':'Добавлено в список 🔖','ar':'أضيف إلى القائمة 🔖','zh':'已添加到阅读列表 🔖','ja':'リストに追加しました 🔖'});
  String get removedFromWishlist => _t({'it':'Rimosso dalla lista "Da leggere"','en':'Removed from reading list','fr':'Retiré de la liste','es':'Eliminado de la lista','de':'Von der Leseliste entfernt','pt':'Removido da lista','ru':'Удалено из списка','ar':'تمت الإزالة من القائمة','zh':'已从阅读列表移除','ja':'リストから削除しました'});
  String get addedToListQuestion => _t({'it':'Aggiunto alla lista?','en':'Added to list?','fr':'Ajouté à la liste?','es':'¿Añadido a la lista?','de':'Zur Liste hinzugefügt?','pt':'Adicionado à lista?','ru':'Добавлено в список?','ar':'أضيف إلى القائمة؟','zh':'已添加到列表？','ja':'リストに追加しましたか？'});
  String get yesAdd => _t({'it':'Sì, aggiungi','en':'Yes, add','fr':'Oui, ajouter','es':'Sí, agregar','de':'Ja, hinzufügen','pt':'Sim, adicionar','ru':'Да, добавить','ar':'نعم، أضف','zh':'是，添加','ja':'はい、追加'});

  // ── Azioni ────────────────────────────────────────────────────────────────
  String get delete => _t({'it':'Elimina','en':'Delete','fr':'Supprimer','es':'Eliminar','de':'Löschen','pt':'Excluir','ru':'Удалить','ar':'حذف','zh':'删除','ja':'削除'});
  String get send => _t({'it':'Invia','en':'Send','fr':'Envoyer','es':'Enviar','de':'Senden','pt':'Enviar','ru':'Отправить','ar':'إرسال','zh':'发送','ja':'送信'});
  String get buy => _t({'it':'Acquista','en':'Buy','fr':'Acheter','es':'Comprar','de':'Kaufen','pt':'Comprar','ru':'Купить','ar':'شراء','zh':'购买','ja':'購入'});
  String get enlarge => _t({'it':'Ingrandisci','en':'Enlarge','fr':'Agrandir','es':'Ampliar','de':'Vergrößern','pt':'Ampliar','ru':'Увеличить','ar':'تكبير','zh':'放大','ja':'拡大'});
  String get preview => _t({'it':'Anteprima','en':'Preview','fr':'Aperçu','es':'Vista previa','de':'Vorschau','pt':'Pré-visualizar','ru':'Предпросмотр','ar':'معاينة','zh':'预览','ja':'プレビュー'});

  // ── Screen titles ─────────────────────────────────────────────────────────
  String get appInfo => _t({'it':'Info App','en':'App Info','fr':'Info App','es':'Info de la App','de':'App-Info','pt':'Info do App','ru':'О приложении','ar':'معلومات التطبيق','zh':'应用信息','ja':'アプリ情報'});
  String get addBookManually => _t({'it':'Aggiungi Libro Manualmente','en':'Add Book Manually','fr':'Ajouter un livre manuellement','es':'Añadir libro manualmente','de':'Buch manuell hinzufügen','pt':'Adicionar livro manualmente','ru':'Добавить книгу вручную','ar':'إضافة كتاب يدويًا','zh':'手动添加书籍','ja':'手動で本を追加'});
  String get bookInfoSection => _t({'it':'Informazioni Libro','en':'Book Information','fr':'Informations livre','es':'Información del libro','de':'Buchinformationen','pt':'Informações do livro','ru':'Информация о книге','ar':'معلومات الكتاب','zh':'书籍信息','ja':'本の情報'});
  String get editorialData => _t({'it':'Dati Editoriali (opzionali)','en':'Editorial Data (optional)','fr':'Données éditoriales (optionnel)','es':'Datos editoriales (opcional)','de':'Verlagsdaten (optional)','pt':'Dados editoriais (opcional)','ru':'Данные издательства (необ.)','ar':'بيانات النشر (اختياري)','zh':'出版数据（可选）','ja':'出版データ（任意）'});
  String get coverOptional => _t({'it':'Copertina (opzionale)','en':'Cover (optional)','fr':'Couverture (optionnel)','es':'Portada (opcional)','de':'Cover (optional)','pt':'Capa (opcional)','ru':'Обложка (необ.)','ar':'الغلاف (اختياري)','zh':'封面（可选）','ja':'カバー（任意）'});
  String get visitorStats => _t({'it':'Statistiche visitatori','en':'Visitor Statistics','fr':'Statistiques visiteurs','es':'Estadísticas de visitantes','de':'Besucherstatistiken','pt':'Estatísticas de visitantes','ru':'Статистика посетителей','ar':'إحصائيات الزوار','zh':'访客统计','ja':'訪問者統計'});
  String get registeredUsers => _t({'it':'Utenti registrati','en':'Registered users','fr':'Utilisateurs inscrits','es':'Usuarios registrados','de':'Registrierte Benutzer','pt':'Usuários registrados','ru':'Зарегистрированные пользователи','ar':'المستخدمون المسجلون','zh':'注册用户','ja':'登録ユーザー'});
  String get guest => _t({'it':'Ospite','en':'Guest','fr':'Invité','es':'Invitado','de':'Gast','pt':'Visitante','ru':'Гость','ar':'ضيف','zh':'访客','ja':'ゲスト'});
  String get loginOrRegister => _t({'it':'Accedi / Registrati','en':'Login / Register','fr':'Connexion / Inscription','es':'Acceder / Registrarse','de':'Anmelden / Registrieren','pt':'Entrar / Registrar','ru':'Войти / Регистрация','ar':'تسجيل الدخول / التسجيل','zh':'登录 / 注册','ja':'ログイン / 登録'});
  String get reviewScreen => _t({'it':'Recensione','en':'Review','fr':'Avis','es':'Reseña','de':'Bewertung','pt':'Resenha','ru':'Рецензия','ar':'مراجعة','zh':'评论','ja':'レビュー'});

  // ── About ─────────────────────────────────────────────────────────────────
  String get reportBug => _t({'it':'Segnala un Bug','en':'Report a Bug','fr':'Signaler un bug','es':'Reportar un bug','de':'Bug melden','pt':'Reportar bug','ru':'Сообщить об ошибке','ar':'الإبلاغ عن خطأ','zh':'报告错误','ja':'バグを報告'});
  String get suggestImprovement => _t({'it':'Suggerisci un miglioramento','en':'Suggest an improvement','fr':'Suggérer une amélioration','es':'Sugerir una mejora','de':'Verbesserung vorschlagen','pt':'Sugerir melhoria','ru':'Предложить улучшение','ar':'اقتراح تحسين','zh':'建议改进','ja':'改善を提案'});

  // ── My Reviews ────────────────────────────────────────────────────────────
  String get deleteReview => _t({'it':'Elimina Recensione','en':'Delete Review','fr':'Supprimer l\'avis','es':'Eliminar reseña','de':'Bewertung löschen','pt':'Excluir resenha','ru':'Удалить рецензию','ar':'حذف المراجعة','zh':'删除评论','ja':'レビューを削除'});
  String get deleteReviewConfirmMsg => _t({'it':'Sei sicuro di voler eliminare questa recensione?','en':'Are you sure you want to delete this review?','fr':'Voulez-vous vraiment supprimer cet avis?','es':'¿Estás seguro de que quieres eliminar esta reseña?','de':'Möchten Sie diese Bewertung wirklich löschen?','pt':'Tem certeza que deseja excluir esta resenha?','ru':'Вы уверены, что хотите удалить эту рецензию?','ar':'هل أنت متأكد من حذف هذه المراجعة؟','zh':'您确定要删除此评论吗？','ja':'このレビューを削除してもよろしいですか？'});
  String get deleteError => _t({'it':'Errore durante l\'eliminazione','en':'Error during deletion','fr':'Erreur lors de la suppression','es':'Error al eliminar','de':'Fehler beim Löschen','pt':'Erro ao excluir','ru':'Ошибка при удалении','ar':'خطأ أثناء الحذف','zh':'删除时出错','ja':'削除中にエラー'});
  String get allBooks => _t({'it':'Tutti i libri','en':'All books','fr':'Tous les livres','es':'Todos los libros','de':'Alle Bücher','pt':'Todos os livros','ru':'Все книги','ar':'جميع الكتب','zh':'所有书籍','ja':'すべての本'});
  String get byAuthor => _t({'it':'Per Autore','en':'By Author','fr':'Par auteur','es':'Por autor','de':'Nach Autor','pt':'Por autor','ru':'По автору','ar':'حسب المؤلف','zh':'按作者','ja':'著者別'});
  String get byGenre => _t({'it':'Per Genere / Tipo','en':'By Genre / Type','fr':'Par genre / type','es':'Por género / tipo','de':'Nach Genre / Typ','pt':'Por gênero / tipo','ru':'По жанру / типу','ar':'حسب النوع / الفئة','zh':'按类型','ja':'ジャンル別'});
  String get noReviewsYet => _t({'it':'Non hai ancora recensito nessun libro','en':'You haven\'t reviewed any book yet','fr':'Vous n\'avez pas encore écrit d\'avis','es':'Aún no has reseñado ningún libro','de':'Noch keine Bewertungen','pt':'Você ainda não avaliou nenhum livro','ru':'Вы ещё не написали ни одной рецензии','ar':'لم تراجع أي كتاب بعد','zh':'您还没有评论任何书籍','ja':'まだレビューを書いていません'});
  String get noResults => _t({'it':'Nessun risultato','en':'No results','fr':'Aucun résultat','es':'Sin resultados','de':'Keine Ergebnisse','pt':'Nenhum resultado','ru':'Нет результатов','ar':'لا توجد نتائج','zh':'没有结果','ja':'結果なし'});

  // ── Community / Forum ─────────────────────────────────────────────────────
  String get noReviewsInCommunity => _t({'it':'Nessuna recensione ancora','en':'No reviews yet','fr':'Pas encore d\'avis','es':'Ninguna reseña todavía','de':'Noch keine Bewertungen','pt':'Nenhuma resenha ainda','ru':'Рецензий пока нет','ar':'لا توجد مراجعات بعد','zh':'暂无评论','ja':'まだレビューがありません'});
  String get communityNotConfigured => _t({'it':'Community non configurata','en':'Community not configured','fr':'Communauté non configurée','es':'Comunidad no configurada','de':'Community nicht konfiguriert','pt':'Comunidade não configurada','ru':'Сообщество не настроено','ar':'المجتمع غير مهيأ','zh':'社区未配置','ja':'コミュニティが未設定'});
  String get deleteFromCommunity => _t({'it':'Elimina dalla Community','en':'Delete from Community','fr':'Supprimer de la communauté','es':'Eliminar de la comunidad','de':'Aus Community löschen','pt':'Excluir da comunidade','ru':'Удалить из сообщества','ar':'حذف من المجتمع','zh':'从社区删除','ja':'コミュニティから削除'});
  String get readOn => _t({'it':'Letto il','en':'Read on','fr':'Lu le','es':'Leído el','de':'Gelesen am','pt':'Lido em','ru':'Прочитано','ar':'قرأته في','zh':'读于','ja':'読んだ日'});
  String get newThread => _t({'it':'Nuovo thread','en':'New thread','fr':'Nouveau sujet','es':'Nuevo hilo','de':'Neues Thema','pt':'Novo tópico','ru':'Новая тема','ar':'موضوع جديد','zh':'新话题','ja':'新しいスレッド'});
  String get noThreadsYet => _t({'it':'Nessun thread ancora','en':'No threads yet','fr':'Pas encore de sujets','es':'Sin hilos todavía','de':'Noch keine Themen','pt':'Nenhum tópico ainda','ru':'Тем пока нет','ar':'لا توجد مواضيع بعد','zh':'暂无话题','ja':'まだスレッドがありません'});
  String get firstToDiscuss => _t({'it':'Sii il primo a iniziare una discussione!','en':'Be the first to start a discussion!','fr':'Soyez le premier à démarrer une discussion!','es':'¡Sé el primero en iniciar una discusión!','de':'Sei der Erste, der eine Diskussion beginnt!','pt':'Seja o primeiro a iniciar uma discussão!','ru':'Будьте первым, кто начнёт обсуждение!','ar':'كن أول من يبدأ نقاشًا!','zh':'成为第一个发起讨论的人！','ja':'最初にディスカッションを始めよう！'});
  String get createFirstThread => _t({'it':'Crea il primo thread','en':'Create the first thread','fr':'Créer le premier sujet','es':'Crear el primer hilo','de':'Ersten Thread erstellen','pt':'Criar o primeiro tópico','ru':'Создать первую тему','ar':'إنشاء أول موضوع','zh':'创建第一个话题','ja':'最初のスレッドを作成'});
  String get deleteReply => _t({'it':'Elimina risposta','en':'Delete reply','fr':'Supprimer la réponse','es':'Eliminar respuesta','de':'Antwort löschen','pt':'Excluir resposta','ru':'Удалить ответ','ar':'حذف الرد','zh':'删除回复','ja':'返信を削除'});
  String get confirmDeleteReply => _t({'it':'Vuoi eliminare questa risposta?','en':'Do you want to delete this reply?','fr':'Voulez-vous supprimer cette réponse?','es':'¿Quieres eliminar esta respuesta?','de':'Möchten Sie diese Antwort löschen?','pt':'Deseja excluir esta resposta?','ru':'Хотите удалить этот ответ?','ar':'هل تريد حذف هذا الرد؟','zh':'要删除此回复吗？','ja':'この返信を削除しますか？'});
  String get deleteThread => _t({'it':'Elimina thread','en':'Delete thread','fr':'Supprimer le sujet','es':'Eliminar hilo','de':'Thread löschen','pt':'Excluir tópico','ru':'Удалить тему','ar':'حذف الموضوع','zh':'删除话题','ja':'スレッドを削除'});
  String get sendError => _t({'it':'Errore nell\'invio della risposta','en':'Error sending reply','fr':'Erreur lors de l\'envoi','es':'Error al enviar la respuesta','de':'Fehler beim Senden','pt':'Erro ao enviar resposta','ru':'Ошибка при отправке ответа','ar':'خطأ في إرسال الرد','zh':'发送回复时出错','ja':'返信の送信中にエラー'});
  String get noRegistrationsInPeriod => _t({'it':'Nessuna iscrizione nel periodo','en':'No registrations in period','fr':'Aucune inscription dans la période','es':'Sin registros en el período','de':'Keine Registrierungen im Zeitraum','pt':'Nenhum registro no período','ru':'Регистраций нет за период','ar':'لا توجد تسجيلات في الفترة','zh':'该期间无注册','ja':'期間内に登録なし'});
}
