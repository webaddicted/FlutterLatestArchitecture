import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pingmexx/main.dart';
import 'package:pingmexx/utils/common/global_utilities.dart';
import 'package:pingmexx/utils/widgethelper/widget_helper.dart';
import 'package:pingmexx/view/profile/user_profile_screen.dart';
import '../../controller/chat_controller.dart';
import '../../data/bean/friend/friend_model.dart';
import '../../data/bean/chat/chat_message_model.dart';
import '../../data/repo/firestore_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';

class ChatDetailScreen extends StatefulWidget {
  final FriendModel friend;

  const ChatDetailScreen({Key? key, required this.friend}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}


class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatController controller = Get.find<ChatController>();
  final ScrollController _scrollController = ScrollController();

  ChatMessageModel? _replyToMessage;
  ChatMessageModel? _forwardMessage;
  Map<String, ChatMessageModel?> _repliedMessagesCache = {};
  final ImagePicker _picker = ImagePicker();

  // Typing status
  String _otherUserTypingTo = '';
  StreamSubscription? _typingSubscription;
  Timer? _typingTimer;

  bool isBlocked = false;
  bool _isInitialized = false;
  Stream<List<ChatMessageModel>>? _messagesStream;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Initialize messages stream first
      _messagesStream = FirestoreService.getMessages(widget.friend.friendId!);
      
      // Mark all messages as read when chat screen is opened
      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      await FirestoreService.markMessagesAsRead(widget.friend.friendId!, currentUserEmail);
      
      // Check if user is blocked
      String myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      isBlocked = await FirestoreService.isUserBlocked(myUid, widget.friend.friendId!);
      
