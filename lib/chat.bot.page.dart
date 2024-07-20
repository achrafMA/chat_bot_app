import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ChatBotPage extends StatefulWidget {
  ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  List messages = [
    {"message": "Hello", "type": "user"},
    {"message": "How can i help you", "type": "assistant"},
  ];

  TextEditingController queryController = TextEditingController();
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "Chat Bot",
          style: TextStyle(color: Theme.of(context).indicatorColor),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isUser = messages[index]['type'] == 'user';
                  return Column(
                    children: [
                      ListTile(
                        trailing: isUser ? Icon(Icons.person) : null,
                        leading: !isUser ? Icon(Icons.support_agent) : null,
                        title: Row(
                          children: [
                            SizedBox(
                              width: isUser ? 100 : 0,
                            ),
                            Expanded(
                              child: Container(
                                child: Text(
                                  messages[index]['message'],
                                  style:
                                  Theme.of(context).textTheme.headlineMedium,
                                ),
                                color: isUser
                                    ? Color.fromARGB(100, 0, 200, 0)
                                    : Colors.white,
                                padding: EdgeInsets.all(10),
                              ),
                            ),
                            SizedBox(
                              width: isUser ? 0 : 100,
                            )
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: queryController,
                    decoration: InputDecoration(
                      //icon: Icon(Icons.lock),
                      suffixIcon: Icon(Icons.keyboard),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1, color: Theme.of(context).primaryColor),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                IconButton(onPressed: (){
                  String query = queryController.text;
                  var openAiUri = Uri.https("api.openai.com","/v1/chat/completions");
                  Map<String,String> headers = {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer sk-proj-Nu24fcn1xyUE22tsiXMgT3BlbkFJshx9FyfAPmFbSEPFbtko"
                  };
                  var prompt = {
                    "model": "GPT-3.5 Turbo",
                    "messages": [{"role": "user", "content": query}],
                    "temperature": 0
                  };

                  http.post(openAiUri,headers: headers,body: json.encode(prompt))
                  .then(
                          (resp){
                            var responseBody = resp.body;
                            var llmResponse = json.decode(responseBody);
                            String responseContent =
                                llmResponse['choices'][0]['message']['content'];
                            setState(() {
                              messages.add({"message":query,"type":"user"});
                              messages.add({"message": responseContent, "type": "assistant"});
                              scrollController.jumpTo(
                                  scrollController.position.maxScrollExtent + 200);
                            });
                          },
                      onError: (err){
                            print("*******----E-R-R-O-R----*********");
                            print(err);
                      });
                },
                  icon: Icon(
                    Icons.send,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}