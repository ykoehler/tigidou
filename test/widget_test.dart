import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tigidou/models/todo_model.dart';
import 'package:tigidou/providers/todo_provider.dart';
import 'package:tigidou/l10n/app_localizations.dart';
import 'package:tigidou/screens/home_screen.dart';

class MockTodoProvider extends ChangeNotifier implements TodoProvider {
  Stream<List<Todo>> _todosStream = Stream.value([]);
  String? lastAddedTitle;
  DateTime? lastAddedDate;

  void setTodos(List<Todo> todos) {
    _todosStream = Stream.value(todos);
    notifyListeners();
  }

  @override
  Stream<List<Todo>> get todos => _todosStream;

  @override
  List<Todo> get allTodos => [];

  @override
  List<String> get availableTags => [];

  @override
  List<Todo> get availablePeople => [];

  @override
  List<String> get activeCategories => [];

  @override
  List<String> get activeTypes => [];

  @override
  List<String> get activeTags => [];

  @override
  Map<String, List<Todo>> get groupedTodos => {};

  @override
  Future<String> addTodo(String title, DateTime? dueDate) async {
    lastAddedTitle = title;
    lastAddedDate = dueDate;
    return 'new_id';
  }

  @override
  Future<void> deleteTodo(String id) async {}

  @override
  Future<void> toggleTodoStatus(Todo todo) async {}

  @override
  Future<void> updateTodo(Todo todo) async {}
}

void main() {
  testWidgets('HomeScreen displays todos and FAB', (WidgetTester tester) async {
    final mockTodoProvider = MockTodoProvider();

    mockTodoProvider.setTodos([
      Todo(id: '1', title: 'Buy milk', isCompleted: false, userId: 'user1'),
      Todo(id: '2', title: 'Walk dog', isCompleted: false, userId: 'user1'),
    ]);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<TodoProvider>.value(value: mockTodoProvider),
          ],
          child: Scaffold(
            appBar: AppBar(
              title: Image.asset(
                'assets/images/logo_banner.png',
                height: 32,
                fit: BoxFit.contain,
              ),
              centerTitle: false,
            ),
            body: const HomeScreen(),
          ),
        ),
      ),
    );

    // Wait for the stream to emit
    await tester.pumpAndSettle();

    // Verify that the logo is present in the AppBar.
    expect(find.byType(Image), findsWidgets);

    // Verify that todos are displayed.
    expect(find.text('Buy milk', findRichText: true), findsOneWidget);
    expect(find.text('Walk dog', findRichText: true), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget); // Search bar
  });

  testWidgets('Search bar filters todos', (WidgetTester tester) async {
    final mockTodoProvider = MockTodoProvider();

    // Mock initial data
    mockTodoProvider.setTodos([
      Todo(id: '1', title: 'Buy milk', isCompleted: false, userId: 'user1'),
      Todo(id: '2', title: 'Walk dog', isCompleted: false, userId: 'user1'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<TodoProvider>.value(value: mockTodoProvider),
          ],
          child: Scaffold(
            appBar: AppBar(
              title: Image.asset(
                'assets/images/logo_banner.png',
                height: 32,
                fit: BoxFit.contain,
              ),
              centerTitle: false,
            ),
            body: const HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Buy milk', findRichText: true), findsOneWidget);
    expect(find.text('Walk dog', findRichText: true), findsOneWidget);

    // Enter text
    await tester.enterText(find.byType(TextField), 'milk');
    await tester.pumpAndSettle(); // Wait for rebuild

    // Verify filtering
    expect(find.text('Buy milk', findRichText: true), findsOneWidget);
    expect(find.text('Walk dog', findRichText: true), findsNothing);
  });

  testWidgets('Search bar adds todo on submit', (WidgetTester tester) async {
    final mockTodoProvider = MockTodoProvider();

    mockTodoProvider.setTodos([]);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<TodoProvider>.value(value: mockTodoProvider),
          ],
          child: Scaffold(
            appBar: AppBar(
              title: Image.asset(
                'assets/images/logo_banner.png',
                height: 32,
                fit: BoxFit.contain,
              ),
              centerTitle: false,
            ),
            body: const HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    // Enter text and submit
    await tester.enterText(find.byType(TextField), 'New Task');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    // Verify addTodo called
    expect(mockTodoProvider.lastAddedTitle, 'New Task');

    // Verify text cleared (requires pump and state update)
    expect(find.text('New Task'), findsNothing);
  });

  testWidgets('Live preview shows draft todo', (WidgetTester tester) async {
    final mockTodoProvider = MockTodoProvider();

    mockTodoProvider.setTodos([]);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<TodoProvider>.value(value: mockTodoProvider),
          ],
          child: Scaffold(
            appBar: AppBar(
              title: Image.asset(
                'assets/images/logo_banner.png',
                height: 32,
                fit: BoxFit.contain,
              ),
              centerTitle: false,
            ),
            body: const HomeScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    // Enter text that doesn't match anything
    await tester.enterText(find.byType(TextField), 'Call @mom');
    await tester.pumpAndSettle();

    // Verify "New Todo Preview" header
    expect(find.text('New Todo Preview'), findsOneWidget);

    // Verify draft todo is displayed
    // In search mode, the Card with key 'draft' contains the preview
    expect(find.byKey(const ValueKey('draft')), findsOneWidget);
    expect(find.text('Call @mom', findRichText: true), findsWidgets);

    // Verify it's read-only (delete button shouldn't be there)
    expect(find.byIcon(Icons.delete), findsNothing);
  });
}
