import 'dart:math';
import 'package:puppeteer/puppeteer.dart';

import './util/FileUtil.dart';
import './util/PuppeteerUtil.dart';

final p = PuppeteerUtil();
final delay = Duration(milliseconds: 100);
final timeout = Duration(seconds: 20);
final List<String> listToIncludeAlways = const ["flutter"];
final List<String> listToInclude = const ["앱 개발"];
final List<String> listToExclude = const ["초등학생", "중학생"];

void main() async {
  Map localData = FileUtil.readJsonFile("./local.json");
  p.openBrowser(() async {
    while (true) {
      await login(localData);
      await deleteRequests();

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
  return await p.include(".invalid-feedback", "입력해주세요") ||
      await p.include(".form-text.text-invalfid", "입력해주세요");
}

Future<void> deleteRequests() async {
  print("deleteRequests 시작");
  await p.goto('https://soomgo.com/requests/received');

  List<ElementHandle> tagList =
      await p.$$('.request-list > li > .request-item');
  if (tagList.isEmpty) {
    print("요청이 없습니다.");
    return;
  }

  for (var tag in tagList) {
    var messageTag = await p.$('.quote > span.message', tag: tag);
    String message = await p.html(tag: messageTag);

    if (!isValidRequest(message)) {
      p.click('.quote-btn.del', tag: tag);
      p.click('.sv-col-small-button-bw.sv__btn-close');
      p.click('.swal2-confirm.btn');

      print("삭제할 tagText : " + message);
    } else {
      print("내가 좋하하는 tagText : " + message);
    }
  }
}

bool isValidRequest(String message) {
  bool isValid = true;
  //이 키워드가 없으면, !isValid
  for (String toInclude in listToInclude) {
    if (!message.contains(toInclude)) {
      isValid = false;
      break;
    }
  }
  //이 키워드가 있으면, !isValid
  for (String toExclude in listToExclude) {
    if (message.contains(toExclude)) {
      isValid = false;
      break;
    }
  }
  //이 키워드가 있으면, 무조건 isValid
  for (String toIncludeAlways in listToIncludeAlways) {
    if (message.toLowerCase().contains(toIncludeAlways.toLowerCase())) {
      isValid = true;
      break;
    }
  }

  return isValid;
}
