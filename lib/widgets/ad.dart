import 'dart:js_interop';

@JS('adsbygoogle')
external JSArray<JSAny?> get _adsbygoogle;

void loadAd() {
  final jsObj = JSObject(); // represents {}
  _adsbygoogle.add(jsObj);
}