import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(AuthGate());
  } catch (e) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF111018),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Yug Adda চালু হতে সমস্যা হয়েছে',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return snap.data == null ? const AuthPage() : const MainPage();
    },
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool login = true;
  bool busy = false;

  @override
  void dispose() {
    name.dispose(); email.dispose(); password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final auth = FirebaseAuth.instance;
      if (login) {
        await auth.signInWithEmailAndPassword(email: email.text.trim(), password: password.text);
      } else {
        final result = await auth.createUserWithEmailAndPassword(email: email.text.trim(), password: password.text);
        await result.user?.updateDisplayName(name.text.trim());
        await FirebaseFirestore.instance.collection('users').doc(result.user!.uid).set({
          'name': name.text.trim(), 'email': email.text.trim(), 'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Form(
        key: formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Icon(Icons.forum_rounded, size: 76, color: Color(0xFFB58AFF)),
          const SizedBox(height: 12),
          const Text('Yug Adda', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          if (!login) ...[
            TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Full name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null),
            const SizedBox(height: 12),
          ],
          TextFormField(controller: email, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null),
          const SizedBox(height: 12),
          TextFormField(controller: password, obscureText: true,
            decoration: const InputDecoration(labelText: 'Password (6+ characters)'),
            validator: (v) => (v == null || v.length < 6) ? 'Use at least 6 characters' : null),
          const SizedBox(height: 18),
          FilledButton(onPressed: busy ? null : submit, child: Text(busy ? 'Please wait...' : (login ? 'Login' : 'Create account'))),
          TextButton(onPressed: busy ? null : () => setState(() => login = !login),
            child: Text(login ? 'Create new account' : 'Already have an account? Login')),
        ]),
      )),
    ))),
  );
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selected = 0;
  final pages = const [DashboardTab(), FeedTab(), EventsTab(), LocationTab(), ChatTab(), ProfileTab(), SettingsTab()];
  final labels = const ['Dashboard', 'Feed', 'Events', 'Location', 'Chat', 'Profile', 'Settings'];
  final icons = const [Icons.dashboard, Icons.dynamic_feed, Icons.event, Icons.location_on, Icons.chat, Icons.person, Icons.settings];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(labels[selected]), actions: [
      IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage())),
        icon: const Icon(Icons.notifications_outlined)),
    ]),
    drawer: Drawer(child: SafeArea(child: Column(children: [
      DrawerHeader(
  child: Center(
    child: Image.asset(
      'yug_adda_logo.png.jpg',
      width: 180,
      fit: BoxFit.contain,
    ),
  ),
),
      for (int i = 0; i < labels.length; i++)
        ListTile(leading: Icon(icons[i]), title: Text(labels[i]), selected: selected == i,
          onTap: () { setState(() => selected = i); Navigator.pop(context); }),
      const Spacer(),
      ListTile(leading: const Icon(Icons.logout), title: const Text('Logout'),
        onTap: () async { Navigator.pop(context); await FirebaseAuth.instance.signOut(); }),
    ]))),
    body: pages[selected],
    bottomNavigationBar: NavigationBar(
      selectedIndex: selected < 5 ? selected : 0,
      onDestinationSelected: (i) => setState(() => selected = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.dynamic_feed), label: 'Feed'),
        NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
        NavigationDestination(icon: Icon(Icons.location_on), label: 'Location'),
        NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
      ],
    ),
  );
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return ListView(padding: const EdgeInsets.all(18), children: [
      Text('Hello, ${user?.displayName ?? 'Yug Adda member'} 👋', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Your community space, all in one place.'),
      const SizedBox(height: 20),
      for (final item in ['Share updates in Feed', 'Create events and countdowns', 'Share your current location', 'Chat with community members'])
        Card(child: ListTile(leading: const Icon(Icons.check_circle_outline), title: Text(item))),
    ]);
  }
}

class FeedTab extends StatefulWidget {
  const FeedTab({super.key});
  @override
  State<FeedTab> createState() => _FeedTabState();
}
class _FeedTabState extends State<FeedTab> {
  final controller = TextEditingController();
  bool busy = false;
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  Future<void> post() async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    setState(() => busy = true);
    try {
      final u = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('posts').add({
        'text': text, 'uid': u.uid, 'name': u.displayName ?? u.email ?? 'Member',
        'createdAt': FieldValue.serverTimestamp(),
      });
      controller.clear();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(padding: const EdgeInsets.all(12), child: Row(children: [
      Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Share a mood or update...'))),
      IconButton.filled(onPressed: busy ? null : post, icon: const Icon(Icons.send)),
    ])),
    Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('posts').orderBy('createdAt', descending: true).limit(50).snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return const Center(child: Text('Feed error. Check Firestore rules.'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        if (snap.data!.docs.isEmpty) return const Center(child: Text('No posts yet. Be the first!'));
        return ListView(children: snap.data!.docs.map((doc) {
          final d = doc.data();
          return Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(d['name']?.toString() ?? 'Member'), subtitle: Text(d['text']?.toString() ?? ''),
            trailing: d['uid'] == FirebaseAuth.instance.currentUser?.uid
              ? IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => doc.reference.delete()) : null));
        }).toList());
      },
    )),
  ]);
}

