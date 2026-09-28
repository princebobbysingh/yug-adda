import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
  
  
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(const YugAddaApp());

  } catch (e, stackTrace) {
    debugPrint('Firebase Error: $e');
    debugPrintStack(stackTrace: stackTrace);

    runApp(
      StartupErrorApp(error: e.toString()),
    );
  }
}

class StartupErrorApp extends StatelessWidget {
  final String error;
  const StartupErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 64),
                    const SizedBox(height: 20),
                    const Text(
                      'Yug Adda চালু হতে সমস্যা হয়েছে',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('Error details:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectableText(error, textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class YugAddaApp extends StatelessWidget {
  const YugAddaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yug Adda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF7F5FA),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

// Check Firebase login status
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const AuthScreen();
      },
    );
  }
}

// Login and Signup Screen
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await credential.user?.updateDisplayName(
          _nameController.text.trim(),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'এই ইমেইলে কোনো অ্যাকাউন্ট পাওয়া যায়নি।';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'ইমেইল অথবা পাসওয়ার্ড সঠিক নয়।';
          break;
        case 'email-already-in-use':
          message = 'এই ইমেইল দিয়ে আগে থেকেই অ্যাকাউন্ট আছে।';
          break;
        case 'weak-password':
          message = 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে।';
          break;
        case 'invalid-email':
          message = 'সঠিক ইমেইল ঠিকানা লিখুন।';
          break;
        case 'network-request-failed':
          message = 'ইন্টারনেট সংযোগ পরীক্ষা করুন।';
          break;
        default:
          message = e.message ?? 'একটি সমস্যা হয়েছে। আবার চেষ্টা করুন।';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
Widget build(BuildContext context) {
  return PopScope(
    canPop: selectedIndex == 0,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;

      if (selectedIndex != 0) {
        setState(() {
          selectedIndex = 0;
        });
      }
    },
    child: Scaffold(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.forum_rounded,
                  size: 85,
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 20),

                Text(
                  isLogin ? 'Welcome Back!' : 'Create Account',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  isLogin
                      ? 'Login to continue to Yug Adda'
                      : 'Join the Yug Adda community',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 32),

                if (!isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'আপনার নাম লিখুন';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'ইমেইল লিখুন';
                    }

                    if (!RegExp(
                      r'^[^@]+@[^@]+\.[^@]+$',
                    ).hasMatch(value.trim())) {
                      return 'সঠিক ইমেইল লিখুন';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'পাসওয়ার্ড লিখুন';
                    }

                    if (value.length < 6) {
                      return 'কমপক্ষে ৬ অক্ষরের পাসওয়ার্ড দিন';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            isLogin ? 'LOGIN' : 'SIGN UP',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLogin
                          ? "Don't have an account?"
                          : 'Already have an account?',
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLogin = !isLogin;
                        });
                      },
                      child: Text(
                        isLogin ? 'Sign Up' : 'Login',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Home Screen after successful authentication

  class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final Color primaryColor = Colors.deepPurple;

  final List<String> menuTitles = [
    'Dashboard',
    'Feed',
    'User Profile',
    'Chat / Messaging',
    'Notifications',
    'Settings',
  ];

  final List<IconData> menuIcons = [
    Icons.dashboard_rounded,
    Icons.dynamic_feed_rounded,
    Icons.person_rounded,
    Icons.chat_rounded,
    Icons.notifications_rounded,
    Icons.settings_rounded,
  ];

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Widget dashboardPage() {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Colors.deepPurple,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Yug Adda!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hello, ${user?.displayName ?? user?.email ?? 'User'}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect. Share. Stay Together.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              dashboardCard(
                Icons.dynamic_feed,
                'Feed',
                'View community posts',
                1,
              ),
              dashboardCard(
                Icons.person,
                'Profile',
                'Your account',
                2,
              ),
              dashboardCard(
                Icons.chat,
                'Messages',
                'Chat with friends',
                3,
              ),
              dashboardCard(
                Icons.notifications,
                'Notifications',
                'Stay updated',
                4,
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Community Feed',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.forum_outlined,
                    size: 55,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Welcome to Yug Adda Feed',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Community posts will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget dashboardCard(
    IconData icon,
    String title,
    String subtitle,
    int index,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 38, color: primaryColor),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionPage(
    IconData icon,
    String title,
    String description,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 85,
              color: primaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget selectedPage() {
    switch (selectedIndex) {
      case 0:
        return dashboardPage();

      case 1:
        return sectionPage(
          Icons.dynamic_feed,
          'Community Feed',
          'Community posts will appear here.',
        );

      case 2:
        final user = FirebaseAuth.instance.currentUser;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 55,
                child: Icon(Icons.person, size: 65),
              ),
              const SizedBox(height: 20),
              Text(
                user?.displayName ?? 'Yug Adda User',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(user?.email ?? ''),
              const SizedBox(height: 10),
              const Text('Your User Profile'),
            ],
          ),
        );

      case 3:
        return sectionPage(
          Icons.chat,
          'Chat / Messaging',
          'Your conversations will appear here.',
        );

      case 4:
        return sectionPage(
          Icons.notifications,
          'Notifications',
          'Your notifications will appear here.',
        );

      case 5:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.settings,
                size: 75,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 15,
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return dashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          menuTitles[selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor,
              ),
              accountName: Text(
                FirebaseAuth.instance.currentUser?.displayName ??
                    'Yug Adda User',
              ),
              accountEmail: Text(
                FirebaseAuth.instance.currentUser?.email ?? '',
              ),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 40),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: menuTitles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(
                      menuIcons[index],
                      color: selectedIndex == index
                          ? primaryColor
                          : Colors.grey,
                    ),
                    title: Text(menuTitles[index]),
                    selected: selectedIndex == index,
                    selectedTileColor: Colors.deepPurple.withValues(
                      alpha: 0.10,
                    ),
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });

                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),

      body: selectedPage(),
    ),
    );
    }
    }
