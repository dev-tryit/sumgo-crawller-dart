import 'dart:math';

import 'package:puppeteer/puppeteer.dart';
import './util/FileUtil.dart';

// ---Guide
// await tab.waitForSelector(id); // 해당selector가 있는지 기다리는데 사용
// tag.$('.quote > span.message')// querySelector를 나타냄.
// tab.$$('.request-list > li .quote > span.message'); // querySelectorAll를 나타냄.

late double waitMinutes;
const defaultTimeout = Duration(seconds: 10);
const delay = Duration(milliseconds: 100);
const timeout = Duration(seconds: 20);
List<String> listToInclude = ["취미/자기개발", "앱 개발"];
List<String> listToExclude = ["초등학생", "중학생", "고등학생", "20대"];

// /querySelectorAll

void main() async {
  Map localData = FileUtil.readJsonFile("./local.json");
  openBrowser((tab) async {
    while (true) {
      waitMinutes = (5 + Random().nextInt(5)).toDouble();

      await login(tab, localData);
      await deleteRequests(tab);
      await wait(tab, waitMinutes * 60 * 1000);
    }
  });
}

Future<void> openBrowser(Future<void> Function(Page tab) function) async {
  var browser = await puppeteer.launch(
    headless: true,
    args: [
      '--no-sandbox',
      '--window-size=1280,1024',
    ], //없으면 에러남
    defaultViewport: DeviceViewport(
      width: 1280,
      height: 1024,
    ),
  );
  var tab = await browser.newPage();
  tab.defaultTimeout = defaultTimeout;

  await function(tab);

  // Gracefully close the browser's process
  try {
    await tab.close();
    await browser.close();
  } catch (e) {}
}

Future<void> deleteRequests(Page tab) async {
  print("deleteRequests 시작");
  await tab.goto('https://soomgo.com/requests/received',
      wait: Until.networkIdle);

  List<ElementHandle> tagList =
      await tab.$$('.request-list > li > .request-item');
  if (tagList.isEmpty) {
    print("요청이 없습니다.");
    return;
  }
  print("요청이 있습니다.");

  for (var tag in tagList) {
    var messageTag = await tag.$('.quote > span.message');
    String message = await tagHtml(tab, messageTag);

    bool validRequest = true;
    //포함할 request
    for (String toInclude in listToInclude) {
      if (!message.contains(toInclude)) {
        validRequest = false;
        break;
      }
    }
    //제외할 request
    for (String toExclude in listToExclude) {
      if (message.contains(toExclude)) {
        validRequest = false;
        break;
      }
    }

    if (!validRequest) {
      var deleteTag = await tag.$('.quote-btn.del');
      await deleteTag.click();

      try {
        await tab.waitForSelector('.sv-col-small-button-bw.sv__btn-close');
        var closeTag = await tab.$('.sv-col-small-button-bw.sv__btn-close');
        await closeTag.click();
      } catch (e) {}

      // FileUtil.writeFile("body.html", await bodyHtml(tab));

      try {
        await tab.waitForSelector('.swal2-confirm.btn');
        var dialogTag = await tab.$('.swal2-confirm.btn');
        await dialogTag.click();
      } catch (e) {}

      print("삭제할 tagText : " + message);
    } else {
      print("내가 좋하하는 tagText : " + message);
    }
  }
}

Future<void> login(Page tab, Map localData) async {
  for (int i = 0; i < 3; i++) {
    if (await checkLogin(tab)) {
      print("로그인 성공");
      break;
    }

    print("로그인 필요함");
    await tab.type('[name="email"]', localData["id"], delay: delay);
    await tab.type('[name="password"]', localData["pw"], delay: delay);
    await tab.clickAndWaitForNavigation('.btn.btn-login.btn-primary',
        timeout: timeout);
  }
}

Future<bool> checkLogin(Page tab) async {
  await tab.goto('https://soomgo.com/requests/received',
      wait: Until.networkIdle);
  return !await isLoginPage(tab);
}

Future<bool> isLoginPage(Page tab) async {
  return await tab.evaluate(r"Boolean(document.querySelector('.login-page'))");
}

Future<bool> checkLoginFail(Page tab) async {
  return await tab.evaluate(
      r"((document.querySelector('.invalid-feedback')?.innerText ?? '').includes('입력해주세요')) || ((document.querySelector('.form-text.text-invalfid')?.innerText ??'').includes('입력해주세요'))");
}

Future<String> bodyHtml(Page tab) async {
  return await tab.content ?? "";
}

Future<String> tagHtml(Page tab, ElementHandle tag) async {
  return await tab.evaluate(r'el => el.textContent', args: [tag]);
}

Future<void> wait(Page tab, double millseconds) async {
  await tab.evaluate('''async () => {
      await new Promise(function(resolve) { 
            setTimeout(resolve, $millseconds)
      });
  }''');
}
