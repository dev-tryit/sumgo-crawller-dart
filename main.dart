import 'dart:math';
import 'package:puppeteer/puppeteer.dart';

import './util/FileUtil.dart';
import './util/PuppeteerUtil.dart';

final p = PuppeteerUtil();
final delay = Duration(milliseconds: 100);
final timeout = Duration(seconds: 20);

void main() async {
  Map localData = FileUtil.readJsonFile("./local.json");
  p.openBrowser(() async {
    while (true) {
      await login(localData);
      await p.deleteRequests();

      double waitMinutes = (5 + Random().nextInt(5)).toDouble();
      await p.wait(waitMinutes * 60 * 1000);
    }
  });
}

Future<void> login(Map localData) async {
  for (int i = 0; i < 5; i++) {
    await p.goto('https://soomgo.com/requests/received');
    if (await isLoginSuccess()) {
      print("로그인 성공");
      break;
    }

    print("로그인 필요함");
    await p.type('[name="email"]', localData["id"], delay: delay);
    await p.type('[name="password"]', localData["pw"], delay: delay);
    await p.clickAndWaitForNavigation('.btn.btn-login.btn-primary',
        timeout: timeout);
  }
}

Future<bool> isLoginSuccess() async {
  bool isLoginPage = await p.existTag(".login-page");
  return !isLoginPage;
}

Future<bool> checkLoginFail() async {
  return await p.evaluate(
      r"((document.querySelector('.invalid-feedback')?.innerText ?? '').includes('입력해주세요')) || ((document.querySelector('.form-text.text-invalfid')?.innerText ??'').includes('입력해주세요'))");
}
