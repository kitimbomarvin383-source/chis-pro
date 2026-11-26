import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(ChrisTokApp());

class ChrisTokApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: ChrisTokHome(),
    );
  }
}

class VideoItem {
  final String url;
  final String user;
  final String caption;
  final String song;
  final int likes;
  final int comments;
  VideoItem(this.url, this.user, this.caption, this.song, this.likes, this.comments);
}

// FAST V2: Small 360p 1MB videos - load in 2 secs even on slow MTN/Airtel
final videos = [
  VideoItem("https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4", "@funny_kampala", "Funny 😂 Wait for it... #uganda #funny", "Original Sound - funny_kampala", 12400, 342),
  VideoItem("https://test-videos.co.uk/vids/sintel/mp4/h264/360/Sintel_360_10s_1MB.mp4", "@dance_queen256", "New dance challenge 🔥 Try it! #dance #viral", "Afrobeats Mix - DJ Sema", 45200, 1204),
  VideoItem("https://test-videos.co.uk/vids/tears-of-steel/mp4/h264/360/Tears_Of_Steel_360_10s_1MB.mp4", "@football_daily", "Best goal this week! ⚽️ #football #sports", "Sports Beat - Football Daily", 8900, 213),
  VideoItem("https://test-videos.co.uk/vids/jellyfish/mp4/h264/360/Jellyfish_360_10s_1MB.mp4", "@ug_music", "New Ugandan music video 🎵 #music #ug", "New Hit - UG Music", 67300, 2890),
  VideoItem("https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4", "@comedy_central256", "When your mum catches you 😂 #comedy", "Comedy Sound - Central256", 23100, 876),
];

class ChrisTokHome extends StatefulWidget {
  @override
  _ChrisTokHomeState createState() => _ChrisTokHomeState();
}

class _ChrisTokHomeState extends State<ChrisTokHome> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _tab == 0 ? VideoFeed() : _tab == 4 ? ProfilePage() : Center(child: Text("ChrisTok - Coming Soon!", style: TextStyle(fontSize: 20))),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _tab,
        onTap: (i) {
          if (i == 2) {
            showDialog(context: context, builder: (_) => AlertDialog(title: Text("Upload Video"), content: Text("Pick a video from your phone to post to ChrisTok!"), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))]));
            return;
          }
          setState(() => _tab = i);
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Discover"),
          BottomNavigationBarItem(icon: Icon(Icons.add_box, size: 32, color: Colors.white), label: "Upload"),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: "Inbox"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Me"),
        ],
      ),
    );
  }
}

class VideoFeed extends StatefulWidget {
  @override
  _VideoFeedState createState() => _VideoFeedState();
}

class _VideoFeedState extends State<VideoFeed> {
  late PageController _pageController;
  int _current = 0;
  Map<int, VideoPlayerController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _ensureController(0);
    _ensureController(1);
  }

  void _ensureController(int index) async {
    if (index < 0 || index >= videos.length) return;
    if (_controllers.containsKey(index)) return;
    final c = VideoPlayerController.networkUrl(Uri.parse(videos[index].url));
    _controllers[index] = c;
    await c.initialize();
    c.setLooping(true);
    c.setVolume(1.0);
    if (index == _current) c.play();
    if (mounted) setState(() {});
  }

  void _onPageChanged(int i) {
    setState(() => _current = i);
    _controllers.forEach((key, c) {
      if (key == i) c.play(); else c.pause();
    });
    _ensureController(i + 1);
    // Free memory: dispose videos far away
    _controllers.keys.where((k) => (k - i).abs() > 1).toList().forEach((k) {
      _controllers[k]?.dispose();
      _controllers.remove(k);
    });
  }

  @override
  void dispose() {
    _controllers.forEach((_, c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(child: Padding(padding: EdgeInsets.all(12), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text("Following", style: TextStyle(color: Colors.grey)), SizedBox(width: 20), Text("For You", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)), Text("  •  ChrisTok", style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold))]))),
        Expanded(child: PageView.builder(scrollDirection: Axis.vertical, itemCount: videos.length, controller: _pageController, onPageChanged: _onPageChanged, itemBuilder: (context, index) => VideoCard(video: videos[index], controller: _controllers[index], isActive: index == _current))),
      ],
    );
  }
}

