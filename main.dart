import 'dart:math';
import 'package:puppeteer/puppeteer.dart';

import './util/FileUtil.dart';
import './util/PuppeteerUtil.dart';
import './util/LogUtil.dart';
import './util/DateTimeUtil.dart';

final p = PuppeteerUtil();
final delay = Duration(milliseconds: 100);
final timeout = Duration(seconds: 20);
final List<String> listToIncludeAlways = const ["flutter"];
final List<String> listToInclude = const ["앱 개발"];
final List<String> listToExclude = const ["초등학생", "중학생"];

void main() async {
  Map localData = FileUtil.readJsonFile("./local.json");
  p.openBrowser(
    () async {
      while (true) {
        try {
          await login(localData["id"], localData["pw"]);
          await deleteRequests();
        }
        catch(e) {}
        await wait();
      }
    },
    headless: false,
  );
}

Future<void> login(String id, String pw) async {
  for (int i = 0; i < 5; i++) {
    await p.goto('https://soomgo.com/requests/received');
    if (await isLoginSuccess()) {
      LogUtil.info("로그인 성공");
      break;
    }

    LogUtil.info("로그인 필요함");
    await p.type('[name="email"]', id, delay: delay);
    await p.type('[name="password"]', pw, delay: delay);
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
  LogUtil.info("deleteRequests 시작");
  await p.goto('https://soomgo.com/requests/received');
  await wait(millseconds: 10000);

  List<ElementHandle> tagList =
      await p.$$('.request-list > li > .request-item');
  if (tagList.isEmpty) {
    LogUtil.info("요청이 없습니다.");
    return;
  }

  for (var tag in tagList) {
    var messageTag = await p.$('.quote > span.message', tag: tag);
    String message = await p.html(tag: messageTag);

    if (!isValidRequest(message)) {
      await p.click('.quote-btn.del', tag: tag);
      await p.click('.sv-col-small-button-bw.sv__btn-close');
      // FileUtil.writeFile(
      //     "${DateTimeUtil.now().toIso8601String()}.html", await p.html());
      await p.click('.swal2-confirm.btn');

      LogUtil.info("삭제할 tagText : " + message);
    } else {
      LogUtil.info("내가 좋하하는 tagText : " + message);
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

Future<void> wait({double? millseconds}) async {
  if(millseconds == null) {
    double waitMinutes = (1 + Random().nextInt(2)).toDouble();
    await p.wait(waitMinutes * 60 * 1000);
  }
  else {
    await p.wait(millseconds);
  }
}