      // Setup typing listener
      _setupTypingListener();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      printLog(msg: "Error initializing chat: $e");
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkIfBlocked();
  }

  Future<void> _checkIfBlocked() async {
    String myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    isBlocked = await FirestoreService.isUserBlocked(myUid, widget.friend.friendId!);
    setState(() {});
  }

  void _setupTypingListener() {
    String otherUserUid = widget.friend.friendId!;
    _typingSubscription = FirestoreService.usersCollectionRef
        .doc(otherUserUid)
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _otherUserTypingTo = data['typingTo'] ?? '';
        });
      }
    });
  }

  void _onTextChanged(String value) async {
    String myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    String otherUserUid = widget.friend.friendId!;
    if (value.isNotEmpty) {
      await FirestoreService.setTypingTo(myUid, otherUserUid);
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 2), () async {
        await FirestoreService.setTypingTo(myUid, null);
      });
    } else {
      await FirestoreService.setTypingTo(myUid, null);
      _typingTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    String otherUserEmail = controller.getOtherUserEmail(widget.friend);
    String currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? 'You';

    bool isReply = _replyToMessage != null;
    bool isForward = _forwardMessage != null;
    String? replyToMsgDoc = _replyToMessage?.messageId;
    String? forwardContent = _forwardMessage?.message;

    ChatMessageModel message = ChatMessageModel(
      friendId: widget.friend.friendId,
      senderEmail: currentUserEmail,
      receiverEmail: otherUserEmail,
      message: isForward ? forwardContent : _messageController.text.trim(),
      messageType: MessageType.text,
      isRead: false,
      isReply: isReply,
      replyToMsgDoc: replyToMsgDoc,
      sd: false,
      rd: false,
      isForward: isForward,
      sname: currentUserName,
    );

    FirestoreService.sendMessage(message);
    _messageController.clear();
    setState(() {
      _replyToMessage = null;
      _forwardMessage = null;
    });

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onReply(ChatMessageModel message) {
    setState(() {
      _replyToMessage = message;
      _forwardMessage = null;
    });
  }

  void _onForward(ChatMessageModel message) {
    setState(() {
      _forwardMessage = message;
      _replyToMessage = null;
    });
    _sendMessage();
  }

  Future<void> _fetchRepliedMessage(String? messageId) async {
    if (messageId == null || _repliedMessagesCache.containsKey(messageId)) return;
    final msg = await FirestoreService.getMessageById(messageId);
    setState(() {
      _repliedMessagesCache[messageId] = msg;
    });
  }

  Future<void> _showAttachmentMenu() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF202C33),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildAttachmentItem(Icons.image, 'Gallery', _onGalleryTap),
              _buildAttachmentItem(Icons.camera_alt, 'Camera', _onCameraTap),
              _buildAttachmentItem(Icons.lock, 'Private Photo', _onPrivatePhotoTap),
              _buildAttachmentItem(Icons.location_on, 'Location', _onStubTap),
              _buildAttachmentItem(Icons.person, 'Contact', _onStubTap),
              _buildAttachmentItem(Icons.insert_drive_file, 'Document', _onStubTap),
              _buildAttachmentItem(Icons.audiotrack, 'Audio', _onStubTap),
              _buildAttachmentItem(Icons.poll, 'Poll', _onStubTap),
              _buildAttachmentItem(Icons.currency_rupee, 'Payment', _onStubTap),
              _buildAttachmentItem(Icons.event, 'Event', _onStubTap),
              _buildAttachmentItem(Icons.image_search, 'AI images', _onStubTap),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A3942),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  void _onStubTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature coming soon!')),
    );
  }

  Future<void> _onCameraTap() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo != null) {
      await _uploadAndSendImage(photo);
    }
  }

  Future<void> _onGalleryTap() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      await _uploadAndSendImage(image);
    }
  }

  Future<void> _onPrivatePhotoTap() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      await _uploadAndSendImage(image, isPrivate: true);
    }
  }

  Future<void> _uploadAndSendImage(XFile file, {bool isPrivate = false}) async {
    try {
      String fileName = 'chat_images/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      Reference ref = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = ref.putData(await file.readAsBytes());
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      // Send as image message
      String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      String otherUserEmail = controller.getOtherUserEmail(widget.friend);
      String currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? 'You';
      ChatMessageModel message = ChatMessageModel(
        friendId: widget.friend.friendId,
        senderEmail: currentUserEmail,
        receiverEmail: otherUserEmail,
        message: downloadUrl,
        messageType: MessageType.image,
        isRead: false,
        isReply: false,
        replyToMsgDoc: null,
        sd: false,
        rd: false,
        isForward: false,
        sname: currentUserName,
        isPrivate: isPrivate,
      );
      await FirestoreService.sendMessage(message);
    } catch (e) {
      showSnackBar(context, 'Failed to upload image: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: const Color(0xFF111B21),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF25D366),
          ),
        ),
      );
    }

    String otherUserName = controller.getOtherUserName(widget.friend);
    String otherUserImage = controller.getOtherUserImage(widget.friend);
    String currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202C33),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: InkWell(
          onTap: (){
          var otheruuid =  FirebaseAuth.instance.currentUser?.uid==widget.friend.senderUid?widget.friend.receiverUid:widget.friend.senderUid;
            Get.to(() => UserProfileScreen(uuid: otheruuid));
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[600],
                backgroundImage: otherUserImage.isNotEmpty
                    ? CachedNetworkImageProvider(otherUserImage)
                    : null,
                child: otherUserImage.isEmpty
                    ? Text(
                        otherUserName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherUserName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_otherUserTypingTo == FirebaseAuth.instance.currentUser?.uid)
                      const Text(
                        'Typing...',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    else
                      const Text(
                        'Online',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.white),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF2A3942),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'view_contact',
                child: Text('View contact', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'media',
                child: Text('Media, links, and docs', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'search',
                child: Text('Search', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'clear_chat',
                child: Text('Clear chat', style: TextStyle(color: Colors.red)),
              ),
              const PopupMenuItem<String>(
                value: 'report_spam',
                child: Text('Report Spam', style: TextStyle(color: Colors.red)),
              ),
              PopupMenuItem<String>(
                value: isBlocked ? 'unblock' : 'block',
                child: Text(isBlocked ? 'Unblock' : 'Block', style: const TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (value) async {
              if (value == 'clear_chat') {
                bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Chat'),
                    content: const Text('Are you sure you want to delete all messages in this chat?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirestoreService.clearChat(widget.friend.friendId!);
                }
              } else if (value == 'report_spam') {
                bool? confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Report Spam'),
                    content: const Text('Are you sure you want to report this user for spam?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Report'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    await FirestoreService.reportSpam(
                      reporterEmail: FirebaseAuth.instance.currentUser?.email ?? '',
                      reportedEmail: controller.getOtherUserEmail(widget.friend),
                      friendId: widget.friend.friendId!,
                    );
                    showSnackBar(context, 'User reported for spam.');
                  } catch (e) {
                    if (e.toString().contains('already_reported')) {
                      showSnackBar(context, 'You have already reported this user.');
                    } else {
                      showSnackBar(context, 'Error: ${e.toString()}');
                    }
                  }
                }
              } else if (value == 'block') {
                await FirestoreService.blockUser(FirebaseAuth.instance.currentUser?.uid ?? '', widget.friend.friendId!);
                setState(() => isBlocked = true);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked.')));
              } else if (value == 'unblock') {
                await FirestoreService.unblockUser(FirebaseAuth.instance.currentUser?.uid ?? '', widget.friend.friendId!);
                setState(() => isBlocked = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User unblocked.')));
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [
          if (isBlocked)
            Container(
              color: Colors.red[900],
              padding: const EdgeInsets.all(12),
              child: const Row(
                children: [
                  Icon(Icons.block, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You have blocked this user. Unblock to continue chatting.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: isBlocked ? null : _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  printLog(msg: "Error in message stream: ${snapshot.error}");
                  return Center(
                    child: Text(
                      'Error loading messages: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF25D366),
                    ),
                  );
                }

                List<ChatMessageModel> messages = snapshot.data!;
                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    ChatMessageModel message = messages[index];
                    bool isMe = message.senderEmail == currentUserEmail;
                    return _buildMessageBubble(message, isMe);
                  },
                );
              },
            ),
          ),
          // Reply/Forward Preview
          if (_replyToMessage != null)
            Container(
              color: Colors.green[900],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.reply, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _replyToMessage!.message ?? '',
                      style: const TextStyle(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => setState(() => _replyToMessage = null),
                  ),
                ],
              ),
            ),
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF202C33),
            child: SafeArea(
              child: Row(
                children: [
                  if (!isBlocked) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A3942),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                decoration: const InputDecoration(
                                  hintText: 'Type a message',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                maxLines: null,
                                onSubmitted: (_) => _sendMessage(),
                                onChanged: _onTextChanged,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.attach_file,
                                color: Colors.grey,
                              ),
                              onPressed: _showAttachmentMenu,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.grey,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF25D366),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel message, bool isMe) {
    if (message.isReply == true && message.replyToMsgDoc != null) {
      _fetchRepliedMessage(message.replyToMsgDoc);
    }
    if (message.messageType == MessageType.image && message.message != null) {
      if (message.isPrivate == true) {
        // Private photo: show blurred/locked preview
        return GestureDetector(
          onTap: () => _showPrivatePhotoPreview(message.message!),
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!isMe) ...[
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.grey[600],
                      child: Text(
                        controller.getOtherUserName(widget.friend).substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              message.message!,
                              fit: BoxFit.cover,
                              width: 200,
                              height: 200,
                              color: Colors.black.withOpacity(0.7),
                              colorBlendMode: BlendMode.darken,
                            ),
                          ),
                          const Icon(Icons.lock, color: Colors.white, size: 48),
                          const Text(
                            'Private Photo',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return GestureDetector(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: const Icon(Icons.reply),
                    title: const Text('Reply'),
                    onTap: () {
                      Navigator.pop(context);
                      _onReply(message);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.forward),
                    title: const Text('Forward'),
                    onTap: () {
                      Navigator.pop(context);
                      _onForward(message);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      Navigator.pop(context);
                      await FirestoreService.deleteMessage(widget.friend.friendId!, message.messageId!);
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isMe) ...[
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey[600],
                    child: Text(
                      controller.getOtherUserName(widget.friend).substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.isReply == true && message.replyToMsgDoc != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              _repliedMessagesCache[message.replyToMsgDoc]?.message != null
                                ? 'Replying to: ${_repliedMessagesCache[message.replyToMsgDoc]?.message}'
                                : 'Replying...',
                              style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ),
                        if (message.isForward == true)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              'Forwarded',
                              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            message.message!,
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.red),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                width: 200,
                                height: 200,
                                child: Center(child: CircularProgressIndicator()),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatMessageTime(message.timestamp),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 4),
                              Icon(
                                message.isRead == true ? Icons.done_all : Icons.done,
                                size: 16,
                                color: message.isRead == true ? Colors.blue[300] : Colors.grey,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.reply),
                  title: const Text('Reply'),
                  onTap: () {
                    Navigator.pop(context);
                    _onReply(message);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.forward),
                  title: const Text('Forward'),
                  onTap: () {
                    Navigator.pop(context);
                    _onForward(message);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await FirestoreService.deleteMessage(widget.friend.friendId!, message.messageId!);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[600],
                  child: Text(
                    controller.getOtherUserName(widget.friend).substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF005C4B) : const Color(0xFF202C33),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.isReply == true && message.replyToMsgDoc != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            _repliedMessagesCache[message.replyToMsgDoc]?.message != null
                              ? 'Replying to: ${_repliedMessagesCache[message.replyToMsgDoc]?.message}'
                              : 'Replying...',
                            style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ),
                      if (message.isForward == true)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            'Forwarded',
                            style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ),
                      Text(
                        message.message ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatMessageTime(message.timestamp),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.isRead == true
                                ? Icons.done_all
                                : Icons.done,
                              size: 16,
                              color: message.isRead == true
                                ? Colors.blue[300]
                                : Colors.grey,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String period = hour >= 12 ? 'PM' : 'AM';
    
    hour = hour > 12 ? hour - 12 : hour;
    hour = hour == 0 ? 12 : hour;
    
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  void _showPrivatePhotoPreview(String imageUrl) async {
     disableScreenshot();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 5), () async {

          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        });
        return GestureDetector(
          onTap: () async {
            Navigator.of(context).pop();
          },
          child: Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: Hero(
              tag: imageUrl,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        );
      },
    ).then((_) async {
     disableScreenshot();
    });
  }
} 