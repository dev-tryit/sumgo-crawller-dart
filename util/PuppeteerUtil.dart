import 'package:puppeteer/puppeteer.dart';

// ---Guide
// await tab.waitForSelector(id); // 해당selector가 있는지 기다리는데 사용
// tag.$('.quote > span.message')// querySelector를 나타냄.
// tab.$$('.request-list > li .quote > span.message'); // querySelectorAll를 나타냄.

// /querySelectorAll

class PuppeteerUtil {
  late Browser browser;
  late Page tab;

  final defaultTimeout = Duration(seconds: 10);

  final List<String> listToInclude = const ["취미/자기개발", "앱 개발"];
  final List<String> listToExclude = const ["초등학생", "중학생", "고등학생", "20대"];

  Future<void> openBrowser(Future<void> Function() function) async {
    //open
    browser = await puppeteer.launch(
      headless: true,
      args: [
        '--no-sandbox',
        '--window-size=1280,1024',
      ],
      defaultViewport: DeviceViewport(
        width: 1280,
        height: 1024,
      ),
    );
    tab = await browser.newPage();
    tab.defaultTimeout = defaultTimeout;

    //process
    await function();

    //close
    try {
      await tab.close();
      await browser.close();
    } catch (e) {}
  }

  Future<void> deleteRequests() async {
    print("deleteRequests 시작");
    await goto('https://soomgo.com/requests/received');

    List<ElementHandle> tagList =
        await tab.$$('.request-list > li > .request-item');
    if (tagList.isEmpty) {
      print("요청이 없습니다.");
      return;
    }
    print("요청이 있습니다.");

    for (var tag in tagList) {
      var messageTag = await tag.$('.quote > span.message');
      String message = await tagHtml(messageTag);

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

  Future<void> goto(String url) async {
    await tab.goto(url, wait: Until.networkIdle);
  }

  Future<String> bodyHtml() async {
    return await tab.content ?? "";
  }
  
  Future<String> tagHtml(ElementHandle tag) async {
    return await evaluate(r'el => el.textContent', args: [tag]);
  }

  Future<dynamic> evaluate(String pageFunction, {List? args}) async {
    return await tab.evaluate(pageFunction, args: args);
  }


  Future<void> type(String selector, String content, {Duration? delay}) async {
    await tab.type(selector, content, delay: delay);
  }

  Future<Response?> clickAndWaitForNavigation(String selector,
      {Duration? timeout, Until? wait}) async {
    return await tab.clickAndWaitForNavigation('.btn.btn-login.btn-primary',
        timeout: timeout, wait: wait);
  }

  Future<bool> existTag(String selector) async {
    return await evaluate("Boolean(document.querySelector('$selector'))");
  }

  Future<void> wait(double millseconds) async {
    await evaluate('''async () => {
      await new Promise(function(resolve) { 
            setTimeout(resolve, $millseconds)
      });
  }''');
  }
}
