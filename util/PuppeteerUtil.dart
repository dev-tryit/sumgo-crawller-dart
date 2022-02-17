import 'package:puppeteer/puppeteer.dart';

class PuppeteerUtil {
  late Browser browser;
  late Page tab;

  final defaultTimeout = Duration(seconds: 10);

  Future<void> openBrowser(Future<void> Function() function, {int width=1280, int height=1024, bool headless = true}) async {
    //open
    browser = await puppeteer.launch(
      headless: headless,
      args: [
        '--no-sandbox',
        '--window-size=$width,$height',
      ],
      defaultViewport: DeviceViewport(
        width: width,
        height: height,
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
    await tab.goto(url, wait: Until.networkIdle,timeout:defaultTimeout);
  }

  Future<String> html({ElementHandle? tag}) async {
    if (tag == null) {
      return await tab.content ?? "";
    } else {
      return await evaluate(r'el => el.textContent', args: [tag]);
    }
  }

  Future<dynamic> evaluate(String pageFunction, {List? args}) async {
    return await tab.evaluate(pageFunction, args: args);
  }

  Future<void> type(String selector, String content, {Duration? delay}) async {
    await tab.type(selector, content, delay: delay);
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

  Future<ElementHandle> $(String selector, {ElementHandle? tag}) async {
    // querySelector를 나타냄.
    if (tag != null) {
      return await tag.$(selector);
    } else {
      return await tab.$(selector);
    }
  }

  Future<List<ElementHandle>> $$(String selector, {ElementHandle? tag}) async {
    // querySelectorAll를 나타냄.
    if (tag != null) {
      return await tag.$$(selector);
    } else {
      return await tab.$$(selector);
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

  Future<Response?> clickAndWaitForNavigation(String selector,
      {Duration? timeout, Until? wait}) async {
    try {
      return await tab.clickAndWaitForNavigation(selector,
          timeout: timeout, wait: wait);
    } catch (e) {
      return null;
    }
  }

  Future<bool> include(String selector, String text) async {
    return await evaluate(
        "(document.querySelector('$selector')?.innerText ?? '').includes('$text')");
  }
}
