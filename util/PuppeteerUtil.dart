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

  Future<List<ElementHandle>> $$(String selector, {ElementHandle? tag}) async {
    if (tag != null) {
      return await tag.$$(selector);
    } else {
      return await tab.$$(selector);
    }
  }

  Future<ElementHandle> $(String selector, {ElementHandle? tag}) async {
    if (tag != null) {
      return await tag.$(selector);
    } else {
      return await tab.$(selector);
    }
  }

  Future<void> click(String selector, {ElementHandle? tag}) async {
    try {
      if (tag == null) {
        await tab.waitForSelector(selector);
      }
      var tagToClick = await $(selector, tag: tag);
      await tagToClick.click();
    } catch (e) {}
  }
}
