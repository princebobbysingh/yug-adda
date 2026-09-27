import 'package:flutter/material.dart';

void main() => runApp(const YugAddaApp());

const purple = Color(0xFF7C4DFF);
const deepPurple = Color(0xFF171225);
const surfacePurple = Color(0xFF241B35);

class YugAddaApp extends StatefulWidget {
  const YugAddaApp({super.key});
  @override
  State<YugAddaApp> createState() => _YugAddaAppState();
}

class _YugAddaAppState extends State<YugAddaApp> {
  String language = 'বাংলা';
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Yug Adda',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepPurple,
      colorScheme: ColorScheme.fromSeed(seedColor: purple, brightness: Brightness.dark),
      cardColor: surfacePurple,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(backgroundColor: deepPurple, centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: surfacePurple,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    ),
    home: MainShell(language: language, onLanguageChanged: (v) => setState(() => language = v)),
  );
}

class MainShell extends StatefulWidget {
  final String language;
  final ValueChanged<String> onLanguageChanged;
  const MainShell({super.key, required this.language, required this.onLanguageChanged});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int selected = 0;
  final posts = <Map<String, dynamic>>[
    {'name':'Riya Das','handle':'@riya','text':'আজকের সন্ধ্যাটা এক কাপ চা আর বন্ধুদের আড্ডার জন্য! ☕','likes':18,'liked':false},
    {'name':'Arjun Sen','handle':'@arjun','text':'নতুন সপ্তাহ, নতুন গল্প। তোমাদের কী খবর?','likes':9,'liked':false},
  ];
  final joined = <String>{};
  int pollChoice = -1;

