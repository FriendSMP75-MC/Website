import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop'; // <--- Add this for .toJS extension

class SupportUsPage extends StatelessWidget {
  const SupportUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Support Us")),
      body: Column(
        children: [
          const Expanded(child: Center(child: Text("Thank you for your support!"))),
          
          SizedBox(
            height: 100,
            child: HtmlElementView.fromTagName(
              tagName: 'div',
              onElementCreated: (Object element) {
                final web.HTMLElement htmlElement = element as web.HTMLElement;
                
                // Add .toJS at the end of the string to fix the error
                htmlElement.innerHTML = '''
                  <ins class="adsbygoogle"
                       style="display:block"
                       data-ad-client="ca-pub-2317643702082291"
                       data-ad-slot="3452575408"
                       data-ad-format="auto"
                       data-full-width-responsive="true"></ins>
                  <script>
                       (adsbygoogle = window.adsbygoogle || []).push({});
                  </script>
                '''.toJS; 
              },
            ),
          ),
        ],
      ),
    );
  }
}