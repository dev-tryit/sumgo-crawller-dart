import 'package:puppeteer/puppeteer.dart';
import './util/FileUtil.dart';

// await tab1.waitForSelector(id); // 해당selector가 있는지 기다리는데 사용
void main() async {
  Map localData = FileUtil.readJsonFile("./local.json");

  var browser = await puppeteer.launch(
    headless: true,
    args: ['--no-sandbox'], //없으면 에러남
  );
  var tab1 = await browser.newPage();

  await login(tab1, localData);

  //파싱작업.

  // await tab1.type('.devsite-search-field', 'Headless Chrome');

  // Do something... See other examples
  // await tab1.screenshot();
  // await tab1.pdf();
  // await tab1.evaluate('() => document.title');

  // Gracefully close the browser's process
  await browser.close();
}

Future<void> login(Page tab1, Map localData) async {
  for (int i = 0; i < 3; i++) {
    if (await checkLogin(tab1)) {
      print("로그인 성공");
      break;
    }

    print("로그인 필요함");
    await tab1.type('[name="email"]', localData["id"],
        delay: Duration(milliseconds: 100));
    await tab1.type('[name="password"]', localData["pw"],
        delay: Duration(milliseconds: 100));
    await tab1.click('.btn.btn-login.btn-primary');

    await tab1.waitForNavigation();
  }
}

Future<bool> checkLogin(Page tab1) async {
  await tab1.goto('https://soomgo.com/requests/received',
      wait: Until.networkIdle);
  return !await isLoginPage(tab1);
}

Future<bool> isLoginPage(Page tab1) async {
  return await tab1.evaluate(r"$('.login-page').length>0");
}

Future<bool> checkLoginFail(Page tab1) async {
  return await tab1.evaluate(
      r"(($('.invalid-feedback').html()??'').includes('입력해주세요')) || (($('.form-text.text-invalfid').html()??'').includes('입력해주세요'))");
}