class VideoCard extends StatefulWidget {
  final VideoItem video;
  final VideoPlayerController? controller;
  final bool isActive;
  VideoCard({required this.video, required this.controller, required this.isActive});
  @override
  _VideoCardState createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _liked = false;
  bool _showHeart = false;
  late int _likeCount;
  @override
  void initState() { super.initState(); _likeCount = widget.video.likes; }
  void _toggleLike() { setState(() { _liked = !_liked; _likeCount += _liked ? 1 : -1; if (_liked) { _showHeart = true; Future.delayed(Duration(milliseconds: 600), () { if (mounted) setState(() => _showHeart = false); }); } }); }
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final ready = c != null && c.value.isInitialized;
    return GestureDetector(
      onDoubleTap: () { if (!_liked) _toggleLike(); },
      onTap: () { if (ready) { if (c.value.isPlaying) c.pause(); else c.play(); setState(() {}); } },
      child: Stack(children: [
        Container(color: Colors.black, child: ready ? SizedBox.expand(child: FittedBox(fit: BoxFit.cover, child: SizedBox(width: c.value.size.width, height: c.value.size.height, child: VideoPlayer(c)))) : Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(color: Colors.pink), SizedBox(height: 10), Text("Loading fast... ChrisTok", style: TextStyle(color: Colors.white70))]))),
        if (_showHeart) Center(child: Icon(Icons.favorite, size: 120, color: Colors.pink.withOpacity(0.9))),
        Positioned(right: 12, bottom: 100, child: Column(children: [
          CircleAvatar(radius: 24, child: Text(widget.video.user[1].toUpperCase(), style: TextStyle(fontSize: 20))),
          SizedBox(height: 16),
          GestureDetector(onTap: _toggleLike, child: Column(children: [Icon(_liked ? Icons.favorite : Icons.favorite_border, color: _liked ? Colors.pink : Colors.white, size: 32), Text("$_likeCount")])),
          SizedBox(height: 16),
          GestureDetector(onTap: () => showModalBottomSheet(context: context, builder: (_) => Container(padding: EdgeInsets.all(16), height: 300, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("${widget.video.comments} Comments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), SizedBox(height: 12), ListTile(leading: CircleAvatar(child: Text("J")), title: Text("Joel"), subtitle: Text("This is so funny 😂🔥")), ListTile(leading: CircleAvatar(child: Text("A")), title: Text("Amina"), subtitle: Text("ChrisTok is the best!"))]))), child: Column(children: [Icon(Icons.comment, size: 32), Text("${widget.video.comments}")])),
          SizedBox(height: 16),
          Column(children: [Icon(Icons.share, size: 32), Text("Share")]),
        ])),
        Positioned(left: 12, bottom: 20, right: 70, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.video.user, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          SizedBox(height: 6),
          Text(widget.video.caption),
          SizedBox(height: 6),
          Row(children: [Icon(Icons.music_note, size: 16), Expanded(child: Text(widget.video.song, overflow: TextOverflow.ellipsis))]),
        ])),
      ]),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Column(children: [
      SizedBox(height: 20),
      CircleAvatar(radius: 45, child: Text("C", style: TextStyle(fontSize: 40))),
      SizedBox(height: 10),
      Text("@chris", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [Column(children: [Text("12", style: TextStyle(fontWeight: FontWeight.bold)), Text("Following")]), SizedBox(width: 30), Column(children: [Text("1.2K", style: TextStyle(fontWeight: FontWeight.bold)), Text("Followers")]), SizedBox(width: 30), Column(children: [Text("45K", style: TextStyle(fontWeight: FontWeight.bold)), Text("Likes")])]),
      SizedBox(height: 20),
      Expanded(child: GridView.count(crossAxisCount: 3, children: List.generate(9, (i) => Container(margin: EdgeInsets.all(2), color: Colors.grey[800], child: Center(child: Icon(Icons.play_arrow)))))),
    ]));
  }
}
