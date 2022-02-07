import 'package:puppeteer/puppeteer.dart';

void main() async {
  
  /*https://pub.dev/packages/puppeteer*/
  var browser = await puppeteer.launch(
    headless: true,
    args: ['--no-sandbox'],//없으면 에러남
  );

  // Open a new tab
  var myPage = await browser.newPage();

  // Go to a page and wait to be fully loaded
  await myPage.goto('https://www.naver.com', wait: Until.networkIdle);

  String? text = await myPage.content;
  print("text : $text");

  // Do something... See other examples
  await myPage.screenshot();
  await myPage.pdf();
  await myPage.evaluate('() => document.title');

  // Gracefully close the browser's process
  await browser.close();
}