  String tr(String bn, String en, String hi) => widget.language == 'English' ? en : widget.language == 'हिन्दी' ? hi : bn;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      _groups(),
      _map(),
      _chats(),
      _profile(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(children: const [
          Icon(Icons.forum_rounded, color: purple),
          SizedBox(width: 9),
          Text('Yug Adda', style: TextStyle(fontWeight: FontWeight.w800)),
        ]),
        actions: [
          IconButton(onPressed: () => _showNotifications(), icon: const Icon(Icons.notifications_none_rounded)),
        ],
      ),
      body: IndexedStack(index: selected, children: pages),
      floatingActionButton: selected == 0 ? FloatingActionButton(
        backgroundColor: purple, onPressed: _composePost,
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: NavigationBar(
        backgroundColor: surfacePurple,
        indicatorColor: purple.withOpacity(.25),
        selectedIndex: selected,
        onDestinationSelected: (i) => setState(() => selected = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: tr('হোম','Home','होम')),
          NavigationDestination(icon: const Icon(Icons.groups_outlined), selectedIcon: const Icon(Icons.groups), label: tr('গ্রুপ','Groups','समूह')),
          NavigationDestination(icon: const Icon(Icons.map_outlined), selectedIcon: const Icon(Icons.map), label: tr('ম্যাপ','Map','मैप')),
          NavigationDestination(icon: const Icon(Icons.chat_bubble_outline), selectedIcon: const Icon(Icons.chat_bubble), label: tr('চ্যাট','Chats','चैट')),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: tr('প্রোফাইল','Profile','प्रोफ़ाइल')),
        ],
      ),
    );
  }

  Widget _home() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
    children: [
      Text(tr('আপনার কমিউনিটির গল্প','Stories from your community','आपके समुदाय की कहानियाँ'), style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
      const SizedBox(height: 14),
      SizedBox(height: 88, child: ListView(scrollDirection: Axis.horizontal, children: [
        _story('আপনি', Icons.add, purple), _story('Riya', Icons.face_3, Colors.pink),
        _story('Arjun', Icons.face, Colors.orange), _story('Mita', Icons.face_4, Colors.teal),
        _story('Sayan', Icons.face_6, Colors.blue),
      ])),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tr('আজকের পোল','Today’s poll','आज का पोल'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        const SizedBox(height: 8),
        const Text('এই সপ্তাহে কমিউনিটি আড্ডা কোথায় হবে?'),
        ...['অনলাইন','কফি শপে','পার্কে'].asMap().entries.map((e) => RadioListTile<int>(
          value: e.key, groupValue: pollChoice, contentPadding: EdgeInsets.zero,
          title: Text(e.value), onChanged: (v) => setState(() => pollChoice = v ?? -1),
        )),
        if (pollChoice >= 0) Text(tr('আপনার ভোট সংরক্ষিত হয়েছে (ডেমো)','Your vote is saved (demo)','आपका वोट सहेजा गया (डेमो)'), style: const TextStyle(color: Colors.greenAccent)),
      ]))),
      const SizedBox(height: 10),
      ...posts.map((p) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(backgroundColor: purple.withOpacity(.25), child: Text(p['name'].toString()[0])),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(p['handle'], style: TextStyle(color: Colors.white.withOpacity(.55), fontSize: 12)),
            ])),
            const Icon(Icons.more_horiz),
          ]),
          const SizedBox(height: 14),
          Text(p['text'], style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          Container(height: 150, decoration: BoxDecoration(color: purple.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: const Center(child: Icon(Icons.image_outlined, size: 42, color: purple))),
          Row(children: [
            IconButton(onPressed: () => setState(() { p['liked'] = !p['liked']; p['likes'] += p['liked'] ? 1 : -1; }), icon: Icon(p['liked'] ? Icons.favorite : Icons.favorite_border, color: p['liked'] ? Colors.pinkAccent : null)),
            Text('${p['likes']}'),
            const SizedBox(width: 18),
            const Icon(Icons.mode_comment_outlined, size: 20), const SizedBox(width: 6), const Text('মন্তব্য'),
            const Spacer(), IconButton(onPressed: () => _snack('শেয়ার ফিচারটি ব্যাকএন্ড যুক্ত হলে চালু হবে'), icon: const Icon(Icons.share_outlined)),
          ]),
        ])),
      )),
    ],
  );

  Widget _story(String name, IconData icon, Color color) => Padding(
    padding: const EdgeInsets.only(right: 14),
    child: Column(children: [
      Container(width: 58, height: 58, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)), child: CircleAvatar(backgroundColor: surfacePurple, child: Icon(icon, color: color))),
      const SizedBox(height: 5), Text(name, style: const TextStyle(fontSize: 12)),
    ]),
  );

  Widget _groups() => ListView(padding: const EdgeInsets.all(16), children: [
    Text(tr('কমিউনিটি খুঁজুন','Discover communities','समुदाय खोजें'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    TextField decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: tr('নাম বা আগ্রহ দিয়ে খুঁজুন','Search by name or interest','नाम या रुचि से खोजें')),
    const SizedBox(height: 12),
    _groupCard('Kolkata Book Lovers','বই, পাঠচক্র ও সাহিত্য আলোচনা','Public', Icons.menu_book),
    _groupCard('Weekend Explorers','সপ্তাহান্তের ঘোরাঘুরি পরিকল্পনা','Public', Icons.explore),
    _groupCard('বন্ধুদের আড্ডা','শুধু আমন্ত্রিত সদস্যদের জন্য','Private', Icons.lock),
    Card(child: ListTile(leading: const Icon(Icons.add_circle_outline, color: purple), title: Text(tr('নতুন কমিউনিটি তৈরি করুন','Create a community','नया समुदाय बनाएँ')), onTap: () => _snack('কমিউনিটি তৈরি API যুক্ত হলে চালু হবে'))),
  ]);

  Widget _groupCard(String name, String description, String type, IconData icon) {
    final isJoined = joined.contains(name);
    return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
      leading: CircleAvatar(backgroundColor: purple.withOpacity(.2), child: Icon(icon, color: purple)),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('$description\n$type community', maxLines: 2),
      isThreeLine: true,
      trailing: OutlinedButton(onPressed: () => setState(() => isJoined ? joined.remove(name) : joined.add(name)), child: Text(isJoined ? 'Joined' : 'Join')),
    ));
  }

  Widget _map() => ListView(padding: const EdgeInsets.all(16), children: [
    Text(tr('গ্রুপ ম্যাপ','Group map','ग्रुप मैप'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    Container(height: 250, decoration: BoxDecoration(color: surfacePurple, borderRadius: BorderRadius.circular(18)), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.map_outlined, size: 60, color: purple), SizedBox(height: 12),
      Text('Map provider integration pending'),
      Text('এই ডেমোতে কোনো অবস্থান শেয়ার হয় না।', style: TextStyle(color: Colors.white60)),
    ])),
    const SizedBox(height: 12),
    Card(child: SwitchListTile(value: false, onChanged: (_) => _snack('লোকেশন শেয়ারিং চালুর আগে স্পষ্ট সম্মতি ও নিরাপদ ব্যাকএন্ড প্রয়োজন'), title: Text(tr('আমার অবস্থান শেয়ার করুন','Share my location','मेरी लोकेशन साझा करें')), subtitle: Text(tr('ডিফল্টভাবে বন্ধ','Off by default','डिफ़ॉल्ट रूप से बंद')))),
    const Text('Location sharing will require explicit consent, visibility controls, and a backend policy before release.'),
  ]);

  Widget _chats() => ListView(padding: const EdgeInsets.all(16), children: [
    Text(tr('বার্তা','Messages','संदेश'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    _chat('Riya Das','আজকের আড্ডার প্ল্যান কী?','2 min ago', Icons.face_3),
    _chat('Weekend Explorers','Arjun: রবিবার সকাল ৮টা?','1 hr ago', Icons.explore),
    _chat('বন্ধুদের আড্ডা','Mita: ছবি পাঠালাম','Yesterday', Icons.groups),
    Card(child: ListTile(leading: const Icon(Icons.call, color: purple), title: Text(tr('ভয়েস/ভিডিও কল','Voice/video calls','वॉइस/वीडियो कॉल')), subtitle: Text(tr('কলিং পরিষেবা সংযুক্ত করা বাকি','Calling service integration pending','कॉल सेवा जोड़ना बाकी है')))),
  ]);

  Widget _chat(String name, String message, String time, IconData icon) => Card(child: ListTile(
    leading: CircleAvatar(backgroundColor: purple.withOpacity(.2), child: Icon(icon, color: purple)),
    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(message), trailing: Text(time, style: const TextStyle(fontSize: 11, color: Colors.white54)),
    onTap: () => _snack('চ্যাট স্ক্রিন ও রিয়েল-টাইম মেসেজিং পরবর্তী ধাপে যুক্ত হবে'),
  ));

  Widget _profile() => ListView(padding: const EdgeInsets.all(16), children: [
    const SizedBox(height: 12),
    const Center(child: CircleAvatar(radius: 44, backgroundColor: purple, child: Icon(Icons.person, size: 48))),
    const SizedBox(height: 12),
    const Center(child: Text('Yug Adda Member', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
    const Center(child: Text('@your_handle', style: TextStyle(color: Colors.white60))),
    const SizedBox(height: 24),
    Card(child: Column(children: [
      ListTile(leading: const Icon(Icons.translate, color: purple), title: Text(tr('অ্যাপের ভাষা','App language','ऐप की भाषा')), subtitle: Text(widget.language), trailing: DropdownButton<String>(
        value: widget.language, underline: const SizedBox(), items: const ['বাংলা','English','हिन्दी'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
        onChanged: (v) { if (v != null) widget.onLanguageChanged(v); },
      )),
      const Divider(height: 1),
      ListTile(leading: const Icon(Icons.privacy_tip_outlined, color: purple), title: Text(tr('গোপনীয়তা ও নিরাপত্তা','Privacy & safety','गोपनीयता और सुरक्षा')), onTap: () => _snack('Privacy controls will be implemented with backend authentication.')),
      ListTile(leading: const Icon(Icons.help_outline, color: purple), title: Text(tr('সাহায্য ও সমর্থন','Help & support','सहायता और समर्थन')), onTap: () => _snack('Support center coming soon.')),
      ListTile(leading: const Icon(Icons.logout, color: purple), title: Text(tr('লগ আউট','Log out','लॉग आउट')), onTap: () => _snack('Authentication is not connected in this demo.')),
    ])),
  ]);

  void _composePost() {
    final controller = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(tr('নতুন পোস্ট','Create post','पोस्ट बनाएँ')),
      content: TextField(controller: controller, maxLines: 4, decoration: InputDecoration(hintText: tr('আপনার মনের কথা লিখুন...','What’s on your mind?','आपके मन में क्या है?'))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('বাতিল','Cancel','रद्द करें'))),
        FilledButton(onPressed: () {
          final value = controller.text.trim();
          if (value.isNotEmpty) setState(() => posts.insert(0, {'name':'You','handle':'@you','text':value,'likes':0,'liked':false}));
          Navigator.pop(ctx);
        }, child: Text(tr('পোস্ট করুন','Post','पोस्ट करें'))),
      ],
    ));
  }

  void _showNotifications() => showModalBottomSheet(context: context, builder: (_) => const SafeArea(child: Padding(padding: EdgeInsets.all(24), child: Text('No new notifications (demo).'))));
  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
