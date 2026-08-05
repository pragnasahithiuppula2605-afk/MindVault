import 'package:flutter/material.dart';

import '../models/whatsapp_chat.dart';
import '../widgets/module_app_bar.dart';
import '../widgets/module_card.dart';
import '../widgets/module_empty_state.dart';
import '../widgets/module_popup_menu.dart';
import '../widgets/module_snackbar.dart';
import '../repositories/whatsapp_repository.dart';
import '../widgets/whatsapp_message_bubble.dart';
import '../widgets/date_separator.dart';

class WhatsappChatScreen extends StatefulWidget {
  final WhatsappChat chat;

  const WhatsappChatScreen({
    super.key,
    required this.chat,
  });

  @override
  State<WhatsappChatScreen> createState() =>
      _WhatsappChatScreenState();
}

class _WhatsappChatScreenState
    extends State<WhatsappChatScreen> {
  final WhatsappRepository _repository =
      WhatsappRepository();

  List<WhatsappMessage> _messages = [];
List<WhatsappMessage> _filteredMessages = [];

bool _loading = true;

  @override
void initState() {
  super.initState();
  _loadMessages();
}

void _searchMessages(String query) {
  if (query.trim().isEmpty) {
    setState(() {
      _filteredMessages = _messages;
    });
    return;
  }

  final search = query.toLowerCase();

  setState(() {
    _filteredMessages = _messages.where((message) {
      return message.message
              .toLowerCase()
              .contains(search) ||
          message.sender
              .toLowerCase()
              .contains(search);
    }).toList();
  });
}

Future<void> _loadMessages() async {
    final messages = await _repository.getMessages(
      widget.chat.id!,
    );

    if (!mounted) return;

    setState(() {
      _messages = messages;
_filteredMessages = messages;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: ModuleAppBar(
  title: widget.chat.title,
  subtitle: '${_filteredMessages.length} messages',
  totalItems: _filteredMessages.length,
  selectionMode: false,
  selectedCount: 0,
  isSearching: false,
  searchController: TextEditingController(),
  onSearch: (_) {},
  onSearchToggle: () {
    showSearch(
      context: context,
      delegate: _WhatsappMessageSearchDelegate(
        messages: _messages,
      ),
    );
  },
  onSelectAll: () {},
  onFavorite: () async {
    final updatedChat = widget.chat.copyWith(
      isFavorite: !widget.chat.isFavorite,
    );

    await _repository.toggleFavorite(
  updatedChat.id!,
  updatedChat.isFavorite,
);

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      updatedChat.isFavorite
          ? 'Added to Favorites'
          : 'Removed from Favorites',
    );

    Navigator.pop(context, true);
  },
  onDelete: () async {
    await _repository.moveToTrash(
  widget.chat.id!,
);

    if (!mounted) return;

    ModuleSnackBar.show(
      context,
      'Moved to Recycle Bin',
    );

    Navigator.pop(context, true);
  },
  onCloseSelection: () {},
  onSort: (_) {},
),
      body: Container(
  color: const Color(0xFFECE5DD),
  child: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _filteredMessages.isEmpty
              ? const Center(
                  child: Text(
                    "No Messages",
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
  horizontal: 10,
  vertical: 12,
),
                  itemCount: _filteredMessages.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final message = _filteredMessages[index];

DateTime? currentDate;

try {
  currentDate = DateTime.parse(message.timestamp ?? '');
} catch (_) {
  currentDate = null;
}

bool showDate = false;

if (currentDate != null) {
  if (index == 0) {
    showDate = true;
  } else {
    DateTime? previousDate;

    try {
      previousDate = DateTime.parse(
        _filteredMessages[index - 1].timestamp ?? '',
      );
    } catch (_) {}

    if (previousDate == null ||
        previousDate.year != currentDate.year ||
        previousDate.month != currentDate.month ||
        previousDate.day != currentDate.day) {
      showDate = true;
    }
  }
}

final bool senderChanged = index == 0 ||
    _filteredMessages[index - 1].sender !=
        message.sender;

return Padding(
  padding: EdgeInsets.only(
    bottom: senderChanged ? 10 : 2,
  ),
  child: Column(
  crossAxisAlignment:
      CrossAxisAlignment.stretch,
  children: [
    if (showDate)
  Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 12,
    ),
    child: DateSeparator(
      date: currentDate!,
    ),
  ),
    WhatsappMessageBubble(
  message: message,
  showSender: senderChanged,
),
  ],
),
);
                  },
                ),
                ),
    );
  }
}
class _WhatsappMessageSearchDelegate
    extends SearchDelegate {
  final List<WhatsappMessage> messages;

  _WhatsappMessageSearchDelegate({
    required this.messages,
  });

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    final filtered = messages.where((message) {
      return message.message
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          message.sender
              .toLowerCase()
              .contains(query.toLowerCase());
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: Text('No messages found'),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final message = filtered[index];

        return ListTile(
          title: Text(message.message),
          subtitle: Text(
            '${message.sender} • ${message.timestamp ?? ""}',
          ),
        );
      },
    );
  }
}