class EventsTab extends StatelessWidget {
  const EventsTab({super.key});
  Future<void> addEvent(BuildContext context) async {
    final title = TextEditingController();
    DateTime date = DateTime.now().add(const Duration(days: 1));
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, setD) => AlertDialog(
      title: const Text('New event'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Event title')),
        const SizedBox(height: 12),
        TextButton.icon(icon: const Icon(Icons.calendar_month), label: Text(date.toLocal().toString().substring(0, 16)),
          onPressed: () async {
            final picked = await showDatePicker(context: ctx, initialDate: date, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)));
            if (picked != null) setD(() => date = DateTime(picked.year, picked.month, picked.day, date.hour, date.minute));
          }),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save'))],
    )));
    if (ok == true && title.text.trim().isNotEmpty) {
      final u = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('events').add({
        'title': title.text.trim(), 'date': Timestamp.fromDate(date), 'uid': u.uid,
      });
    }
    title.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton.extended(onPressed: () => addEvent(context), icon: const Icon(Icons.add), label: const Text('Add event')),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('events').orderBy('date').snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return const Center(child: Text('Events error. Check Firestore rules.'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        if (snap.data!.docs.isEmpty) return const Center(child: Text('No events added yet.'));
        return ListView(children: snap.data!.docs.map((doc) {
          final d = doc.data(); final timestamp = d['date'] as Timestamp?;
          return Card(child: ListTile(leading: const Icon(Icons.event), title: Text(d['title']?.toString() ?? 'Event'),
            subtitle: Text(timestamp?.toDate().toLocal().toString() ?? ''),
            trailing: d['uid'] == FirebaseAuth.instance.currentUser?.uid
              ? IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => doc.reference.delete()) : null));
        }).toList());
      },
    ),
  );
}

class LocationTab extends StatefulWidget {
  const LocationTab({super.key});
  @override
  State<LocationTab> createState() => _LocationTabState();
}
class _LocationTabState extends State<LocationTab> {
  String status = 'Location is not shared.';
  bool busy = false;
  Future<void> share() async {
    setState(() => busy = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) throw Exception('Turn on GPS/location services.');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) throw Exception('Location permission denied.');
      final p = await Geolocator.getCurrentPosition();
      final u = FirebaseAuth.instance.currentUser!;
      await FirebaseFirestore.instance.collection('shared_locations').doc(u.uid).set({
        'uid': u.uid, 'name': u.displayName ?? u.email ?? 'Member',
        'latitude': p.latitude, 'longitude': p.longitude, 'updatedAt': FieldValue.serverTimestamp(), 'sharing': true,
      });
      setState(() => status = 'Location saved: ${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}');
    } catch (e) { setState(() => status = '$e'); }
    finally { if (mounted) setState(() => busy = false); }
  }
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(
    mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.location_on, size: 70, color: Color(0xFFB58AFF)),
      const SizedBox(height: 14), const Text('Share current location', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12), Text(status, textAlign: TextAlign.center),
      const SizedBox(height: 18), FilledButton.icon(onPressed: busy ? null : share, icon: const Icon(Icons.my_location), label: Text(busy ? 'Please wait...' : 'Share location')),
      const SizedBox(height: 12), const Text('This starter saves one location update while the app is open. Live/background tracking and group map are not included yet.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.white60)),
    ],
  )));
}

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});
  @override
  State<ChatTab> createState() => _ChatTabState();
}
class _ChatTabState extends State<ChatTab> {
  final controller = TextEditingController();
  Future<void> send() async {
    final text = controller.text.trim(); if (text.isEmpty) return;
    final u = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('community_messages').add({
      'text': text, 'uid': u.uid, 'name': u.displayName ?? u.email ?? 'Member', 'createdAt': FieldValue.serverTimestamp(),
    });
    controller.clear();
  }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Column(children: [
    Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('community_messages').orderBy('createdAt').limit(100).snapshots(),
      builder: (context, snap) {
        if (snap.hasError) return const Center(child: Text('Chat error. Check Firestore rules.'));
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        return ListView(children: snap.data!.docs.map((doc) {
          final d = doc.data(); return ListTile(title: Text(d['name']?.toString() ?? 'Member'), subtitle: Text(d['text']?.toString() ?? ''));
        }).toList());
      },
    )),
    SafeArea(top: false, child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [
      Expanded(child: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Message community...'))),
      IconButton.filled(onPressed: send, icon: const Icon(Icons.send)),
    ]))),
  ]);
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}
class _ProfileTabState extends State<ProfileTab> {
  final name = TextEditingController(); final bio = TextEditingController(); bool loaded = false; bool saving = false;
  @override
  void dispose() { name.dispose(); bio.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser!;
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance.collection('users').doc(u.uid).get(),
      builder: (context, snap) {
        if (!loaded && snap.hasData) { final d = snap.data!.data() ?? {}; name.text = d['name']?.toString() ?? u.displayName ?? ''; bio.text = d['bio']?.toString() ?? ''; loaded = true; }
        return ListView(padding: const EdgeInsets.all(18), children: [
          const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 42)),
          const SizedBox(height: 12), Text(u.email ?? '', textAlign: TextAlign.center),
          const SizedBox(height: 20), TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12), TextField(controller: bio, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'About me')),
          const SizedBox(height: 16), FilledButton(onPressed: saving ? null : () async {
            setState(() => saving = true);
            try {
              await u.updateDisplayName(name.text.trim());
              await FirebaseFirestore.instance.collection('users').doc(u.uid).set({'name': name.text.trim(), 'bio': bio.text.trim(), 'email': u.email, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
            } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'))); }
            finally { if (mounted) setState(() => saving = false); }
          }, child: Text(saving ? 'Saving...' : 'Save profile')),
        ]);
      },
    );
  }
}

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const ListTile(leading: Icon(Icons.language), title: Text('Language'), subtitle: Text('Bengali / English / Hindi full localization is a later step.')),
    FilledButton.tonalIcon(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout), label: const Text('Logout')),
  ]);
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Notifications')),
    body: const Center(child: Text('Push notifications will be connected in a later step.')));
}
