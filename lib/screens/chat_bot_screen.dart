import 'package:climatezone/controllers/chat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatBotScreen extends StatelessWidget {
  ChatBotScreen({super.key});

  final ChatController controller = Get.put(ChatController());

  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        elevation: 0,

        title: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF00D9A5).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Color(0xFF00D9A5),
              ),
            ),

            const SizedBox(width: 12),

            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SmartSense AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Environmental Assistant',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: controller.clearChat,
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),

      body: Column(
        children: [
          // ======================================================
          // CHAT
          // ======================================================
          Expanded(
            child: Obx(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
              });

              return ListView.builder(
                controller: scrollController,

                padding: const EdgeInsets.all(18),

                itemCount: controller.messages.length,

                itemBuilder: (context, index) {
                  final item = controller.messages[index];

                  final bool isBot = item['isBot'] as bool;

                  final bool isLoading = item['loading'] == true;

                  return Align(
                    alignment: isBot
                        ? Alignment.centerLeft
                        : Alignment.centerRight,

                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),

                      margin: const EdgeInsets.only(bottom: 12),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),

                      decoration: BoxDecoration(
                        color: isBot
                            ? const Color(0xFF151D25)
                            : const Color(0xFF00D9A5),

                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),

                          topRight: const Radius.circular(18),

                          bottomLeft: Radius.circular(isBot ? 4 : 18),

                          bottomRight: Radius.circular(isBot ? 18 : 4),
                        ),
                      ),

                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF00D9A5),
                              ),
                            )
                          : Text(
                              item['message'].toString(),

                              style: TextStyle(
                                color: isBot ? Colors.white : Colors.black,

                                fontSize: 14,

                                height: 1.45,
                              ),
                            ),
                    ),
                  );
                },
              );
            }),
          ),

          // ======================================================
          // INPUT
          // ======================================================
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),

            decoration: const BoxDecoration(
              color: Color(0xFF10161D),

              border: Border(top: BorderSide(color: Color(0xFF1D2833))),
            ),

            child: SafeArea(
              top: false,

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,

                      style: const TextStyle(color: Colors.white),

                      minLines: 1,
                      maxLines: 4,

                      textInputAction: TextInputAction.send,

                      onSubmitted: (_) {
                        _sendMessage();
                      },

                      decoration: InputDecoration(
                        hintText: 'Ask SmartSense AI...',

                        hintStyle: const TextStyle(color: Colors.grey),

                        filled: true,

                        fillColor: const Color(0xFF151D25),

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Obx(
                    () => Container(
                      height: 50,
                      width: 50,

                      decoration: BoxDecoration(
                        color: controller.isLoading.value
                            ? Colors.grey
                            : const Color(0xFF00D9A5),

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: IconButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : _sendMessage,

                        icon: const Icon(
                          Icons.send_rounded,

                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final message = messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    controller.sendMessage(message);

    messageController.clear();
  }
}
